import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/service.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel {
  final String id;
  final String name;
  final String? nameAm;
  final String description;
  final String? descriptionAm;
  final String sector;
  final String? sectorAm;
  final String serviceMode;
  final String icon;
  final bool isAvailable;
  final List<RequiredDocumentModel> requiredDocuments;
  final String? onlineInstructions;
  final String? onlineInstructionsAm;
  final String? estimatedProcessingTime;

  ServiceModel({
    required this.id,
    required this.name,
    this.nameAm,
    required this.description,
    this.descriptionAm,
    required this.sector,
    this.sectorAm,
    required this.serviceMode,
    required this.icon,
    required this.isAvailable,
    required this.requiredDocuments,
    this.onlineInstructions,
    this.onlineInstructionsAm,
    this.estimatedProcessingTime,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);

  Service toEntity() {
    return Service(
      id: id,
      name: name,
      nameAm: nameAm,
      description: description,
      descriptionAm: descriptionAm,
      sector: sector,
      sectorAm: sectorAm,
      serviceMode: serviceMode,
      icon: icon,
      isAvailable: isAvailable,
      requiredDocuments: requiredDocuments.map((doc) => doc.toEntity()).toList(),
      onlineInstructions: onlineInstructions,
      onlineInstructionsAm: onlineInstructionsAm,
      estimatedProcessingTime: estimatedProcessingTime,
    );
  }
}

@JsonSerializable()
class RequiredDocumentModel {
  final String name;
  final String? nameAm;
  final bool required;

  RequiredDocumentModel({
    required this.name,
    this.nameAm,
    required this.required,
  });

  factory RequiredDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$RequiredDocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$RequiredDocumentModelToJson(this);

  RequiredDocument toEntity() {
    return RequiredDocument(
      name: name,
      nameAm: nameAm,
      required: required,
    );
  }
}

class ServicesResponse {
  final bool success;
  final List<ServiceModel> data;

  ServicesResponse({
    required this.success,
    required this.data,
  });

  factory ServicesResponse.fromJson(dynamic json) {
    if (json is List) {
      return ServicesResponse(
        success: true,
        data: json
            .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (json is Map<String, dynamic>) {
      if (json.containsKey('data') && json['data'] is List) {
        return ServicesResponse(
          success: json['success'] ?? true,
          data: (json['data'] as List)
              .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }
    }
    return ServicesResponse(success: false, data: []);
  }
}
