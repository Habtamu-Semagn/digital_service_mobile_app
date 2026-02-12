import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../queue/presentation/bloc/queue_bloc.dart';
import '../../../queue/domain/entities/queue.dart' as entity;
import '../../domain/entities/service.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  int _selectedIndex = 0;
  String? _selectedSectorId;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadServices());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final List<Widget> pages = [
      _buildQueueMonitor(context, l10n, theme),
      const Center(child: Text('Appointments (Officer)')),
      const Center(child: Text('Requests (Officer)')),
      _buildProfileContent(context, l10n, theme),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_selectedSectorId != null) {
                context.read<QueueBloc>().add(QueueLoadList(sectorId: _selectedSectorId!));
              }
            },
          ),
        ],
      ),
      body: BlocListener<QueueBloc, QueueState>(
        listener: (context, state) {
          if (state is QueueActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            // Refresh list
            if (_selectedSectorId != null) {
              context.read<QueueBloc>().add(QueueLoadList(sectorId: _selectedSectorId!));
            }
          } else if (state is QueueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            _buildSectorSelector(context, theme),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'Queue'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Requests'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildSectorSelector(BuildContext context, ThemeData theme) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          // Get unique sectors from services
          final sectors = state.services
              .map((s) => s.sector)
              .toSet()
              .map((name) => {'id': name, 'name': name})
              .toList();
          
          if (_selectedSectorId == null && sectors.isNotEmpty) {
            _selectedSectorId = sectors.first['id'] as String;
            context.read<QueueBloc>().add(QueueLoadList(sectorId: _selectedSectorId!));
          }

          return Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sectors.length,
              itemBuilder: (context, index) {
                final sector = sectors[index];
                final isSelected = _selectedSectorId == sector['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(sector['name'] as String),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSectorId = sector['id'] as String;
                      });
                      context.read<QueueBloc>().add(QueueLoadList(sectorId: _selectedSectorId!));
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQueueMonitor(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        List<entity.Queue> queues = [];
        entity.Queue? nowServing;

        if (state is QueueListLoaded) {
          queues = state.queues;
          nowServing = queues.firstWhere((q) => q.status == 'CALLING' || q.status == 'PROCESSING', orElse: () => queues.firstWhere((q) => q.status == 'WAITING', orElse: () => entity.Queue(id: '', queueNumber: '---', serviceId: '', serviceName: 'No active tickets', userId: '', status: 'NONE', position: 0, estimatedWaitTime: '', createdAt: DateTime.now())));
        }

        if (state is QueueLoading) return const Center(child: CircularProgressIndicator());

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNowServingCard(context, nowServing, theme),
              const SizedBox(height: 24),
              Text('Next in Line', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: queues.length,
                  itemBuilder: (context, index) {
                    final q = queues[index];
                    if (q.id == nowServing?.id && (q.status == 'CALLING' || q.status == 'PROCESSING')) return const SizedBox.shrink();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(q.queueNumber, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(q.serviceName),
                        subtitle: Text(q.status),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () {
                            // Call this specific ticket
                            context.read<QueueBloc>().add(QueueUpdateStatus(queueId: q.id, status: 'CALLING'));
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNowServingCard(BuildContext context, entity.Queue? queue, ThemeData theme) {
    if (queue == null || queue.status == 'NONE') {
      return Card(
        color: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Padding(
          padding: EdgeInsets.all(48.0),
          child: Center(child: Text('No tickets waiting')),
        ),
      );
    }

    final isCalling = queue.status == 'CALLING';
    final isProcessing = queue.status == 'PROCESSING';

    return Card(
      color: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              isProcessing ? 'NOW SERVING' : (isCalling ? 'CALLING...' : 'UP NEXT'),
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            Text(queue.queueNumber, style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900)),
            Text(queue.serviceName, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      String nextStatus = 'CALLING';
                      if (isCalling) nextStatus = 'PROCESSING';
                      if (isProcessing) nextStatus = 'COMPLETED';
                      
                      context.read<QueueBloc>().add(QueueUpdateStatus(queueId: queue.id, status: nextStatus));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isProcessing ? 'COMPLETE' : (isCalling ? 'START SERVING' : 'CALL NEXT'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                if (isCalling || isProcessing) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    onPressed: () {
                      context.read<QueueBloc>().add(QueueUpdateStatus(queueId: queue.id, status: 'REJECTED'));
                    },
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return Column(
                  children: [
                    Text(state.user.fullName, style: theme.textTheme.headlineSmall),
                    Text('Role: ${state.user.role}', style: const TextStyle(color: Colors.grey)),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Change Language'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}
