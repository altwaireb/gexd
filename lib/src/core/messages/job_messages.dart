import 'message.dart';

/// Background job execution messages
///
/// This class contains messages related to background job operations,
/// including project creation, dependency installation, and template generation.
///
/// Example usage:
/// ```dart
/// final message = JobMessages.projectCreationStarted.format({'projectName': 'my_app'});
/// print(message); // "Starting project creation for my_app..."
/// ```
class JobMessages {
  /// Project creation started message
  /// Parameters: {projectName}
  static const projectCreationStarted = Message(
    "Starting project creation for {projectName}...",
  );

  /// Template generation success message
  static const templateGenerated = Message(
    "Template files generated successfully",
  );

  /// Dependencies installation progress message
  static const dependenciesInstalling = Message("Installing dependencies...");

  /// Dependencies installation success message
  static const dependenciesInstalled = Message(
    "Dependencies installed successfully",
  );

  /// Project creation completion message
  /// Parameters: {duration}
  static const creationCompleted = Message(
    "Project creation completed in {duration}",
  );

  /// Flutter project creation started
  /// Parameters: {projectName}
  static const flutterProjectStarted = Message(
    "Creating Flutter project \"{projectName}\"...",
  );

  /// Flutter project creation success
  static const flutterProjectCreated = Message(
    "Flutter project created successfully",
  );

  /// Directory creation message
  /// Parameters: {path}
  static const directoryCreated = Message("Project directory created");

  /// Template files generation started
  /// Parameters: {template}
  static const templateGenerationStarted = Message(
    "Generating {template} template files...",
  );

  /// Dependency addition message
  /// Parameters: {dependency}
  static const addingDependency = Message("Adding dependency: {dependency}");

  /// Dependencies installation failed
  /// Parameters: {error}
  static const dependenciesInstallationFailed = Message(
    "Failed to install dependencies: {error}",
  );

  /// Project creation failed
  /// Parameters: {error}
  static const projectCreationFailed = Message(
    "Failed to create project: {error}",
  );

  /// Initialization creation failed
  /// Parameters: {error}
  static const initializationCreationFailed = Message(
    "Failed to create initialization: {error}",
  );

  /// generation template failed
  /// Parameters: {error}
  static const templateGeneratedFailed = Message(
    "Failed to generate template: {error}",
  );

  /// Validation failed
  /// Parameters: {error}
  static const validationFailed = Message("Failed to validate input: {error}");

  /// Operation duration message
  /// Parameters: {operation}, {duration}
  static const operationDuration = Message("{operation} ({duration})");

  /// Job execution started
  /// Parameters: {jobName}
  static const jobStarted = Message("Starting {jobName} job...");

  /// Job execution completed
  /// Parameters: {jobName}, {duration}
  static const jobCompleted = Message("{jobName} job completed in {duration}");

  static const projectCreated = Message(
    "Starting project creation for {name}...",
  );

  static const projectCreatedSuccessfully = Message(
    'Project {name} created successfully!',
  );

  static const projectInitializationSuccessfully = Message(
    'Project {name} initialized successfully!',
  );
}
