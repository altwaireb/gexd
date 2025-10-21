/// Utility class containing regex patterns for parsing Dart command files
///
/// This class centralizes all regular expressions used to extract
/// metadata from command class definitions.
class RegexUtils {
  /// Pattern to match class declarations extending Command
  /// Matches: class CreateCommand extends `Command<int>`
  static final RegExp className = RegExp(r'class\s+(\w+)\s+extends\s+Command');

  /// Pattern to match name getter with single quotes
  /// Matches: String get name => 'create';
  static final RegExp nameGetterSingle = RegExp(
    r"String\s+get\s+name\s*=>\s*'([^']+)'",
  );

  /// Pattern to match name getter with double quotes
  /// Matches: String get name => "create";
  static final RegExp nameGetterDouble = RegExp(
    r'String\s+get\s+name\s*=>\s*"([^"]+)"',
  );

  /// Pattern to match simple description getter (single line)
  /// Matches: String get description => 'Create a new project';
  static final RegExp descriptionSimple = RegExp(
    r"String\s+get\s+description\s*=>\s*'([^']+)'",
  );

  /// Pattern to match multi-line description getter start
  /// Matches: String get description =>
  static final RegExp descriptionStart = RegExp(
    r'String\s+get\s+description\s*=>',
  );

  /// Pattern to match aliases getter
  /// Matches: `List<String>` get aliases => ['c', 'cr'];
  static final RegExp aliasGetter = RegExp(
    r"List<String>\s*get\s+aliases\s*=>\s*\[([^\]]*)\]",
  );

  /// Pattern to match addOption calls
  /// Matches: addOption('template', ...)
  static final RegExp addOption = RegExp(r"addOption\s*\(\s*'([^']+)'");

  /// Pattern to match addFlag calls
  /// Matches: addFlag('verbose', ...)
  static final RegExp addFlag = RegExp(r"addFlag\s*\(\s*'([^']+)'");

  /// Pattern to extract quoted strings from text
  /// Matches: 'text' or "text"
  static final RegExp quotedString = RegExp(r'''['"]([^'"]+)['"]''');

  /// Pattern to match method calls ending with semicolon
  /// Used to find the end of getter methods
  static final RegExp methodEnd = RegExp(r';');
}
