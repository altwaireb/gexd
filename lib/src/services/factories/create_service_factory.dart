import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

/// Factory class to create various services used in project creation
/// Provides methods to instantiate services with shared Logger
/// such as FlutterProjectService, MasonService, DependencyService,
class CreateServiceFactory {
  final Logger logger;
  CreateServiceFactory(this.logger);

  FlutterProjectService createFlutter() => FlutterProjectService();
  MasonService createMason() => MasonService(logger: logger);
  DependencyService createDependency() => DependencyService(logger: logger);
  PostGenerationService createPostGen() =>
      PostGenerationService(logger: logger);
}
