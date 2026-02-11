import '../../../../../core/network/dio_client.dart';
import '../models/service_model.dart';

class ServiceRemoteDataSource {
  final DioClient _client;

  ServiceRemoteDataSource(this._client);

  Future<List<ServiceModel>> getServices() async {
    final response = await _client.get('/services/sectors');
    // Backend returns array of sectors with nested services
    final List<dynamic> sectors = response.data as List<dynamic>;
    
    // Flatten the structure: extract all services from all sectors
    final List<ServiceModel> allServices = [];
    
    for (var sector in sectors) {
      final sectorMap = sector as Map<String, dynamic>;
      final sectorName = sectorMap['name'] as String;
      final sectorIcon = sectorMap['icon'] as String?;
      final services = sectorMap['services'] as List<dynamic>? ?? [];
      
      for (var service in services) {
        final serviceMap = service as Map<String, dynamic>;
        
        // Create a flattened service model
        final flattenedService = {
          'id': serviceMap['id'],
          'name': serviceMap['name'],
          'nameAm': serviceMap['nameAm'],
          'description': serviceMap['description'] ?? '',
          'descriptionAm': serviceMap['descriptionAm'],
          'sector': sectorName, // Use sector name instead of nested object
          'sectorAm': null,
          'serviceMode': serviceMap['mode'] ?? 'QUEUE',
          'icon': serviceMap['icon'] ?? sectorIcon ?? 'FileText',
          'isAvailable': serviceMap['availability'] != null,
          'requiredDocuments': <Map<String, dynamic>>[], // Empty for now
          'onlineInstructions': null,
          'onlineInstructionsAm': null,
          'estimatedProcessingTime': null,
        };
        
        allServices.add(ServiceModel.fromJson(flattenedService));
      }
    }
    
    return allServices;
  }

  Future<ServiceModel> getServiceById(String serviceId) async {
    final response = await _client.get('/services/$serviceId');
    final data = response.data['data'];
    return ServiceModel.fromJson(data);
  }
}
