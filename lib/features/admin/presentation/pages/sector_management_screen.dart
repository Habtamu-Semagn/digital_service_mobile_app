import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';

class SectorManagementScreen extends StatefulWidget {
  const SectorManagementScreen({super.key});

  @override
  State<SectorManagementScreen> createState() => _SectorManagementScreenState();
}

class _SectorManagementScreenState extends State<SectorManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadSectors());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sector Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSectorDialog(context),
          ),
        ],
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(_getIcon(sector['icon']), color: Colors.blue),
                    ),
                    title: Text(sector['name']),
                    subtitle: Text(sector['description'] ?? 'No description'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showSectorDialog(context, sector: sector),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, sector['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No sectors found'));
        },
      ),
    );
  }

  void _showSectorDialog(BuildContext context, {Map<String, dynamic>? sector}) {
    final nameController = TextEditingController(text: sector?['name']);
    final descController = TextEditingController(text: sector?['description']);
    final iconController = TextEditingController(text: sector?['icon'] ?? 'business');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sector == null ? 'Create Sector' : 'Edit Sector'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: iconController, decoration: const InputDecoration(labelText: 'Icon Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final data = {
                'name': nameController.text,
                'description': descController.text,
                'icon': iconController.text,
              };
              if (sector == null) {
                this.context.read<AdminBloc>().add(AdminCreateSector(data));
              } else {
                this.context.read<AdminBloc>().add(AdminUpdateSector(sector['id'], data));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this sector? This may affect associated services.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              this.context.read<AdminBloc>().add(AdminDeleteSector(id));
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
      case 'business': return Icons.business;
      case 'person': return Icons.person;
      case 'security': return Icons.security;
      case 'payment': return Icons.payment;
      case 'description': return Icons.description;
      default: return Icons.category;
    }
  }
}
