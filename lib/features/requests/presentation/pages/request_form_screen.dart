import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_localizations.dart';
import 'package:digital_service_app/features/dashboard/domain/entities/service.dart';
import 'package:digital_service_app/features/requests/presentation/bloc/request_bloc.dart';

class RequestFormScreen extends StatefulWidget {
  final Service service;

  const RequestFormScreen({super.key, required this.service});

  @override
  State<RequestFormScreen> createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      context.read<RequestBloc>().add(
        RequestSubmitRequested(
          serviceId: widget.service.id,
          data: _formData,
          remarks: _remarksController.text.trim().isEmpty ? null : _remarksController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Mocking some fields based on service name if needed, 
    // but for now a generic "Description" or "Purpose" field.
    final List<String> fields = ['Description', 'Purpose', 'Additional Requirements'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name),
      ),
      body: BlocListener<RequestBloc, RequestState>(
        listener: (context, state) {
          if (state is RequestSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.pop();
          } else if (state is RequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: theme.colorScheme.error),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Request for ${widget.service.name}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.service.description,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                ...fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: field,
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: field.contains('Description') || field.contains('Requirements') ? 3 : 1,
                      onSaved: (value) => _formData[field.toLowerCase().replaceAll(' ', '_')] = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      },
                    ),
                  );
                }),
                
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  decoration: const InputDecoration(
                    labelText: 'Remarks (Optional)',
                    border: OutlineInputBorder(),
                    helperText: 'Any additional notes for the officer',
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<RequestBloc, RequestState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is RequestLoading ? null : _submit,
                        child: state is RequestLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Request'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
