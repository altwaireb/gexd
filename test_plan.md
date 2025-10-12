# 🧪 Gexd CLI – Testing Architecture & Setup

## 🔍 ANALYSIS & RECOMMENDATIONS (Updated)

### ✅ What Works Well in Current Implementation:
- **E2EHelpers system** (500+ lines) with isolated temp directories
- **Environment Detection** with local/CI adaptive timeouts  
- **Smart Smoke Test Suite** with 6 passing tests
- **Performance monitoring** and validation systems

### ⚠️ Critical Issues Found:
1. **Test Hanging**: Interactive prompts cause 30s+ timeouts
2. **Duplicate Infrastructure**: Plan overlaps with existing helpers
3. **Missing Integration**: Doesn't leverage current test/suites structure
4. **Performance Issues**: Some tests take 9+ seconds (too slow)

### 🎯 RECOMMENDED APPROACH:

**Instead of implementing this entire new architecture, we should:**

1. **ENHANCE Current E2EHelpers** with Mock support
2. **EXTEND Environment Detection** with better timeout handling  
3. **INTEGRATE with existing test/suites** structure
4. **ADD Mock layer gradually** without disrupting working tests

### 📋 Implementation Priority:
- **HIGH**: Fix hanging tests with proper timeout/mock handling
- **MEDIUM**: Add MockRegistry to existing E2EHelpers
- **LOW**: Migrate to new folder structure (only if needed)

---

## Original Plan Overview

This document describes the **testing architecture**, **helpers**, and **best practices** for maintaining consistent, isolated, and reliable tests across the Gexd CLI project.

The goal is to ensure that both **E2E (end-to-end)** and **unit tests** can be executed easily — locally or in CI — with consistent results and without affecting the developer’s environment.

---

## 🎯 Testing Goals

| Objective         | Description                                                                      |
| ----------------- | -------------------------------------------------------------------------------- |
| **Consistency**   | All tests should behave identically across local and CI environments.            |
| **Isolation**     | Each test runs in a temporary, disposable directory (no pollution).              |
| **Clarity**       | Failures should be easy to diagnose with clear log messages.                     |
| **Speed**         | Simple helpers, minimal setup overhead.                                          |
| **Extensibility** | Helpers can easily grow (e.g., add structure validators or performance metrics). |

---

## 🧱 Folder Structure

All test-related helpers are stored in a single folder for clarity and reuse:

```
test/
 ├── e2e/
 │   └── create_project_test.dart
 └── helpers/
     ├── e2e_helper.dart
     └── environment_helper.dart
```

### ✅ Purpose of Each File

| File                        | Responsibility                                                                                                                   |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| **e2e_helper.dart**         | Provides utilities for creating temporary test directories, running CLI commands, validating project structure, and cleaning up. |
| **environment_helper.dart** | Detects whether tests are running locally or in CI, and adjusts timeouts or settings accordingly.                                |

---

## ⚙️ Implementation Details

### `test/helpers/e2e_helper.dart`

```dart
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

/// E2EHelper - A lightweight utility for end-to-end testing of the Gexd CLI.
class E2EHelper {
  static final _root = Directory.current.path;

  /// Creates a temporary, isolated directory for each test run.
  static Future<Directory> createTemp([String prefix = 'gexd_test_']) async {
    final dir = await Directory.systemTemp.createTemp(prefix);
    print('🧪 Created temp dir: ${dir.path}');
    return dir;
  }

  /// Runs the Gexd CLI using `dart run bin/gexd.dart`.
  static Future<ProcessResult> runGexd(
    List<String> args, {
    String? workingDir,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final binPath = p.join(_root, 'bin', 'gexd.dart');

    final process = await Process.run(
      'dart',
      ['run', binPath, ...args],
      workingDirectory: workingDir ?? _root,
    ).timeout(timeout);

    if (process.exitCode != 0) {
      print('❌ gexd failed with exit code ${process.exitCode}');
      print(process.stderr);
    }

    return process;
  }

  /// Deletes the temporary directory created for the test.
  static Future<void> cleanup(Directory dir) async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print('🧹 Cleaned up ${dir.path}');
    }
  }

  /// Verifies that a generated Flutter project contains the essential files.
  static bool validateBasicStructure(String projectPath) {
    final files = [
      'pubspec.yaml',
      'lib/main.dart',
      'test/widget_test.dart',
    ];

    final missing = files.where(
      (f) => !File(p.join(projectPath, f)).existsSync(),
    );

    if (missing.isEmpty) {
      print('✅ Valid project structure');
      return true;
    } else {
      print('❌ Missing files: ${missing.join(', ')}');
      return false;
    }
  }

  /// Runs `dart pub get` inside a given project directory.
  static Future<void> runPubGet(String projectPath) async {
    final result = await Process.run('dart', ['pub', 'get'],
        workingDirectory: projectPath);
    if (result.exitCode != 0) {
      throw Exception('pub get failed: ${result.stderr}');
    }
  }
}
```

