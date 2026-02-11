import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:digital_service_app/features/appointment/presentation/bloc/appointment_bloc.dart';
import 'package:digital_service_app/features/requests/presentation/bloc/request_bloc.dart';
import 'package:digital_service_app/features/requests/domain/entities/request.dart';
import 'package:digital_service_app/core/utils/app_localizations.dart';
import 'package:digital_service_app/features/appointment/domain/entities/appointment.dart';

class MyRequestsTab extends StatefulWidget {
  const MyRequestsTab({super.key});

  @override
  State<MyRequestsTab> createState() => _MyRequestsTabState();
}

class _MyRequestsTabState extends State<MyRequestsTab> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(AppointmentLoadMy());
    context.read<RequestBloc>().add(RequestLoadMy());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppointmentBloc>().add(AppointmentLoadMy());
        context.read<RequestBloc>().add(RequestLoadMy());
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<RequestBloc, RequestState>(
            listener: (context, state) {
              if (state is RequestError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, appointmentState) {
            return BlocBuilder<RequestBloc, RequestState>(
              builder: (context, requestState) {
                if (appointmentState is AppointmentLoading || requestState is RequestLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<dynamic> combinedList = [];
                if (appointmentState is AppointmentListLoaded) {
                  combinedList.addAll(appointmentState.appointments);
                }
                if (requestState is RequestLoaded) {
                  combinedList.addAll(requestState.requests);
                }

                // Sort by date descending
                combinedList.sort((a, b) {
                  DateTime dateA = a is Request ? a.createdAt : a.appointmentDate;
                  DateTime dateB = b is Request ? b.createdAt : b.appointmentDate;
                  return dateB.compareTo(dateA);
                });

                if (combinedList.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(l10n.noData ?? 'No requests found'),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    final item = combinedList[index];
                    if (item is Request) {
                      return _buildRequestCard(context, item, theme);
                    } else {
                      return _buildAppointmentCard(context, item, theme);
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, dynamic appointment, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.serviceName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusBadge(theme, appointment.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Appointment: ${DateFormat.yMMMd().format(appointment.appointmentDate)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(appointment.timeSlot),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, dynamic request, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.serviceName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusBadge(theme, request.status),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.online_prediction, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Online Request: ${DateFormat.yMMMd().format(request.createdAt)}'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${request.type}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    switch (status) {
      case 'SCHEDULED':
      case 'PENDING':
        color = theme.colorScheme.primary;
        break;
      case 'COMPLETED':
        color = Colors.green;
        break;
      case 'CANCELLED':
      case 'REJECTED':
        color = theme.colorScheme.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentBloc>().add(AppointmentCancel(appointmentId: appointmentId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
