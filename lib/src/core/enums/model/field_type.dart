/// Supported field types for custom model generation
enum FieldType {
  string(
    key: 'String',
    displayName: 'String',
    description: 'Text data type',
    dartType: 'String',
    jsonExample: '"example text"',
  ),
  integer(
    key: 'int',
    displayName: 'Integer',
    description: 'Whole number',
    dartType: 'int',
    jsonExample: '42',
  ),
  double(
    key: 'double',
    displayName: 'Double',
    description: 'Decimal number',
    dartType: 'double',
    jsonExample: '3.14',
  ),
  boolean(
    key: 'bool',
    displayName: 'Boolean',
    description: 'True/false value',
    dartType: 'bool',
    jsonExample: 'true',
  ),
  dateTime(
    key: 'DateTime',
    displayName: 'DateTime',
    description: 'Date and time',
    dartType: 'DateTime',
    jsonExample: '"2024-01-01T00:00:00.000Z"',
  ),
  list(
    key: 'List',
    displayName: 'List',
    description: 'Array/List of items',
    dartType: 'List<dynamic>',
    jsonExample: '["item1", "item2"]',
  ),
  map(
    key: 'Map',
    displayName: 'Map/Object',
    description: 'Key-value object',
    dartType: 'Map<String, dynamic>',
    jsonExample: '{"key": "value"}',
  ),
  stringNullable(
    key: 'String?',
    displayName: 'String (Optional)',
    description: 'Optional text data',
    dartType: 'String?',
    jsonExample: '"optional text"',
  ),
  intNullable(
    key: 'int?',
    displayName: 'Integer (Optional)',
    description: 'Optional whole number',
    dartType: 'int?',
    jsonExample: '42',
  ),
  doubleNullable(
    key: 'double?',
    displayName: 'Double (Optional)',
    description: 'Optional decimal number',
    dartType: 'double?',
    jsonExample: '3.14',
  ),
  boolNullable(
    key: 'bool?',
    displayName: 'Boolean (Optional)',
    description: 'Optional true/false value',
    dartType: 'bool?',
    jsonExample: 'true',
  );

  const FieldType({
    required this.key,
    required this.displayName,
    required this.description,
    required this.dartType,
    required this.jsonExample,
  });

  final String key;
  final String displayName;
  final String description;
  final String dartType;
  final String jsonExample;

  bool get isNullable => key.endsWith('?');
  bool get isRequired => !isNullable;

  /// Get field type by key
  static FieldType? fromKey(String key) {
    try {
      return FieldType.values.firstWhere((type) => type.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Get all required types
  static List<FieldType> get requiredTypes =>
      FieldType.values.where((type) => type.isRequired).toList();

  /// Get all nullable types
  static List<FieldType> get nullableTypes =>
      FieldType.values.where((type) => type.isNullable).toList();
}