---

### `test/helpers/environment_helper.dart`

```dart
import 'dart:io';

/// TestEnv - Provides environment-aware configuration for tests.
class TestEnv {
  /// Detect if tests are running in a CI/CD environment.
  static bool get isCI =>
      Platform.environment['CI'] == 'true' ||
      Platform.environment['GITHUB_ACTIONS'] == 'true';

  /// Adjust timeouts automatically depending on the environment.
  static Duration get timeout =>
      isCI ? const Duration(minutes: 5) : const Duration(seconds: 30);

  /// Print environment info for better debugging.
  static void printInfo() {
    print('🌍 Running on: ${isCI ? 'CI' : 'Local'}');
  }
}
```

---

## 🧩 Example E2E Test

`test/e2e/create_project_test.dart`

```dart
import 'dart:io';
import 'package:test/test.dart';
import '../helpers/e2e_helper.dart';
import '../helpers/environment_helper.dart';
import 'package:path/path.dart' as p;

void main() {
  TestEnv.printInfo();

  test('E2E: Create new project successfully', () async {
    final temp = await E2EHelper.createTemp();

    final result = await E2EHelper.runGexd(
      ['create', 'demo_app'],
      workingDir: temp.path,
      timeout: TestEnv.timeout,
    );

    expect(result.exitCode, 0, reason: result.stderr.toString());

    final projectPath = p.join(temp.path, 'demo_app');
    final isValid = E2EHelper.validateBasicStructure(projectPath);
    expect(isValid, isTrue);

    await E2EHelper.cleanup(temp);
  });
}
```

---

## 🧰 Optional Extensions (Future)

You can extend the helper system gradually as the CLI evolves.

| Extension                 | Description                                                                        |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `measurePerformance()`    | Wraps a test and logs the execution time in milliseconds.                          |
| `validateGetXStructure()` | Checks that `lib/app/modules/` and `core/services/` exist in GetX-based templates. |
| `MockPromptService`       | Provides simulated user input for interactive commands.                            |
| `FakeFlutterService`      | Mocks Flutter commands like `flutter create` or `flutter pub get`.                 |

---

## 🧠 Design Principles

1. **One helper per concern**
   `E2EHelper` for integration testing utilities, `TestEnv` for environment logic.

2. **No side effects**
   Tests never modify the developer’s workspace — everything happens in a temporary directory.

3. **CI-safe**
   Automatically handles longer timeouts and reduced verbosity when running in CI.

4. **Composable**
   Helpers can be reused in unit tests or extended for more complex scenarios.

---

## 🧾 Running Tests

### Locally

```bash
dart test
```

### CI (only E2E tests)

```bash
dart test --tags e2e --reporter expanded
```

### With Coverage

```bash
dart test --coverage=coverage
```

---

## 🧩 Notes for Contributors

* **Never hardcode absolute paths** in tests. Always use the provided `createTemp()` method.
* **Keep helpers small and reusable** — one purpose per helper.
* **Ensure cleanup** happens even when tests fail (you can use `addTearDown()`).
* **Avoid mocking system tools** like `dart` or `flutter` unless absolutely necessary; prefer running lightweight real commands.

---








# 🧪 Gexd Command Testing Architecture

## Overview

This document describes how to design and implement a **robust, extensible, and testable** command testing system for the `gexd` CLI.
It covers:

* Interactive and non-interactive command testing
* Use of mocks for services and prompts
* Organized directory structure
* Reusable helpers and factories
* Fast and maintainable testing patterns

---

## 🎯 Goals

* ✅ Support **automated tests** for CLI commands with and without user input
* ✅ Enable **mocked services** (e.g., `FlutterProjectService`, `MasonService`, etc.)
* ✅ Provide a **`PromptServiceMock`** for interactive tests
* ✅ Isolate all external operations (filesystem, shell, network)
* ✅ Maintain a clean, **SOLID-aligned structure**

---

## 📁 Directory Structure

Organize the test directory like this:

```
test/
├── commands/
│   ├── create_command_test.dart
│   ├── build_command_test.dart
│   └── ...other command tests
│
├── mocks/
│   ├── prompt_service_mock.dart
│   ├── flutter_project_service_mock.dart
│   ├── mason_service_mock.dart
│   ├── dependency_service_mock.dart
│   └── post_generation_service_mock.dart
│
├── helpers/
│   ├── test_environment.dart
│   ├── fake_project_factory.dart
│   └── mock_registry.dart
│
└── test_utils.dart
```

---

## 🧱 Core Testing Layers

### 1. **Mock Layer (`/test/mocks`)**

Each mock should implement its corresponding service interface.
Example:

