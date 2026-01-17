// lib/models/checkpoint_model.dart
class Checkpoint {
  final String checkpointId;
  final String name;
  final String description;
  final CheckpointType type;
  final String? unit;
  final double? minValue;
  final double? maxValue;
  final bool isRequired;
  final List<String> applicableCategories;

  Checkpoint({
    required this.checkpointId,
    required this.name,
    required this.description,
    required this.type,
    this.unit,
    this.minValue,
    this.maxValue,
    this.isRequired = true,
    this.applicableCategories = const [],
  });

  factory Checkpoint.fromMap(Map<String, dynamic> map) {
    CheckpointType type;
    switch (map['type']) {
      case 'boolean':
        type = CheckpointType.boolean;
        break;
      case 'number':
        type = CheckpointType.number;
        break;
      case 'text':
        type = CheckpointType.text;
        break;
      default:
        type = CheckpointType.boolean;
    }

    return Checkpoint(
      checkpointId: map['checkpointId'],
      name: map['name'],
      description: map['description'] ?? '',
      type: type,
      unit: map['unit'],
      minValue: map['minValue']?.toDouble(),
      maxValue: map['maxValue']?.toDouble(),
      isRequired: map['isRequired'] ?? true,
      applicableCategories: List<String>.from(map['applicableCategories'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    String typeString;
    switch (type) {
      case CheckpointType.boolean:
        typeString = 'boolean';
        break;
      case CheckpointType.number:
        typeString = 'number';
        break;
      case CheckpointType.text:
        typeString = 'text';
        break;
    }

    return {
      'checkpointId': checkpointId,
      'name': name,
      'description': description,
      'type': typeString,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
      'isRequired': isRequired,
      'applicableCategories': applicableCategories,
    };
  }

  bool isApplicableToCategory(String category) {
    return applicableCategories.contains(category);
  }

  @override
  String toString() {
    return 'Checkpoint(name: $name, type: $type, required: $isRequired)';
  }
}

enum CheckpointType { boolean, number, text }