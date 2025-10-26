import '../core/enums/model/field_type.dart';

/// Represents a custom field defined by user input
class CustomField {
  final String name;
  final FieldType type;
  final String? description;
  final dynamic defaultValue;
  final bool isRequired;

  CustomField({
    required this.name,
    required this.type,
    this.description,
    this.defaultValue,
    bool? isRequired,
  }) : isRequired = isRequired ?? !type.isNullable;

  /// Create field from user input
  factory CustomField.fromInput({
    required String name,
    required FieldType type,
    String? description,
    dynamic defaultValue,
  }) {
    return CustomField(
      name: name,
      type: type,
      description: description,
      defaultValue: defaultValue,
    );
  }

  /// Convert to JSON format for model generation
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.dartType,
      'jsonType': type.jsonExample,
      'required': isRequired,
      'nullable': type.isNullable,
      'defaultValue': defaultValue,
    };
  }

  /// Generate the JSON example value for this field
  dynamic get jsonValue {
    if (defaultValue != null) return defaultValue;

    switch (type) {
      case FieldType.string:
      case FieldType.stringNullable:
        return name.toLowerCase().replaceAll(' ', '_');
      case FieldType.integer:
      case FieldType.intNullable:
        return 1;
      case FieldType.double:
      case FieldType.doubleNullable:
        return 1.0;
      case FieldType.boolean:
      case FieldType.boolNullable:
        return true;
      case FieldType.dateTime:
        return DateTime.now().toIso8601String();
      case FieldType.list:
        return [];
      case FieldType.map:
        return <String, dynamic>{};
    }
  }

  @override
  String toString() =>
      '$name: ${type.displayName}${isRequired ? ' (required)' : ' (optional)'}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomField &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ type.hashCode;
}