```dart
// test/mocks/prompt_service_mock.dart
import 'package:gexd/src/services/interfaces/prompt_service_interface.dart';

class PromptServiceMock implements PromptServiceInterface {
  final List<String> inputs;
  final List<bool> confirmations;
  final List<int> selections;
  final List<List<int>> multiSelections;

  int _inputIndex = 0;
  int _confirmIndex = 0;
  int _selectIndex = 0;
  int _multiSelectIndex = 0;

  PromptServiceMock({
    this.inputs = const [],
    this.confirmations = const [],
    this.selections = const [],
    this.multiSelections = const [],
  });

  @override
  Future<String> input(String prompt, {String? defaultValue, String? Function(String)? validator}) async {
    final value = _inputIndex < inputs.length ? inputs[_inputIndex++] : (defaultValue ?? '');
    if (validator != null) {
      final error = validator(value);
      if (error != null) throw Exception(error);
    }
    return value;
  }

  @override
  Future<bool> confirm(String prompt, {bool defaultValue = false}) async {
    return _confirmIndex < confirmations.length
        ? confirmations[_confirmIndex++]
        : defaultValue;
  }

  @override
  Future<int> select(String prompt, List<String> options, {int? initialIndex}) async {
    return _selectIndex < selections.length
        ? selections[_selectIndex++]
        : (initialIndex ?? 0);
  }

  @override
  Future<List<int>> multiSelect(String prompt, List<String> options, {List<bool>? defaults}) async {
    return _multiSelectIndex < multiSelections.length
        ? multiSelections[_multiSelectIndex++]
        : [];
  }
}
```

---

### 2. **Helper Layer (`/test/helpers`)**

#### 🧩 `test_environment.dart`

Sets up a **temporary project directory** and injects mock dependencies.

```dart
import 'dart:io';
import 'package:path/path.dart' as p;

class TestEnvironment {
  late final Directory tempDir;

  Future<void> setup() async {
    tempDir = await Directory.systemTemp.createTemp('gexd_test_');
  }

  Future<void> cleanup() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  String path(String relative) => p.join(tempDir.path, relative);
}
```

---

#### 🏗️ `fake_project_factory.dart`

Creates a fake Flutter project structure for integration-like tests.

```dart
import 'dart:io';
import 'package:path/path.dart' as p;

class FakeProjectFactory {
  final String root;

  FakeProjectFactory(this.root);

  Future<void> createBasicStructure() async {
    await Directory(p.join(root, 'lib')).create(recursive: true);
    await File(p.join(root, 'pubspec.yaml')).writeAsString('name: fake_project');
  }
}
```

---

#### 🧠 `mock_registry.dart`

Centralized mock container for dependency injection in tests.

```dart
import '../mocks/prompt_service_mock.dart';
import '../mocks/flutter_project_service_mock.dart';
import '../mocks/mason_service_mock.dart';
import '../mocks/dependency_service_mock.dart';
import '../mocks/post_generation_service_mock.dart';

class MockRegistry {
  late PromptServiceMock prompt;
  late FlutterProjectServiceMock flutterProject;
  late MasonServiceMock mason;
  late DependencyServiceMock dependencies;
  late PostGenerationServiceMock postGen;

  void initialize() {
    prompt = PromptServiceMock();
    flutterProject = FlutterProjectServiceMock();
    mason = MasonServiceMock();
    dependencies = DependencyServiceMock();
    postGen = PostGenerationServiceMock();
  }
}
```

---

### 3. **Command Tests (`/test/commands`)**

Example for `create:module` command:

```dart
import 'package:test/test.dart';
import '../helpers/test_environment.dart';
import '../helpers/mock_registry.dart';
import 'package:gexd/src/commands/create_module_command.dart';

void main() {
  group('CreateModuleCommand', () {
    late TestEnvironment env;
    late MockRegistry mocks;

    setUp(() async {
      env = TestEnvironment();
      await env.setup();

      mocks = MockRegistry()..initialize();
    });

    tearDown(() async => await env.cleanup());

    test('runs successfully with interactive input', () async {
      mocks.prompt = PromptServiceMock(inputs: ['user', 'yes']);
      final command = CreateModuleCommand(
        promptService: mocks.prompt,
        flutterProjectService: mocks.flutterProject,
      );

      final result = await command.run(['create:module']);
      expect(result, equals(0));
    });

    test('handles missing arguments gracefully', () async {
      final command = CreateModuleCommand(
        promptService: mocks.prompt,
        flutterProjectService: mocks.flutterProject,
      );

      final result = await command.run([]);
      expect(result, isNot(0));
    });
  });
}
```

---

## 🧩 Integration with Dependency Injection

Ensure all services are **abstracted and injected**, allowing mocks to replace them easily.

Example:

```dart
class CreateModuleCommand extends Command {
  final PromptServiceInterface promptService;
  final FlutterProjectServiceInterface flutterProjectService;

  CreateModuleCommand({
    required this.promptService,
    required this.flutterProjectService,
  });

  @override
  Future<int> run(List<String> args) async {
    final moduleName = await promptService.input('Module name:');
    await flutterProjectService.createModule(moduleName);
    return 0;
  }
}
```

