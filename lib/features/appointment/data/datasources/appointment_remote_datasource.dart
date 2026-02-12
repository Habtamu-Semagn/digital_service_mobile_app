import 'package:logger/logger.dart';
import '../../../../../core/network/dio_client.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDataSource {
  final DioClient _client;

  AppointmentRemoteDataSource(this._client);

  Future<List<TimeSlotModel>> getAvailableSlots(
    String serviceId,
    String date,
  ) async {
    final response = await _client.get(
      '/appointments/slots',
      queryParameters: {
        'serviceId': serviceId,
        'date': date,
      },
    );
    final slotsResponse = TimeSlotsResponse.fromJson(response.data);
    return slotsResponse.data;
  }

  Future<AppointmentModel> bookAppointment(
    String serviceId,
    String date,
    String timeSlot,
  ) async {
    final response = await _client.post(
      '/appointments',
      data: {
        'serviceId': serviceId,
        'date': date,
        'timeSlot': timeSlot,
      },
    );
    // Backend returns unwrapped Appointment object
    try {
      return AppointmentResponse.fromJson(response.data).data;
    } catch (e) {
      Logger().e('Failed to parse appointment response. Data: ${response.data}', error: e);
      rethrow;
    }
  }

  Future<List<AppointmentModel>> getMyAppointments() async {
    final response = await _client.get('/appointments/my');
    
    List<dynamic> list;
    if (response.data is List) {
      list = response.data;
    } else if (response.data is Map && response.data.containsKey('data')) {
      list = response.data['data'];
    } else {
      Logger().e('Unexpected response format for my appointments: ${response.data}');
      return [];
    }

    return list.map((json) => AppointmentModel.fromJson(json)).toList();
  }

  Future<List<AppointmentModel>> getSectorAppointments(String sectorId) async {
    final response = await _client.get('/appointments/sector/$sectorId');
    final dynamic data = response.data;
    List<dynamic> list = [];
    
    if (data is List) {
      list = data;
    } else if (data is Map && data.containsKey('data') && data['data'] is List) {
      list = data['data'];
    }
    
    return list.map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _client.delete('/appointments/$appointmentId');
  }
}
