@Tags(['e2e'])
library;

import 'package:test/test.dart';
import 'locale_command_test.dart' as locale_command;
import 'locale_generate_command_test.dart' as locale_generate;

/// Comprehensive Locale Commands Test Suite
///
/// Aggregates all locale-related command tests:
/// - LocaleCommand (main command structure)
/// - LocaleGenerateCommand (generation functionality)
void main() {
  // Run all locale command tests
  locale_command.main();
  locale_generate.main();
}