---

## 🧠 Summary of Benefits

✅ Fast & isolated tests (no real file operations)
✅ Support for both interactive and non-interactive testing
✅ Scalable architecture — new mocks and helpers are easy to add
✅ Clearly separated layers for **Mocks**, **Helpers**, and **Commands**
✅ Ready for CI pipelines with zero manual input

---

## 🧩 Future Improvements

* Add `FakeProcessRunner` to simulate shell commands (`flutter create`, `git`, etc.)
* Add snapshot comparison for generated files
* Add test coverage reports via `dart test --coverage`

---






Perfect 👌 — here’s a **ready-to-copy, pre-structured folder skeleton** for your `gexd` CLI test environment.

You can paste this directly into your `test/` directory.
Each file includes short boilerplate code or comments guiding the developer on what to implement.

---

# 🧩 `gexd` CLI — Test Folder Skeleton

```
test/
├── commands/
│   ├── create_module_command_test.dart
│   ├── build_command_test.dart
│   └── example_command_test.dart
│
├── helpers/
│   ├── test_environment.dart
│   ├── fake_project_factory.dart
│   ├── mock_registry.dart
│   └── test_utils.dart
│
├── mocks/
│   ├── prompt_service_mock.dart
│   ├── flutter_project_service_mock.dart
│   ├── mason_service_mock.dart
│   ├── dependency_service_mock.dart
│   ├── post_generation_service_mock.dart
│   └── mock_base.dart
│
└── test_config.dart
```

---

## 🧱 File-by-file Implementation

### 📁 `test/commands/create_module_command_test.dart`

```dart
import 'package:test/test.dart';
import '../helpers/test_environment.dart';
import '../helpers/mock_registry.dart';
import 'package:gexd/src/commands/create_module_command.dart';

void main() {
  group('CreateModuleCommand', () {
    late TestEnvironment env;
    late MockRegistry mocks;

    setUp(() async {
      env = TestEnvironment();
      await env.setup();
      mocks = MockRegistry()..initialize();
    });

    tearDown(() async => await env.cleanup());

    test('runs successfully with interactive input', () async {
      mocks.prompt = PromptServiceMock(inputs: ['auth', 'yes']);
      final command = CreateModuleCommand(
        promptService: mocks.prompt,
        flutterProjectService: mocks.flutterProject,
      );

      final result = await command.run(['create:module']);
      expect(result, equals(0));
    });

    test('handles missing arguments gracefully', () async {
      final command = CreateModuleCommand(
        promptService: mocks.prompt,
        flutterProjectService: mocks.flutterProject,
      );

      final result = await command.run([]);
      expect(result, isNot(0));
    });
  });
}
```

---

### 📁 `test/helpers/test_environment.dart`

```dart
import 'dart:io';
import 'package:path/path.dart' as p;

/// Provides a temporary, isolated test environment.
class TestEnvironment {
  late final Directory tempDir;

  Future<void> setup() async {
    tempDir = await Directory.systemTemp.createTemp('gexd_test_');
  }

  Future<void> cleanup() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }

  String path(String relative) => p.join(tempDir.path, relative);
}
```

---

### 📁 `test/helpers/fake_project_factory.dart`

```dart
import 'dart:io';
import 'package:path/path.dart' as p;

/// Generates a minimal fake Flutter project structure for command tests.
class FakeProjectFactory {
  final String root;

  FakeProjectFactory(this.root);

  Future<void> createBasicStructure() async {
    await Directory(p.join(root, 'lib')).create(recursive: true);
    await File(p.join(root, 'pubspec.yaml')).writeAsString('name: fake_project');
  }
}
```

---

### 📁 `test/helpers/mock_registry.dart`

```dart
import '../mocks/prompt_service_mock.dart';
import '../mocks/flutter_project_service_mock.dart';
import '../mocks/mason_service_mock.dart';
import '../mocks/dependency_service_mock.dart';
import '../mocks/post_generation_service_mock.dart';

/// Centralized registry for test mocks.
/// Makes it easy to inject them into commands or services.
class MockRegistry {
  late PromptServiceMock prompt;
  late FlutterProjectServiceMock flutterProject;
  late MasonServiceMock mason;
  late DependencyServiceMock dependencies;
  late PostGenerationServiceMock postGen;

  void initialize() {
    prompt = PromptServiceMock();
    flutterProject = FlutterProjectServiceMock();
    mason = MasonServiceMock();
    dependencies = DependencyServiceMock();
    postGen = PostGenerationServiceMock();
  }
}
```

---

### 📁 `test/helpers/test_utils.dart`

