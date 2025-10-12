import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateServiceFactory {
  final Logger logger;
  CreateServiceFactory(this.logger);

  FlutterProjectService createFlutter() => FlutterProjectService();
  MasonService createMason() => MasonService(logger: logger);
  DependencyService createDependency() => DependencyService(logger: logger);
  PostGenerationService createPostGen() =>
      PostGenerationService(logger: logger);
}
