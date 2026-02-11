import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String? nameAm;
  final String description;
  final String? descriptionAm;
  final String sector;
  final String? sectorAm;
  final String serviceMode; // ONLINE, QUEUE, APPOINTMENT
  final String icon;
  final bool isAvailable;
  final List<RequiredDocument> requiredDocuments;
  final String? onlineInstructions;
  final String? onlineInstructionsAm;
  final String? estimatedProcessingTime;

  const Service({
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

  @override
  List<Object?> get props => [
        id,
        name,
        nameAm,
        description,
        descriptionAm,
        sector,
        sectorAm,
        serviceMode,
        icon,
        isAvailable,
        requiredDocuments,
        onlineInstructions,
        onlineInstructionsAm,
        estimatedProcessingTime,
      ];
}

class RequiredDocument extends Equatable {
  final String name;
  final String? nameAm;
  final bool required;

  const RequiredDocument({
    required this.name,
    this.nameAm,
    required this.required,
  });

  @override
  List<Object?> get props => [name, nameAm, required];
}
