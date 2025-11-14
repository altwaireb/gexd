/// Main constants used throughout the application
/// Contains string templates, file suffixes,
/// and prompt messages
/// Private constructor to prevent instantiation
class MainConstants {
  MainConstants._();

  /// Package information
  static const String packageName = 'Gexd';
  static const String packageDocumentation =
      'https://gexd.gitbook.io/gexd-docs';

  /// Maximum allowed depth for a given path
  static const int maxPathDepth = 3;

  /// Prompt message for name input
  static const String nameInput = 'Enter {input} name:';

  /// Prompt message for directory input
  static const String folderDirInput = 'Enter {input} directory:';

  /// Prompt message for 'on' path input
  static const String onPathInput = 'Enter path:';

  /// Confirmation prompt for creating in a subdirectory
  static const String askForOnPathPrompt =
      'Do you want to create in a subdirectory?';

  /// Default prompt message for overwriting existing files
  static const String defaultRoutePrompt =
      'Do you want to add routes automatically?';

  static const String chooseInput = 'Choose {input}:';

  static const String askForOverwriteInput = 'Files already exist. Overwrite?';

  static const String askForModelNameInput =
      'Do you want to add a Model for typed state management?';

  static const String askForHasModelInput =
      'Do you want to enable auto model detection?';

  static const String askForHasInterfaceInput =
      'Do you want to create an interface for the repository?';

  static const String modelInputSourceTypePrompt =
      'Select the model input source type:';

  // File paths
  static const String bindingSingleSuffix = '{name}_binding.dart';
  static const String controllerSingleSuffix = '{name}_controller.dart';
  static const String widgetSingleSuffix = '{name}_widget.dart';
  static const String viewSingleSuffix = '{name}_view.dart';
  static const String interfaceSuffix = '{name}_interface.dart';
  static const String serviceSuffix = '{name}_service.dart';
  static const String utilSuffix = '{name}_utils.dart';
  static const String constantsSuffix = '{name}_constants.dart';
  static const String providerSuffix = '{name}_provider.dart';
  static const String repositorySuffix = '{name}_repository.dart';
  static const String modelSuffix = '{name}.dart';
  static const String modelSuffixEndingModel = '{name}_model.dart';
  static const String middlewareSuffix = '{name}_middleware.dart';
  static const String exceptionSuffix = '{name}_exception.dart';
  // for screen files
  static const String controllerSuffix = 'controllers/{name}_controller.dart';
  static const String viewSuffix = 'views/{name}_view.dart';
  static const String bindingSuffix = 'bindings/{name}_binding.dart';

  // Progress messages
  static const String generatingFiles = 'Generating {name} files...';
  static const String generatingFile = 'Generating {name} file...';

  static const String generatedFilesSuccess =
      'Generated {name} files successful';
  static const String generatedFileSuccess = 'Generated {name} file successful';

  static const String generationFilesFailed = 'Failed to generate {name} files';

  static const String generationFileFailed = 'Failed to generate {name} file';

  // Route update messages
  static const String updatingRoutes = 'Updating routes automatically...';
  static const String routesUpdatedSuccess =
      'Routes updated in app_pages.dart automatically!';

  static const String routeUpdateFailed =
      'Route update failed - add routes manually';
}

/// Extension for string interpolation in constants
extension MainConstantsFormatter on String {
  String formatWith(Map<String, String> params) {
    String result = this;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
