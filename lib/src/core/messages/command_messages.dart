import 'message.dart';

/// Command-related messages for CLI operations
///
/// This class contains messages related to command execution, user interaction,
/// and CLI feedback. These messages provide consistent communication patterns
/// across different commands.
///
/// Example usage:
/// ```dart
/// final message = CommandMessages.welcome.format({'command': 'Project'});
/// print(message); // "🚀 Welcome to Gexd Project Creator!"
/// ```
class CommandMessages {
  /// Welcome message for command operations
  /// Parameters: {command}
  static const welcome = Message("🚀 Welcome to Gexd {command} Creator!");

  /// Success message for project creation
  /// Parameters: {projectName}
  static const projectCreated = Message(
    "🎉 Project \"{projectName}\" created successfully!",
  );

  /// Progress message for data collection
  /// Parameters: {type}
  static const collectingData = Message("Collecting {type} data...");

  /// Success message for data collection
  /// Parameters: {type}
  static const dataCollected = Message("{type} data collected successfully");

  /// Generic operation failure message
  /// Parameters: {operation}
  static const operationFailed = Message("Failed to {operation}");

  /// Help tips message
  static const creationTips = Message(
    "💡 Tips for successful project creation:\n"
    "   💡 Example: gexd create my_app --template getx",
  );

  /// Next steps message
  /// Parameters: {projectName}
  static const nextSteps = Message(
    "🚀 Next steps:\n"
    "   cd {projectName}\n"
    "   flutter run",
  );

  /// Project information header
  static const projectInfo = Message("📋 Project information:");

  /// Learn more section
  static const learnMore = Message(
    "📚 Learn more:\n"
    "   • GetX: https://pub.dev/packages/get\n"
    "   • Gexd: https://github.com/altwaireb/gexd",
  );

  /// Field requirements message
  /// Parameters: {field}, {requirements}
  static const fieldRequirements = Message(
    "📝 {field} requirements:\n{requirements}",
  );

  /// Retry prompt message
  /// Parameters: {field}
  static const retryPrompt = Message("💡 Please try again...");

  /// Maximum retry attempts reached
  /// Parameters: {field}
  static const maxRetriesReached = Message(
    "❌ Maximum retry attempts reached for {field}.",
  );

  /// Restart suggestion message
  static const restartSuggestion = Message(
    "💡 Please restart the command and try again.",
  );

  /// Project name detection messages
  /// Parameters: {projectName}
  static const projectNameFromPubspec = Message(
    "📦 Using project name from pubspec.yaml: {projectName}",
  );

  /// Parameters: {projectName}
  static const projectNameFromDirectory = Message(
    "📦 Using directory name as project name: {projectName}",
  );

  /// Parameters: {projectName}
  static const projectNameFallback = Message(
    "Could not read project name, using directory: {projectName}",
  );

  /// Init success message
  /// Parameters: {projectName}
  static const initSuccess = Message(
    "🎉 Project \"{projectName}\" initialized successfully!",
  );

  /// Version message
  /// Parameters: {version}
  static const versionInfo = Message("Gexd {version}");

  /// Update available message
  /// Parameters: {currentVersion}, {latestVersion}
  static const updateAvailable = Message(
    "Update available! {currentVersion} → {latestVersion}",
  );

  /// Update instruction message
  static const updateInstruction = Message("Run `gexd self-update` to update.");

  /// Self-update related messages
  static const selfUpdateStarted = Message("🔄 Starting gexd self-update...");
  static const selfUpdateCompleted = Message(
    "✅ Gexd update completed successfully!",
  );
  static const selfUpdateFailed = Message("❌ Self-update failed: {error}");
  static const projectsUpdated = Message(
    "✅ Updated {count} project configuration(s)",
  );
  static const noProjectsFound = Message(
    "📁 No Gexd projects found in current directory",
  );

  /// Error messages for different exception types
  static const validationFailed = Message("❌ Validation failed: {message}");
  static const initializationError = Message(
    "⚠️ Initialization error: {message}",
  );
  static const projectCreationFailed = Message(
    "🚫 Project creation failed: {message}",
  );
  static const masonError = Message("🔧 Mason error: {message}");
  static const processError = Message("💻 Process error: {message}");
  static const unexpectedError = Message("🔥 Unexpected error: {error}");
}
