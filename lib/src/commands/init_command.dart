import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:gexd/gexd.dart';
import 'package:mason_logger/mason_logger.dart';

class InitCommand extends Command<int> {
  final Logger _logger;
  final PromptServiceInterface _prompt;
  final bool _skipValidation;

  InitCommand({
    Logger? logger,
    PromptServiceInterface? prompt,
    bool skipValidation = false,
  }) : _logger = logger ?? Logger(),
       _prompt = prompt ?? PromptService(),
       _skipValidation = skipValidation {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'template',
        abbr: 't',
        help: 'Project template',
        allowed: ProjectTemplate.allKeys,
        allowedHelp: ProjectTemplate.allowedHelp,
      )
      ..addFlag(
        'full',
        abbr: 'f',
        help: 'Generate full project structure with all directories',
        defaultsTo: false,
      );
  }

  @override
  String get name => 'init';

  @override
  String get description =>
      'Initialize an existing Flutter project with Gexd templates and patterns';

  @override
  Future<int> run() async {
    try {
      final currentDir = Directory.current.path;
      final data = await InitInputs(
        argResults: argResults!,
        prompt: _prompt,
        skipValidation: _skipValidation,
        currentDir: currentDir,
      ).handle();

      final factory = InitServiceFactory(_logger);

      final init = InitProject(
        data,
        masonService: factory.createMason(),
        dependencyService: factory.createDependency(),
        postGenService: factory.createPostGen(),
        logger: _logger,
      );

      return await init.execute();
    } catch (error, stackTrace) {
      _logger.err(error.toString());
      _logger.err(stackTrace.toString());
      return ExitCode.software.code;
    }
  }
}
