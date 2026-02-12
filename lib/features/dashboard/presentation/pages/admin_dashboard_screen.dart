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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
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
        _buildStatCard(context, 'Uptime', stats.uptime, Icons.security, Colors.teal),
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
            trailing: const Icon(Icons.more_vert),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.layers),
            title: const Text('Manage Sectors'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/sectors');
            },
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Manage Services'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin/services');
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
}
