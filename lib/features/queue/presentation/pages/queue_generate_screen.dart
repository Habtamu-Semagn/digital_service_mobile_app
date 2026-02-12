import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_localizations.dart';
import '../bloc/queue_bloc.dart';

class QueueGenerateScreen extends StatefulWidget {
  final String serviceId;

  const QueueGenerateScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<QueueGenerateScreen> createState() => _QueueGenerateScreenState();
}

class _QueueGenerateScreenState extends State<QueueGenerateScreen> {
  @override
  void initState() {
    super.initState();
    final queueState = context.read<QueueBloc>().state;
    // Only generate if we don't have any active ticket at all
    if (queueState is! QueueActive && queueState is! QueueGenerated) {
      context.read<QueueBloc>().add(QueueGenerate(serviceId: widget.serviceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.queueNumber),
      ),
      body: BlocConsumer<QueueBloc, QueueState>(
        listener: (context, state) {
          if (state is QueueError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is QueueGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.queueGenerated),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QueueLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QueueGenerated || state is QueueActive) {
            final queue = state is QueueGenerated
                ? state.queue
                : (state as QueueActive).queue;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Queue Ticket Card
                  Card(
                    elevation: 4,
                    color: AppTheme.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            l10n.yourQueueNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            queue.queueNumber,
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 64,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getLocalizedServiceName(context, queue),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Card
                  _buildStatusCard(context, queue, theme, l10n),
                  const SizedBox(height: 16),

                  // Position Card
                  _buildInfoCard(
                    context,
                    Icons.people_outline,
                    l10n.position,
                    '${queue.position ?? 0}',
                    theme,
                  ),
                  const SizedBox(height: 16),

                  // Estimated Wait Time Card
                  _buildInfoCard(
                    context,
                    Icons.access_time,
                    l10n.estimatedWait,
                    queue.estimatedWaitTime ?? '---',
                    theme,
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Card(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.infoColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Please wait for your number to be called. You will be notified when it\'s your turn.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Back to Dashboard Button
                  OutlinedButton.icon(
                    onPressed: () => context.go('/dashboard'),
                    icon: const Icon(Icons.dashboard),
                    label: Text(l10n.dashboard),
                  ),
                ],
              ),
            );
          }

          if (state is QueueError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.close),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    queue,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final statusColor = AppTheme.getStatusColor(queue.status);
    final statusIcon = AppTheme.getStatusIcon(queue.status);

    return Card(
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.queueStatus,
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    _getStatusText(queue.status, l10n),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedServiceName(BuildContext context, queue) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == AppConstants.languageAmharic &&
        queue.serviceNameAm != null) {
      return queue.serviceNameAm!;
    }
    return queue.serviceName;
  }

  String _getStatusText(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'WAITING':
        return l10n.waiting;
      case 'CALLING':
        return l10n.called;
      case 'PROCESSING':
        return l10n.inService;
      case 'COMPLETED':
        return l10n.completed;
      case 'CANCELLED':
        return l10n.cancelled;
      default:
        return status;
    }
  }
}