```dart
import 'dart:io';

/// Common utilities for command testing
class TestUtils {
  static Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

  static bool fileExists(String path) => File(path).existsSync();

  static String readFile(String path) => File(path).readAsStringSync();
}
```

---

### 📁 `test/mocks/mock_base.dart`

```dart
/// Base class for all mocks.
/// Helps maintain consistency and debugging visibility.
abstract class MockBase {
  void log(String message) {
    // ignore: avoid_print
    print('[Mock] $message');
  }
}
```

---

### 📁 `test/mocks/prompt_service_mock.dart`

```dart
import 'package:gexd/src/services/interfaces/prompt_service_interface.dart';
import 'mock_base.dart';

class PromptServiceMock extends MockBase implements PromptServiceInterface {
  final List<String> inputs;
  final List<bool> confirmations;
  final List<int> selections;
  final List<List<int>> multiSelections;

  int _inputIndex = 0;
  int _confirmIndex = 0;
  int _selectIndex = 0;
  int _multiSelectIndex = 0;

  PromptServiceMock({
    this.inputs = const [],
    this.confirmations = const [],
    this.selections = const [],
    this.multiSelections = const [],
  });

  @override
  Future<String> input(String prompt, {String? defaultValue, String? Function(String)? validator}) async {
    log('input: $prompt');
    final value = _inputIndex < inputs.length ? inputs[_inputIndex++] : (defaultValue ?? '');
    if (validator != null) {
      final error = validator(value);
      if (error != null) throw Exception(error);
    }
    return value;
  }

  @override
  Future<bool> confirm(String prompt, {bool defaultValue = false}) async {
    log('confirm: $prompt');
    return _confirmIndex < confirmations.length ? confirmations[_confirmIndex++] : defaultValue;
  }

  @override
  Future<int> select(String prompt, List<String> options, {int? initialIndex}) async {
    log('select: $prompt');
    return _selectIndex < selections.length ? selections[_selectIndex++] : (initialIndex ?? 0);
  }

  @override
  Future<List<int>> multiSelect(String prompt, List<String> options, {List<bool>? defaults}) async {
    log('multiSelect: $prompt');
    return _multiSelectIndex < multiSelections.length ? multiSelections[_multiSelectIndex++] : [];
  }
}
```

---

### 📁 `test/mocks/flutter_project_service_mock.dart`

```dart
import 'package:gexd/src/services/interfaces/flutter_project_service_interface.dart';
import 'mock_base.dart';

class FlutterProjectServiceMock extends MockBase implements FlutterProjectServiceInterface {
  bool created = false;

  @override
  Future<void> createProject(String name) async {
    log('createProject called with $name');
    created = true;
  }

  @override
  Future<bool> isFlutterProject(String path) async {
    log('isFlutterProject called for $path');
    return true;
  }
}
```

---

### 📁 `test/mocks/mason_service_mock.dart`

```dart
import 'package:gexd/src/services/interfaces/mason_service_interface.dart';
import 'mock_base.dart';

class MasonServiceMock extends MockBase implements MasonServiceInterface {
  @override
  Future<void> runTemplate(String template, Map<String, dynamic> vars) async {
    log('runTemplate: $template');
  }
}
```

---

### 📁 `test/mocks/dependency_service_mock.dart`

```dart
import 'package:gexd/src/services/interfaces/dependency_service_interface.dart';
import 'mock_base.dart';

class DependencyServiceMock extends MockBase implements DependencyServiceInterface {
  @override
  Future<void> installDependencies() async {
    log('installDependencies');
  }
}
```

---

### 📁 `test/mocks/post_generation_service_mock.dart`

```dart
import 'package:gexd/src/services/interfaces/post_generation_service_interface.dart';
import 'mock_base.dart';

class PostGenerationServiceMock extends MockBase implements PostGenerationServiceInterface {
  @override
  Future<void> runPostGenerationHooks() async {
    log('runPostGenerationHooks');
  }
}
```

---

### 📁 `test/test_config.dart`

```dart
/// This file can be used to set up global test configuration,
/// such as initializing environment variables, fake paths, etc.
///
/// It will automatically run before all tests if included via
/// `dart test --preload test/test_config.dart`.

void setupTestConfig() {
  // Example: Environment setup
  // Platform.environment['CI'] = 'true';
}
```

---

## ✅ Summary

This skeleton gives your developers:

* Full **mock + helper + command test** structure
* Clear **extensibility** for new commands or services
* Seamless testing of **interactive prompts**
* Strong isolation for **filesystem and dependencies**

---






Excellent ✅
Here’s a **complete, minimal `ExampleCommand`** implementation designed for your `gexd` CLI — perfectly compatible with the test skeleton I provided.

It demonstrates **manual arguments + interactive prompts + dependency mocks**, so developers can easily understand how to build and test new commands.

---

# 📂 `lib/src/commands/example_command.dart`

````dart
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:gexd/gexd.dart';

