import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';

class ServiceManagementScreen extends StatefulWidget {
  const ServiceManagementScreen({super.key});

  @override
  State<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadSectors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Management'),
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.read<AdminBloc>().add(AdminLoadSectors());
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          
          if (state is AdminSectorsLoaded) {
            final sectors = state.sectors;
            return ListView.builder(
              itemCount: sectors.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final sector = sectors[index];
                final services = sector['services'] as List<dynamic>? ?? [];
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(sector['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                            onPressed: () => _showServiceDialog(context, sectorId: sector['id']),
                          ),
                        ],
                      ),
                    ),
                    ...services.map((service) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(_getIcon(service['icon'])),
                        title: Text(service['name']),
                        subtitle: Text(service['mode'] ?? 'General'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showServiceDialog(context, service: service, sectorId: sector['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _confirmDelete(context, service['id']),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const Divider(height: 32),
                  ],
                );
              },
            );
          }

          return const Center(child: Text('No sectors/services found'));
        },
      ),
    );
  }

  void _showServiceDialog(BuildContext context, {Map<String, dynamic>? service, required String sectorId}) {
    final nameController = TextEditingController(text: service?['name']);
    final descController = TextEditingController(text: service?['description']);
    final iconController = TextEditingController(text: service?['icon'] ?? 'confirmation_number');
    String selectedMode = service?['mode'] ?? 'QUEUE';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(service == null ? 'Create Service' : 'Edit Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Service Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMode,
                  decoration: const InputDecoration(
                    labelText: 'Service Mode',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.settings),
                  ),
                  items: ['ONLINE', 'QUEUE', 'APPOINTMENT'].map((mode) {
                    return DropdownMenuItem(value: mode, child: Text(mode));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedMode = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.insert_emoticon),
                    helperText: 'e.g., confirmation_number, calendar_today',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final data = {
                  'name': nameController.text,
                  'description': descController.text,
                  'mode': selectedMode,
                  'icon': iconController.text,
                  'sectorId': sectorId,
                  'availability': 'FULL_TIME',
                };
                if (service == null) {
                  this.context.read<AdminBloc>().add(AdminCreateService(data));
                } else {
                  this.context.read<AdminBloc>().add(AdminUpdateService(service['id'], data));
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              this.context.read<AdminBloc>().add(AdminDeleteService(id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'confirmation_number': return Icons.confirmation_number;
      case 'calendar_today': return Icons.calendar_today;
      case 'description': return Icons.description;
      case 'person': return Icons.person;
      default: return Icons.category;
    }
  }
}
