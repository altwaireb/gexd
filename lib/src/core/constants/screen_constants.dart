/// Constants and messages for screen generation
class ScreenConstants {
  ScreenConstants._();

  // Configuration constants
  static const int maxPathDepth = 3;
  static const String askForOnPathPrompt =
      'Do you want to create in a subdirectory?';
  static const String defaultRoutePrompt =
      'Do you want to add routes automatically?';
  static const String onPathPrompt =
      'Enter path (max 3 levels, e.g., auth/user):';
  static const String screenNamePrompt =
      'Enter screen name (e.g., Login, Profile):';
  static const String screenTypePrompt = 'Choose screen type:';
  static const String defaultOverwritePrompt =
      'Files already exist. Overwrite?';

  static const String askForModelNamePrompt =
      'Do you want to add a Model for typed state management?';

  static const String askForHasModelPrompt =
      'Do you want to enable auto model detection?';

  static const String modelNamePrompt =
      'Enter model name (e.g., User, Product):';

  // Success messages
  static const String generatorTitle = '🎯 Screen Generator';
  static const String dataCollectedSuccess =
      'Screen data collected successfully';
  static const String filesGeneratedSuccess =
      'Screen files generated successfully';
  static const String routesUpdatedSuccess =
      'Routes updated in app_pages.dart automatically!';
  static const String detectedTemplate = '🎯 Detected template:';
  static const String forceMode =
      '🔥 Force mode: Overwriting existing files...';

  // Error messages
  static const String notInProject = '❌ Not in a SolidX project directory';
  static const String templateNotDetected =
      '❌ Could not detect project template';
  static const String dataCollectionFailed = '❌ Failed to collect screen data';
  static const String generationFailed = '❌ Failed to generate screen files';
  static const String generationCancelled = '❌ Generation cancelled by user';
  static const String validationError = '❌ Validation Error:';
  static const String unexpectedError = '❌ Error:';

  // Warning messages
  static const String existingFilesFound = '⚠️  Existing files found:';
  static const String routeUpdateFailed =
      '⚠️  Route update failed - add routes manually';

  // Model validation messages
  static const String modelNotFound = '❌ Model "{modelName}" not found';
  static const String modelCreateSuggestion =
      '💡 Create the model first: solidx make model {modelName}';

  // Info messages
  static const String projectDirectoryHelp =
      '💡 Make sure you are in a directory that contains .solidx/config.yaml';
  static const String createProjectHelp =
      '💡 Create a new project with: solidx create <project_name>';
  static const String generatedFiles = '📁 Generated files:';
  static const String nextSteps = '🔗 Next steps:';
  static const String location = '📁 Location:';

  // Progress messages
  static const String collectingData = 'Collecting screen data...';
  static const String generatingFiles = 'Generating screen files...';
  static const String updatingRoutes = 'Updating routes automatically...';

  // Next steps messages - Enhanced
  static const String nextStepsHeader =
      '🚀 Next steps to complete integration:';

  // Route handling steps
  static const String routesAutoCompleted =
      '   ✅ Routes configured automatically in app_pages.dart';
  static const String routesManualRequired =
      '   📝 Add routes manually to app_pages.dart (auto-generation was skipped)';

  // Integration steps by screen type
  static const String integrationStepBasic =
      '   🎯 Navigation: Get.toNamed(Routes.{SCREEN_ROUTE}) or Get.to(() => {screenName}View())';
  static const String integrationStepForm =
      '   📋 Form Setup: Configure validation rules and submission logic in the controller';
  static const String integrationStepState =
      '   ⚡ State Management: Use controller.obx() in view for automatic loading/error states';

  // Customization steps
  static const String customizeLogic =
      '   🔧 Customize controller logic based on your requirements';
  static const String updateImportsSubPath =
      '   📦 Update imports in existing files to use the new subdirectory structure';

  // Documentation links
  static const String learnMore =
      '   📚 Learn more: https://pub.dev/packages/get#route-management';

  // Quick start examples
  static const String quickStartBasic =
      '   💡 Quick Start: Add ElevatedButton(onPressed: () => Get.toNamed(Routes.{SCREEN_ROUTE}), ...)';
  static const String quickStartForm =
      '   💡 Quick Start: Use GlobalKey<FormState> and controller validation methods';
  static const String quickStartState =
      '   💡 Quick Start: Wrap UI with controller.obx() for reactive state management';

  // File paths
  static const String controllerSuffix = 'controllers/{name}_controller.dart';
  static const String viewSuffix = 'views/{name}_view.dart';
  static const String bindingSuffix = 'bindings/{name}_binding.dart';
}

/// Extension for string interpolation in constants
extension ScreenMessageFormatter on String {
  String formatWith(Map<String, String> params) {
    String result = this;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
