import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/service_card.dart';
import '../../../queue/presentation/bloc/queue_bloc.dart';
import 'tabs/my_requests_tab.dart';
import '../../../notifications/presentation/pages/notifications_tab.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadServices());
    context.read<QueueBloc>().add(QueueLoadActive());
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // List of pages for bottom navigation
    final List<Widget> pages = [
      _buildDashboardContent(context, l10n, theme),
      const MyRequestsTab(),
      const NotificationsTab(),
      _buildProfileContent(context, l10n, theme),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(l10n)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // TODO: Implement language switcher
            },
          ),
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: l10n.myRequests,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: l10n.notifications,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_selectedIndex) {
      case 0:
        return l10n.dashboard;
      case 1:
        return l10n.myRequests;
      case 2:
        return l10n.notifications;
      case 3:
        return l10n.profile;
      default:
        return l10n.dashboard;
    }
  }

  Widget _buildDashboardContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) return const Center(child: CircularProgressIndicator());
        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DashboardBloc>().add(DashboardLoadServices()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          );
        }
        if (state is DashboardLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(DashboardRefreshServices());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildActiveQueueCard(context, l10n, theme),
                const SizedBox(height: 16),
                _buildWelcomeCard(context, l10n, theme),
                const SizedBox(height: 24),
                Text(l10n.services, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...state.services.map((service) => ServiceCard(
                  service: service,
                  onTap: () {
                    final mode = service.serviceMode.toUpperCase();
                    if (mode == 'ONLINE') {
                      context.push('/request/form/${service.id}', extra: service);
                    } else if (mode == 'APPOINTMENT') {
                      context.push('/appointment/book/${service.id}');
                    } else {
                      context.push('/help-desk/${service.id}');
                    }
                  },
                )),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActiveQueueCard(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<QueueBloc, QueueState>(
      builder: (context, state) {
        if (state is QueueActive) {
          final queue = state.queue;
          final isCalled = queue.status == 'CALLING' || queue.status == 'PROCESSING';
          
          return Card(
            elevation: 8,
            shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            color: isCalled ? Colors.orange : theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isCalled ? 'YOUR TURN!' : 'ACTIVE TICKET',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => context.read<QueueBloc>().add(QueueLoadActive()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    queue.serviceName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Wait', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(queue.estimatedWaitTime ?? '---', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('NUMBER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900)),
                          Text(queue.queueNumber, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      authState.user.fullName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l10n.welcome},', style: theme.textTheme.bodyMedium),
                        Text(
                          authState.user.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        state.user.fullName[0].toUpperCase(),
                        style: theme.textTheme.displayMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(state.user.fullName, style: theme.textTheme.headlineSmall),
                    Text(
                      state.user.phoneNumber ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Profile'),
                onTap: () => context.push('/profile/edit'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text(l10n.logout, style: TextStyle(color: theme.colorScheme.error)),
                onTap: () => _showLogoutDialog(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Colors.white),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