/// A simple example command to demonstrate how to:
/// - Parse arguments
/// - Ask interactive questions via [PromptServiceInterface]
/// - Use injected services for Flutter and Mason
///
/// Example:
/// ```bash
/// gexd example hello --upper
/// ```
/// or interactive:
/// ```bash
/// gexd example
/// ```
class ExampleCommand extends Command<int> {
  final Logger _logger;
  final PromptServiceInterface _prompt;
  final FlutterProjectServiceInterface _flutterService;
  final MasonServiceInterface _masonService;

  @override
  String get name => 'example';

  @override
  String get description =>
      'An example command showing input, confirmation, and mockable dependencies.';

  ExampleCommand({
    required Logger logger,
    required PromptServiceInterface prompt,
    required FlutterProjectServiceInterface flutterService,
    required MasonServiceInterface masonService,
  })  : _logger = logger,
        _prompt = prompt,
        _flutterService = flutterService,
        _masonService = masonService {
    _setupArgs();
  }

  void _setupArgs() {
    argParser
      ..addOption(
        'message',
        abbr: 'm',
        help: 'Message to display (optional)',
      )
      ..addFlag(
        'upper',
        abbr: 'u',
        help: 'Convert message to uppercase',
        defaultsTo: false,
      );
  }

  @override
  Future<int> run() async {
    try {
      String? message = argResults?['message'] as String?;
      final toUpper = argResults?['upper'] as bool;

      // If no message was passed, ask interactively
      message ??= await _prompt.input(
        'Enter a message to display:',
        defaultValue: 'Hello from gexd!',
      );

      // Ask for confirmation to continue
      final confirmed = await _prompt.confirm(
        'Do you want to print this message?',
        defaultValue: true,
      );
      if (!confirmed) {
        _logger.warn('Operation cancelled.');
        return ExitCode.success.code;
      }

      // Use dependencies (mocked in tests)
      await _flutterService.createProject('example_temp_project');
      await _masonService.runTemplate('example_template', {'message': message});

      final output = toUpper ? message.toUpperCase() : message;
      _logger.info('✅ Output: $output');
      return ExitCode.success.code;
    } catch (e, s) {
      _logger.err('❌ Error in example command: $e');
      _logger.detail(s.toString());
      return ExitCode.software.code;
    }
  }
}
````

---

# 📂 `test/commands/example_command_test.dart`

```dart
import 'package:test/test.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:gexd/src/commands/example_command.dart';
import '../../helpers/mock_registry.dart';
import '../../helpers/test_environment.dart';

void main() {
  group('ExampleCommand', () {
    late TestEnvironment env;
    late MockRegistry mocks;
    late Logger logger;

    setUp(() async {
      env = TestEnvironment();
      await env.setup();
      mocks = MockRegistry()..initialize();
      logger = Logger();
    });

    tearDown(() async => await env.cleanup());

    test('runs successfully with manual message', () async {
      final command = ExampleCommand(
        logger: logger,
        prompt: mocks.prompt,
        flutterService: mocks.flutterProject,
        masonService: mocks.mason,
      );

      final result = await command.runFrom(['example', '-m', 'test', '--upper']);
      expect(result, equals(0));
    });

    test('runs successfully with interactive prompt', () async {
      mocks.prompt = PromptServiceMock(
        inputs: ['Interactive message'],
        confirmations: [true],
      );

      final command = ExampleCommand(
        logger: logger,
        prompt: mocks.prompt,
        flutterService: mocks.flutterProject,
        masonService: mocks.mason,
      );

      final result = await command.runFrom(['example']);
      expect(result, equals(0));
    });

    test('handles user cancellation gracefully', () async {
      mocks.prompt = PromptServiceMock(
        inputs: ['Some message'],
        confirmations: [false],
      );

      final command = ExampleCommand(
        logger: logger,
        prompt: mocks.prompt,
        flutterService: mocks.flutterProject,
        masonService: mocks.mason,
      );

      final result = await command.runFrom(['example']);
      expect(result, equals(0)); // command exits gracefully
    });
  });
}
```

---

# 🧠 Explanation for Developers

| Concept                    | Description                                                          |
| -------------------------- | -------------------------------------------------------------------- |
| **PromptServiceInterface** | Abstracts input, confirmation, and selection logic (real or mocked). |
| **MockRegistry**           | Central location to access fake implementations for all services.    |
| **ExampleCommand**         | Demonstrates a testable, dependency-injected command structure.      |
| **runFrom([...])**         | Allows simulating CLI args inside tests (from `args.Command`).       |
| **FakeProjectFactory**     | Used in future commands to generate test project directories.        |

---

# 🧩 How to Register It

Add `ExampleCommand` to your command runner (so it’s visible via `gexd example`):

```dart
// lib/src/commands/interfaces/gexd_command_runner.dart
addCommand(ExampleCommand(
  logger: _logger,
  prompt: _prompt,
  flutterService: FlutterProjectService(),
  masonService: MasonService(),
));
```

