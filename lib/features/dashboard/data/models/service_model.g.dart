// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAm: json['nameAm'] as String?,
      description: json['description'] as String,
      descriptionAm: json['descriptionAm'] as String?,
      sector: json['sector'] as String,
      sectorAm: json['sectorAm'] as String?,
      serviceMode: json['serviceMode'] as String,
      icon: json['icon'] as String,
      isAvailable: json['isAvailable'] as bool,
      requiredDocuments: (json['requiredDocuments'] as List<dynamic>)
          .map((e) => RequiredDocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      onlineInstructions: json['onlineInstructions'] as String?,
      onlineInstructionsAm: json['onlineInstructionsAm'] as String?,
      estimatedProcessingTime: json['estimatedProcessingTime'] as String?,
    );

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameAm': instance.nameAm,
      'description': instance.description,
      'descriptionAm': instance.descriptionAm,
      'sector': instance.sector,
      'sectorAm': instance.sectorAm,
      'serviceMode': instance.serviceMode,
      'icon': instance.icon,
      'isAvailable': instance.isAvailable,
      'requiredDocuments': instance.requiredDocuments,
      'onlineInstructions': instance.onlineInstructions,
      'onlineInstructionsAm': instance.onlineInstructionsAm,
      'estimatedProcessingTime': instance.estimatedProcessingTime,
    };

RequiredDocumentModel _$RequiredDocumentModelFromJson(
        Map<String, dynamic> json) =>
    RequiredDocumentModel(
      name: json['name'] as String,
      nameAm: json['nameAm'] as String?,
      required: json['required'] as bool,
    );

Map<String, dynamic> _$RequiredDocumentModelToJson(
        RequiredDocumentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameAm': instance.nameAm,
      'required': instance.required,
    };
