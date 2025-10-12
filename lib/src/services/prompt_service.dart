import 'package:interact/interact.dart';
import 'interfaces/prompt_service_interface.dart';

class PromptService implements PromptServiceInterface {
  @override
  /// Prompts the user for input with validation
  Future<String> input(
    String prompt, {
    String? defaultValue,
    String? Function(String)? validator,
  }) async {
    final inputPrompt = Input(
      prompt: prompt,
      defaultValue: defaultValue,
      validator: validator != null ? (value) => validator(value) != null : null,
    );
    return inputPrompt.interact();
  }

  /// Confirms a yes/no question from the user
  @override
  Future<bool> confirm(String prompt, {bool defaultValue = false}) async {
    final confirmPrompt = Confirm(prompt: prompt, defaultValue: defaultValue);
    return confirmPrompt.interact();
  }

  /// Selects a single option from a list
  @override
  Future<int> select(
    String prompt,
    List<String> options, {
    int? initialIndex,
  }) async {
    final selectPrompt = Select(
      prompt: prompt,
      options: options,
      initialIndex: initialIndex ?? 0,
    );
    return selectPrompt.interact();
  }

  /// Selects multiple options from a list
  /// [defaults] is a list of booleans indicating which options are selected by default
  @override
  Future<List<int>> multiSelect(
    String prompt,
    List<String> options, {
    List<bool>? defaults,
  }) async {
    final multiSelectPrompt = MultiSelect(
      prompt: prompt,
      options: options,
      defaults: defaults,
    );
    return multiSelectPrompt.interact();
  }
}