---

# ✅ What Developers Learn from This Example

* How to **build new commands** following the same pattern.
* How to **inject dependencies** (instead of using singletons).
* How to **mock all services** for fully isolated unit tests.
* How to test both **manual arguments** and **interactive prompts**.
* How to keep tests **fast, readable, and deterministic**.

---





Perfect 👌 — here’s the **next section** for your `.md` guide.
It explains, step by step, how developers can **extend the command testing system** into **full integration tests** that simulate real CLI runs with fake projects — without ever touching the real filesystem or network.

---

# 🧪 Integration Testing Guide for Gexd CLI

This section explains how to create **integration tests** for Gexd commands that simulate **real CLI runs** — including argument parsing, file creation, and service orchestration — in a **safe and isolated test environment**.

---

## 🎯 Goal

Integration tests should:

1. Run the full command runner (`GexdCommandRunner`) end-to-end.
2. Use a **temporary fake project directory** (no side effects on disk).
3. Mock external processes (like `flutter create`, `mason make`).
4. Support both **automated** and **interactive** testing.
5. Provide consistent logs for CI and local runs.

---

## 🧩 Folder Structure

Your project should have this testing layout:

```
test/
├── commands/
│   ├── create_command_test.dart
│   ├── example_command_test.dart
│   └── ...
├── helpers/
│   ├── test_environment.dart
│   ├── mock_registry.dart
│   ├── prompt_service_mock.dart
│   ├── flutter_service_mock.dart
│   └── mason_service_mock.dart
└── integration/
    ├── create_project_integration_test.dart
    ├── example_integration_test.dart
    └── ...
```

---

## 🧱 `TestEnvironment` (Reusable Setup)

This helper creates a **temporary directory** and cleans it automatically.
You’ll use this in **all integration tests**.

```dart
// test/helpers/test_environment.dart
import 'dart:io';
import 'package:path/path.dart' as p;

class TestEnvironment {
  late final Directory rootDir;

  Future<void> setup() async {
    rootDir = await Directory.systemTemp.createTemp('gexd_test_');
  }

  String get path => rootDir.path;

  File file(String name) => File(p.join(rootDir.path, name));

  Future<void> cleanup() async {
    if (await rootDir.exists()) {
      await rootDir.delete(recursive: true);
    }
  }
}
```

---

## 🧩 `MockRegistry` (Centralized Mocks)

This registry provides reusable mock implementations of all services:

```dart
// test/helpers/mock_registry.dart
import 'prompt_service_mock.dart';
import 'flutter_service_mock.dart';
import 'mason_service_mock.dart';

class MockRegistry {
  late PromptServiceMock prompt;
  late FlutterServiceMock flutterProject;
  late MasonServiceMock mason;

  void initialize() {
    prompt = PromptServiceMock();
    flutterProject = FlutterServiceMock();
    mason = MasonServiceMock();
  }
}
```

---

## 🧠 Example: Mock Prompt Service

```dart
// test/helpers/prompt_service_mock.dart
import 'package:gexd/gexd.dart';

class PromptServiceMock implements PromptServiceInterface {
  final List<String> inputs;
  final List<bool> confirmations;
  int _inputIndex = 0;
  int _confirmIndex = 0;

  PromptServiceMock({
    this.inputs = const [],
    this.confirmations = const [],
  });

  @override
  Future<String> input(String prompt, {String? defaultValue, String? Function(String)? validator}) async {
    return _inputIndex < inputs.length
        ? inputs[_inputIndex++]
        : (defaultValue ?? '');
  }

  @override
  Future<bool> confirm(String prompt, {bool defaultValue = false}) async {
    return _confirmIndex < confirmations.length
        ? confirmations[_confirmIndex++]
        : defaultValue;
  }

  @override
  Future<int> select(String prompt, List<String> options, {int? initialIndex}) async => 0;

  @override
  Future<List<int>> multiSelect(String prompt, List<String> options, {List<bool>? defaults}) async => [];
}
```

---

## 🧰 Mock Flutter and Mason Services

```dart
// test/helpers/flutter_service_mock.dart
import 'package:gexd/gexd.dart';

class FlutterServiceMock implements FlutterProjectServiceInterface {
  final List<String> createdProjects = [];

  @override
  Future<void> createProject(String name) async {
    createdProjects.add(name);
  }
}
```

```dart
// test/helpers/mason_service_mock.dart
import 'package:gexd/gexd.dart';

class MasonServiceMock implements MasonServiceInterface {
  final List<String> usedTemplates = [];

  @override
  Future<void> runTemplate(String name, Map<String, dynamic> vars) async {
    usedTemplates.add(name);
  }
}
```

---

## 🧪 Example Integration Test

