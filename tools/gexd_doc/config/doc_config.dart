/// Configuration settings for the documentation generator
///
/// This class centralizes all configuration options and paths
/// used throughout the documentation generation process.
class DocConfig {
  /// Current version of the documentation generator
  static const String version = '1.0.0';

  /// Base directory for generated documentation
  static const String outputDir = 'doc';

  /// Path to command files in the project
  static const String commandsPath = 'lib/src/commands';

  /// Mapping of enum types to their file paths
  ///
  /// This map provides direct paths to enum definitions used in commands.
  /// Add new enum types here as they are created in the project.
  static const Map<String, String> enumPaths = {
    'BindingLocation': 'lib/src/core/enums/binding_location.dart',
    'ScreenType': 'lib/src/core/enums/screen_type.dart',
    'ProjectTemplate': 'lib/src/core/enums/project_template.dart',
    'NameComponent': 'lib/src/core/enums/name_component.dart',
  };

  /// Fallback directories to search for enum files
  ///
  /// When an enum is not found in the direct mapping above,
  /// these directories are searched automatically.
  static const List<String> possibleEnumPaths = [
    'lib/src/core/enums',
    'lib/src/models',
  ];

  /// Template settings for generated documentation
  static const Map<String, String> templates = {
    'commandTitle': '# `{name}` Command',
    'classReference': '**Class:** `{className}`',
    'descriptionHeader': '## 📝 Description',
    'aliasesHeader': '## 🧩 Aliases',
    'optionsHeader': '## ⚙️ Options',
    'flagsHeader': '## 🚩 Flags',
  };

  // =============================================================================
  // DISPLAY CONTROL SETTINGS
  // =============================================================================

  /// Quick toggles for major sections
  /// These provide coarse-grained control over entire sections
  static const bool includeHeader = true;
  static const bool includeContent = true;
  static const bool includeFooter = true;

  /// Detailed header controls
  /// Fine-grained control over header elements
  static const bool showClassName = false;
  static const bool showDescription = true;

  /// Detailed content controls
  /// Fine-grained control over main content sections
  static const bool showUsage = true;
  static const bool showDetailedUsage =
      true; // Show detailed usage from command.usage
  static const bool showAliases = true;
  static const bool showOptions = true;
  static const bool showFlags = true;

  /// Option formatting controls
  /// Controls how options are displayed in detail
  static const bool showOptionAbbr = true;
  static const bool showOptionDefaults = true;
  static const bool showEnumDetails = true;
  static const bool showMultiOptionType = true;

  /// Flag formatting controls
  /// Controls how flags are displayed in detail
  static const bool showFlagAbbr = true;
  static const bool showFlagDefaults = true;

  /// Footer controls
  /// Controls footer content and formatting
  static const bool showGeneratorCredit = true;
}
