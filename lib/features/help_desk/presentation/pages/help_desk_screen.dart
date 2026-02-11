import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_localizations.dart';
import '../../../dashboard/domain/entities/service.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';

class HelpDeskScreen extends StatelessWidget {
  final String serviceId;

  const HelpDeskScreen({
    super.key,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpDesk),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            final service = state.services.firstWhere(
              (s) => s.id == serviceId,
              orElse: () => state.services.first,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Service Header
                  _buildServiceHeader(context, service, theme),
                  const SizedBox(height: 24),

                  // Service Description
                  _buildSection(
                    context,
                    l10n.serviceDetails,
                    _getLocalizedDescription(context, service),
                    theme,
                  ),
                  const SizedBox(height: 16),

                  // Required Documents
                  if (service.requiredDocuments.isNotEmpty) ...[
                    _buildDocumentsSection(context, service, theme, l10n),
                    const SizedBox(height: 16),
                  ],

                  // Online Instructions (if ONLINE mode)
                  if (service.serviceMode == AppConstants.serviceModeOnline &&
                      service.onlineInstructions != null) ...[
                    _buildSection(
                      context,
                      'Online Instructions',
                      _getLocalizedInstructions(context, service),
                      theme,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Estimated Processing Time
                  if (service.estimatedProcessingTime != null) ...[
                    _buildInfoCard(
                      context,
                      Icons.access_time,
                      l10n.estimatedTime,
                      service.estimatedProcessingTime!,
                      theme,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Button (Service Mode Enforcement)
                  _buildActionButton(context, service, l10n, theme),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildServiceHeader(
    BuildContext context,
    Service service,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppTheme.getServiceModeIcon(service.serviceMode),
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedName(context, service),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getLocalizedSector(context, service),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(
    BuildContext context,
    Service service,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.requiredDocuments,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: service.requiredDocuments.map((doc) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        doc.required
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: doc.required
                            ? AppTheme.successColor
                            : AppTheme.infoColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getLocalizedDocumentName(context, doc),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      if (doc.required)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Required',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Column(
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    Service service,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // CRITICAL: Service Mode Enforcement
    // Only show the action button that matches the service mode
    switch (service.serviceMode.toUpperCase()) {
      case AppConstants.serviceModeOnline:
        return ElevatedButton.icon(
          onPressed: () {
            context.push('/request/form/${service.id}', extra: service);
          },
          icon: const Icon(Icons.language),
          label: Text(l10n.proceedOnline),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      case AppConstants.serviceModeQueue:
        return ElevatedButton.icon(
          onPressed: () {
            context.push('/queue/generate/${service.id}');
          },
          icon: const Icon(Icons.confirmation_number),
          label: Text(l10n.takeQueueNumber),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      case AppConstants.serviceModeAppointment:
        return ElevatedButton.icon(
          onPressed: () {
            context.push('/appointment/book/${service.id}');
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(l10n.bookAppointment),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  String _getLocalizedName(BuildContext context, Service service) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == AppConstants.languageAmharic &&
        service.nameAm != null) {
      return service.nameAm!;
    }
    return service.name;
  }

  String _getLocalizedSector(BuildContext context, Service service) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == AppConstants.languageAmharic &&
        service.sectorAm != null) {
      return service.sectorAm!;
    }
    return service.sector;
  }

  String _getLocalizedDescription(BuildContext context, Service service) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == AppConstants.languageAmharic &&
        service.descriptionAm != null) {
      return service.descriptionAm!;
    }
    return service.description;
  }

  String _getLocalizedInstructions(BuildContext context, Service service) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == AppConstants.languageAmharic &&
        service.onlineInstructionsAm != null) {
      return service.onlineInstructionsAm!;
    }
    return service.onlineInstructions ?? '';
  }

  String _getLocalizedDocumentName(
    BuildContext context,
    RequiredDocument doc,
  ) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == AppConstants.languageAmharic &&
        doc.nameAm != null) {
      return doc.nameAm!;
    }
    return doc.name;
  }
}
