@Tags(['e2e'])
library;

import 'package:test/test.dart';

// Import all E2E test files
import 'create_command_test.dart' as create_command;
import 'init_command_test.dart' as init_command;
import 'commands/locale/locale_test_suite.dart' as locale_tests;
import 'commands/make/model/model_command_test.dart' as model_tests;
import 'commands/make/view/view_command_test.dart' as view_tests;

/// Comprehensive E2E Test Suite
///
/// Aggregates all end-to-end tests for the gexd CLI tool:
/// - Core commands (create, init)
/// - Make commands (model, view, controller, etc.)
/// - Locale commands (generate)
/// - Integration and performance tests
void main() {
  group('🚀 GEXD CLI E2E Test Suite', () {
    print('');
    print('🎯 Running comprehensive E2E tests for gexd CLI...');
    print('📊 This may take several minutes to complete');
    print('');

    // Core Commands
    group('📋 Core Commands', () {
      create_command.main();
      init_command.main();
    });

    // Make Commands
    group('🔨 Make Commands', () {
      model_tests.main();
      view_tests.main();
    });

    // Locale Commands
    group('🌐 Locale Commands', () {
      locale_tests.main();
    });

    setUpAll(() {
      print('');
      print('🎉 All E2E tests completed successfully!');
      print('✅ gexd CLI is ready for production');
      print('');
    });
  });
}