```dart
// test/integration/example_integration_test.dart
import 'package:test/test.dart';
import 'package:gexd/gexd.dart';
import '../helpers/mock_registry.dart';
import '../helpers/test_environment.dart';
import 'package:mason_logger/mason_logger.dart';

void main() {
  group('ExampleCommand (integration)', () {
    late TestEnvironment env;
    late MockRegistry mocks;
    late Logger logger;
    late GexdCommandRunner runner;

    setUp(() async {
      env = TestEnvironment();
      await env.setup();
      mocks = MockRegistry()..initialize();
      logger = Logger();

      runner = GexdCommandRunner(
        logger: logger,
        prompt: mocks.prompt,
      );
    });

    tearDown(() async => await env.cleanup());

    test('runs full CLI successfully with arguments', () async {
      final code = await runner.run(['example', '--message', 'Hello']);
      expect(code, equals(0));
    });

    test('runs full CLI successfully with interactive mode', () async {
      mocks.prompt = PromptServiceMock(
        inputs: ['Interactive mode!'],
        confirmations: [true],
      );

      final code = await runner.run(['example']);
      expect(code, equals(0));
    });

    test('handles user cancellation gracefully', () async {
      mocks.prompt = PromptServiceMock(
        inputs: ['Will cancel'],
        confirmations: [false],
      );

      final code = await runner.run(['example']);
      expect(code, equals(0));
    });
  });
}
```

---

## 🧩 Advanced Option: Test CLI as a Real Process

If you want to test the **compiled binary** (like a real user), use `Process.run()`:

```dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('runs gexd binary directly', () async {
    final result = await Process.run('dart', ['run', 'bin/gexd.dart', 'example', '-m', 'CLI test']);
    expect(result.exitCode, equals(0));
    expect(result.stdout, contains('CLI test'));
  });
}
```

> 🧠 Use this sparingly — process-based tests are slower and less isolated than mock-based tests.

---

## ✅ Benefits of This Testing Architecture

| Feature             | Description                                                               |
| ------------------- | ------------------------------------------------------------------------- |
| **Full Coverage**   | Both interactive and automated modes tested end-to-end.                   |
| **Fast & Isolated** | No real project creation, no network, no I/O.                             |
| **Reusability**     | Shared mocks, test environment, and logger utilities.                     |
| **Extensibility**   | Easily add new service mocks as you grow (e.g., `DependencyServiceMock`). |
| **CI Friendly**     | Works seamlessly with GitHub Actions or any CI system.                    |

---

## 🚀 Developer Workflow

1. Create your command under `lib/src/commands/`.
2. Add mocks if the command uses new services.
3. Write **unit tests** in `test/commands/`.
4. Write **integration tests** in `test/integration/`.
5. Run all tests with:

   ```bash
   dart test --reporter=expanded
   ```
6. Check coverage:

   ```bash
   dart run coverage:test_with_coverage
   ```

---

---

## 🔧 PRACTICAL IMPLEMENTATION PLAN

### Phase 1: Fix Current Issues (URGENT)
```dart
// Add to existing E2EHelpers:
class E2EHelpers {
  static Future<ProcessResult> runCommandWithTimeout(
    List<String> args,
    {Duration timeout = const Duration(seconds: 10)}
  ) async {
    return runCommand(args).timeout(timeout);
  }
  
  static MockRegistry? _mockRegistry;
  static void useMocks(MockRegistry registry) {
    _mockRegistry = registry;
  }
}
```

### Phase 2: Enhance Environment Detection
```dart
// Add to existing EnvironmentConfig:
class EnvironmentConfig {
  static Duration get promptTimeout => 
    TestEnvironment.instance.isLocalEnvironment 
      ? Duration(seconds: 3)  // Fast local timeout
      : Duration(seconds: 10); // CI timeout
}
```

### Phase 3: Gradual Mock Integration
- Keep existing `test/helpers/e2e_helpers.dart`
- Add `test/helpers/mock_registry.dart` (from this plan)
- Extend current test suites with mock support

### Phase 4: Structure Migration (Optional)
Only if Phase 1-3 proves insufficient:
- Migrate to proposed folder structure
- Update all existing tests
- Full integration testing overhaul

---

## ✅ FINAL RECOMMENDATIONS

**DO IMPLEMENT:**
- Mock system for interactive prompts
- Better timeout handling  
- Performance optimizations
- Enhanced Environment Detection

**DON'T IMPLEMENT (Yet):**
- Complete folder restructure
- Full replacement of E2EHelpers
- New test infrastructure from scratch

**REASON**: Current system works well (6/6 tests passing), just needs refinement rather than replacement.

Would you like me to add a **final section** in the `.md` explaining how to **auto-generate new test skeletons** when developers create new commands — for example, when running:

```bash
gexd make command example
```

so it also generates:

* `lib/src/commands/example_command.dart`  
* `test/commands/example_command_test.dart`
* `test/integration/example_integration_test.dart`
