@Tags(['unit'])
library;

import 'package:test/test.dart';
import 'package:args/args.dart';
import 'package:gexd/src/jobs/create/create_inputs.dart';
import 'package:gexd/src/core/enums/project/project_template.dart';
import '../helpers/test_environment.dart';
import '../mocks/prompt_service_mock.dart';

void main() {
  group('CreateCommand Integration Tests', () {
    late TestEnvironment env;
    late PromptServiceMock mockPrompt;

    setUp(() async {
      env = TestEnvironment();
      await env.setup();
      mockPrompt = PromptServiceMock();
    });

    tearDown(() async {
      await env.cleanup();
    });

    test('should create CreateInputs with ArgResults correctly', () async {
      // Create ArgParser and parse arguments
      final parser = ArgParser()
        ..addOption('template', abbr: 't', defaultsTo: 'getx')
        ..addMultiOption('platforms', defaultsTo: ['android', 'ios'])
        ..addOption('org', defaultsTo: 'com.example')
        ..addOption('description', defaultsTo: 'A new Flutter project')
        ..addFlag('full', defaultsTo: false);

      final argResults = parser.parse(['test_app', '--template', 'getx']);

      // Create CreateInputs with ArgResults
      final inputs = CreateInputs(argResults, prompt: mockPrompt);

      // Verify inputs object was created successfully
      expect(inputs.argResults, equals(argResults));
    });

    test('should handle CreateData from CreateInputs', () async {
      // Create ArgParser and parse arguments
      final parser = ArgParser()
        ..addOption('template', abbr: 't', defaultsTo: 'getx')
        ..addMultiOption('platforms', defaultsTo: ['android', 'ios'])
        ..addOption('org', defaultsTo: 'com.example')
        ..addOption('description', defaultsTo: 'A new Flutter project')
        ..addFlag('full', defaultsTo: false);

      final argResults = parser.parse(['test_app', '--template', 'getx']);
      final inputs = CreateInputs(argResults, prompt: mockPrompt);

      // Handle inputs to get CreateData
      final createData = await inputs.handle();

      // Verify CreateData was created correctly
      expect(createData.name, equals('test_app'));
      expect(createData.template, equals(ProjectTemplate.getx));
      expect(createData.platforms, contains('android'));
      expect(createData.platforms, contains('ios'));
      expect(createData.organization, equals('com.example'));
    });

    test('should handle different project templates via arguments', () async {
      final parser = ArgParser()
        ..addOption('template', abbr: 't')
        ..addMultiOption('platforms', defaultsTo: ['android', 'ios'])
        ..addOption('org', defaultsTo: 'com.example')
        ..addOption('description', defaultsTo: 'A new Flutter project')
        ..addFlag('full', defaultsTo: false);

      // Test GetX template
      final getxArgs = parser.parse(['getx_app', '--template', 'getx']);
      final getxInputs = CreateInputs(getxArgs, prompt: mockPrompt);
      final getxData = await getxInputs.handle();
      expect(getxData.template, equals(ProjectTemplate.getx));

      // Test Clean Architecture template
      final cleanArgs = parser.parse(['clean_app', '--template', 'clean']);
      final cleanInputs = CreateInputs(cleanArgs, prompt: mockPrompt);
      final cleanData = await cleanInputs.handle();
      expect(cleanData.template, equals(ProjectTemplate.clean));
    });

    test('should validate project name from arguments', () async {
      final parser = ArgParser()
        ..addOption('template', abbr: 't', defaultsTo: 'getx')
        ..addMultiOption('platforms', defaultsTo: ['android', 'ios'])
        ..addOption('org', defaultsTo: 'com.example')
        ..addOption('description', defaultsTo: 'A new Flutter project')
        ..addFlag('full', defaultsTo: false);

      // Test valid project names
      const validNames = ['test_app', 'my_app', 'flutter_project', 'app123'];

      for (final name in validNames) {
        final argResults = parser.parse([name, '--template', 'getx']);
        final inputs = CreateInputs(argResults, prompt: mockPrompt);
        final createData = await inputs.handle();
        expect(createData.name, equals(name));
      }
    });
  });
}
