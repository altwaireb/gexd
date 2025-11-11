/// Interface for MasonService
/// Defines methods for generating files
/// from Mason bricks and package bricks
abstract class PromptServiceInterface {
  /// inputs a string from the user
  /// [prompt] is the message to display to the user
  /// [defaultValue] is the value to use if the user inputs nothing
  /// [validator] is a function that takes the user input and returns
  ///   null if the input is valid, or a string error message if the input is invalid
  Future<String> input(
    String prompt, {
    String? defaultValue,
    String? Function(String value)? validator,
  });

  /// confirms a yes/no question from the user
  /// [prompt] is the message to display to the user
  /// [defaultValue] is the value to use if the user inputs nothing (Defaults to false)
  Future<bool> confirm(String prompt, {bool defaultValue = false});

  /// selects a single option from a list
  /// [prompt] is the message to display to the user
  /// [options] is the list of options to choose from
  /// [initialIndex] is the index of the option to select by default (optional)
  Future<int> select(String prompt, List<String> options, {int? initialIndex});

  /// selects multiple options from a list
  /// [prompt] is the message to display to the user
  /// [options] is the list of options to choose from
  /// [defaults] is a list of booleans indicating which options are selected by default
  Future<List<int>> multiSelect(
    String prompt,
    List<String> options, {
    List<bool>? defaults,
  });
}
