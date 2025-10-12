import 'package:gexd/src/services/interfaces/prompt_service_interface.dart';

/// Mock implementation of PromptServiceInterface for testing
class PromptServiceMock implements PromptServiceInterface {
  final List<String> inputs;
  final List<bool> confirmations;
  final List<int> selections;

  int _inputIndex = 0;
  int _confirmIndex = 0;
  int _selectIndex = 0;

  PromptServiceMock({
    this.inputs = const [],
    this.confirmations = const [],
    this.selections = const [],
  });

  @override
  Future<String> input(
    String prompt, {
    String? defaultValue,
    String? Function(String)? validator,
  }) async {
    final value = _inputIndex < inputs.length
        ? inputs[_inputIndex++]
        : (defaultValue ?? '');

    if (validator != null) {
      final error = validator(value);
      if (error != null) throw Exception(error);
    }

    return value;
  }

  @override
  Future<bool> confirm(String prompt, {bool defaultValue = false}) async {
    return _confirmIndex < confirmations.length
        ? confirmations[_confirmIndex++]
        : defaultValue;
  }

  @override
  Future<int> select(
    String prompt,
    List<String> options, {
    int? initialIndex,
  }) async {
    return _selectIndex < selections.length
        ? selections[_selectIndex++]
        : (initialIndex ?? 0);
  }

  @override
  Future<List<int>> multiSelect(
    String prompt,
    List<String> options, {
    List<bool>? defaults,
  }) async {
    return []; // Return empty list for simplicity
  }
}
