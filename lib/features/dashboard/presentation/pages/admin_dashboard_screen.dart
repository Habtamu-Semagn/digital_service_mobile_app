import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:digital_service_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:digital_service_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:digital_service_app/features/admin/data/models/admin_stats_model.dart';
import 'package:digital_service_app/features/admin/data/models/system_log_model.dart';
import 'package:digital_service_app/features/auth/domain/entities/user.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // 0: Overview, 1: Users, 2: Logs

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    switch (_selectedIndex) {
      case 0:
        context.read<AdminBloc>().add(AdminLoadStats());
        break;
      case 1:
        context.read<AdminBloc>().add(AdminLoadUsers());
        break;
      case 2:
        context.read<AdminBloc>().add(AdminLoadLogs());
        break;
      case 3:
      case 4:
        context.read<AdminBloc>().add(AdminLoadSectors());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          if (_selectedIndex == 3)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showSectorDialog(context),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            _loadData();
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) return const Center(child: CircularProgressIndicator());
          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                ],
              ),
            );
          }

          if (_selectedIndex == 0 && state is AdminStatsLoaded) {
            return _buildOverview(context, state.stats);
          }
          if (_selectedIndex == 1 && state is AdminUsersLoaded) {
            return _buildUserList(context, state.users);
          }
          if (_selectedIndex == 2 && state is AdminLogsLoaded) {
            return _buildLogList(context, state.logs);
          }
          if (_selectedIndex == 3 && state is AdminSectorsLoaded) {
            return _buildSectorList(context, state.sectors);
          }
          if (_selectedIndex == 4 && state is AdminSectorsLoaded) {
            return _buildServiceList(context, state.sectors);
          }

          return const SizedBox.shrink();
        },
      ),
      drawer: _buildDrawer(context, theme),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0: return 'Admin Overview';
      case 1: return 'User Management';
      case 2: return 'System Logs';
      case 3: return 'Sector Management';
      case 4: return 'Service Management';
      default: return 'Admin Console';
    }
  }

  Widget _buildOverview(BuildContext context, AdminStats stats) {
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(context, 'Total Citizens', stats.users.toString(), Icons.people, Colors.blue),
        _buildStatCard(context, 'Total Tickets', stats.queues.toString(), Icons.confirmation_number, Colors.orange),
        _buildStatCard(context, 'Active Sectors', stats.sectors.toString(), Icons.business, Colors.green),
        _buildStatCard(context, 'Total Services', stats.services.toString(), Icons.home_repair_service, Colors.indigo),
      ],
    );
  }

  Widget _buildUserList(BuildContext context, List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(user.fullName[0].toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            title: Text(user.fullName),
            subtitle: Text('${user.role} • ${user.phoneNumber ?? "No phone"}'),
            trailing: user.role == 'ADMIN' 
              ? const Icon(Icons.shield, color: Colors.blueGrey, size: 20)
              : PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'role') {
                      _showRoleDialog(context, user);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(context, user);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'role',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings, size: 20),
                          SizedBox(width: 8),
                          Text('Change Role'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete User', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
          ),
        );
      },
    );
  }

  Widget _buildLogList(BuildContext context, List<SystemLog> logs) {
    return ListView.builder(
      itemCount: logs.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final log = logs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(log.action),
            subtitle: Text('${log.userName ?? "System"} • ${log.createdAt.toString().split('.')[0]}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildSectorList(BuildContext context, List<dynamic> sectors) {
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
              child: Icon(_getSectorIcon(sector['icon']), color: Colors.blue),
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
                  onPressed: () => _confirmSectorDelete(context, sector['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceList(BuildContext context, List<dynamic> sectors) {
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
                leading: Icon(_getServiceIcon(service['icon'])),
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
                      onPressed: () => _confirmServiceDelete(context, service['id']),
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

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('ADMINISTRATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Overview'),
            selected: _selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 0);
              _loadData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text('User Management'),
            selected: _selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 1);
              _loadData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('System Logs'),
            selected: _selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 2);
              _loadData();
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Manage Sectors'),
            selected: _selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 3);
              _loadData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Manage Services'),
            selected: _selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              setState(() => _selectedIndex = 4);
              _loadData();
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: color.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: color)),
            Text(title, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: color.withOpacity(0.8)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, User user) {
    String selectedRole = user.role.toUpperCase();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change User Role'),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User: ${user.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                const Text('Select new role:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: ['CITIZEN', 'OFFICER', 'ADMIN'].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedRole = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
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
                Navigator.pop(context);
                context.read<AdminBloc>().add(AdminUpdateUserRole(user.id, selectedRole));
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Update Role'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.fullName}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(AdminDeleteUser(user.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Sector Management Dialogs
  void _showSectorDialog(BuildContext context, {Map<String, dynamic>? sector}) {
    final nameController = TextEditingController(text: sector?['name']);
    final descController = TextEditingController(text: sector?['description']);
    final iconController = TextEditingController(text: sector?['icon'] ?? 'business');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sector == null ? 'Create Sector' : 'Edit Sector'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Sector Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: iconController,
                  decoration: InputDecoration(
                    labelText: 'Icon Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.insert_emoticon),
                    helperText: 'e.g., business, security, payment',
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
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
                context.read<AdminBloc>().add(AdminCreateSector(data));
              } else {
                context.read<AdminBloc>().add(AdminUpdateSector(sector['id'], data));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmSectorDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this sector? This may affect associated services.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminDeleteSector(id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Service Management Dialogs
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
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Service Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedMode,
                    decoration: InputDecoration(
                      labelText: 'Service Mode',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.settings),
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: iconController,
                    decoration: InputDecoration(
                      labelText: 'Icon Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.insert_emoticon),
                      helperText: 'e.g., confirmation_number, calendar_today',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
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
                  context.read<AdminBloc>().add(AdminCreateService(data));
                } else {
                  context.read<AdminBloc>().add(AdminUpdateService(service['id'], data));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmServiceDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AdminBloc>().add(AdminDeleteService(id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getSectorIcon(String? iconName) {
    switch (iconName) {
      case 'business': return Icons.business;
      case 'person': return Icons.person;
      case 'security': return Icons.security;
      case 'payment': return Icons.payment;
      case 'description': return Icons.description;
      default: return Icons.category;
    }
  }

  IconData _getServiceIcon(String? iconName) {
    switch (iconName) {
      case 'confirmation_number': return Icons.confirmation_number;
      case 'calendar_today': return Icons.calendar_today;
      case 'description': return Icons.description;
      case 'person': return Icons.person;
      default: return Icons.category;
    }
  }
}
