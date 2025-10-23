import '../utils/regex_utils.dart';
import '../utils/enum_analyzer.dart';

/// Extracts metadata and documentation from Dart command class files
///
/// This class parses command class definitions to extract all relevant
/// information needed for documentation generation including names,
/// descriptions, aliases, options, and flags.
class CommandExtractor {
  /// The raw content of the command file
  final String content;

  /// The file path of the command file (for direct analysis)
  final String? filePath;

  /// Creates a new command extractor for the given file content
  CommandExtractor(this.content, {this.filePath});

  /// Extracts the command class name (e.g., 'CreateCommand')
  String get className => _extractClassName() ?? 'UnknownCommand';

  /// Extracts the command name (e.g., 'create')
  String get name => _extractName() ?? 'unknown';

  /// Extracts the command description with proper formatting
  String get description => _extractDescription() ?? 'No description provided.';

  /// Extracts command aliases as a list of strings
  List<String> get aliases => _extractAliases();

  /// Extracts detailed usage information from the usage getter
  String get detailedUsage => _extractDetailedUsage();

  /// Extracts command options with detailed information
  List<Map<String, dynamic>> get options => _extractDetailedOptions();

  /// Extracts command flags with detailed information
  List<Map<String, dynamic>> get flags => _extractDetailedFlags();

  // ============ PRIVATE EXTRACTION METHODS ============

  /// Extracts the class name from the file content
  String? _extractClassName() {
    final match = RegexUtils.className.firstMatch(content);
    return match?.group(1);
  }

  /// Extracts the command name from the getter
  String? _extractName() {
    // Try single quotes first
    var match = RegexUtils.nameGetterSingle.firstMatch(content);
    if (match != null) return match.group(1);

    // Try double quotes
    match = RegexUtils.nameGetterDouble.firstMatch(content);
    return match?.group(1);
  }

  /// Extracts and formats the command description
  String? _extractDescription() {
    // Try simple single-line description first
    var match = RegexUtils.descriptionSimple.firstMatch(content);
    if (match != null) {
      return _cleanDescription(match.group(1) ?? '');
    }

    // Handle multi-line descriptions
    final startMatch = RegexUtils.descriptionStart.firstMatch(content);
    if (startMatch != null) {
      return _extractMultiLineDescription(startMatch.end);
    }

    return null;
  }

  /// Extracts multi-line description content
  String _extractMultiLineDescription(int startIndex) {
    final remaining = content.substring(startIndex);
    final endMatch = RegexUtils.methodEnd.firstMatch(remaining);

    if (endMatch == null) return '';

    final descriptionContent = remaining.substring(0, endMatch.start).trim();

    // Extract all quoted strings and join them
    final matches = RegexUtils.quotedString.allMatches(descriptionContent);
    final parts = matches.map((m) => m.group(1) ?? '').toList();

    return _cleanDescription(parts.join(''));
  }

  /// Cleans and formats description text
  String _cleanDescription(String description) {
    return description
        .replaceAll(r'\n\n', '\n\n') // Keep paragraph breaks
        .replaceAll(
          r'\n',
          '\n\n',
        ) // Convert single newlines to paragraph breaks
        .replaceAll('Usage:', '\n\n**Usage:**') // Format usage section
        .replaceAll('Example:', '\n\n**Example:**') // Format example section
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Replace multiple spaces with single space
        .replaceAll('\n\n \n\n', '\n\n') // Clean up extra spaces around breaks
        .trim();
  }

  /// Extracts command aliases from the getter
  List<String> _extractAliases() {
    final match = RegexUtils.aliasGetter.firstMatch(content);
    if (match == null) return [];

    final aliasesStr = match.group(1) ?? '';
    if (aliasesStr.trim().isEmpty) return [];

    // Extract quoted strings from the list
    return RegexUtils.quotedString
        .allMatches(aliasesStr)
        .map((m) => m.group(1) ?? '')
        .where((alias) => alias.isNotEmpty)
        .toList();
  }

  /// Extracts detailed usage information from the usage getter
  String _extractDetailedUsage() {
    // Look for usage getter with triple quotes
    final usagePattern = RegExp(
      r'''@override\s+String\s+get\s+usage\s*=>\s*['"]{3}(.*?)['"]{3};''',
      multiLine: true,
      dotAll: true,
    );

    final match = usagePattern.firstMatch(content);
    if (match != null) {
      return _cleanUsageText(match.group(1) ?? '');
    }

    // Try alternative patterns if triple quotes not found
    final simpleUsagePattern = RegExp(
      r'''@override\s+String\s+get\s+usage\s*=>\s*['"]([^'"]*?)['"];''',
      multiLine: true,
    );

    final simpleMatch = simpleUsagePattern.firstMatch(content);
    if (simpleMatch != null) {
      return _cleanUsageText(simpleMatch.group(1) ?? '');
    }

    return '';
  }

  /// Cleans and formats usage text
  String _cleanUsageText(String usageText) {
    var cleanedText = usageText
        .replaceAll(r'\n', '\n') // Handle escaped newlines
        .replaceAll(
          r'$description',
          description,
        ) // Replace description variable
        .replaceAll(
          r'$invocation',
          'gexd make $name',
        ) // Replace invocation variable
        .trim();

    // Replace ${argParser.usage} with formatted options
    if (cleanedText.contains(r'${argParser.usage}')) {
      final formattedOptions = _generateFormattedOptions();
      cleanedText = cleanedText.replaceAll(
        r'${argParser.usage}',
        formattedOptions,
      );
    }

    return cleanedText;
  }

  /// Generates formatted options text similar to command line help
  String _generateFormattedOptions() {
    final buffer = StringBuffer();

    // Add help option first (always present)
    buffer.writeln(
      '-h, --help                             Print this usage information.',
    );

    // Add other options
    for (final option in options) {
      final name = option['name'] as String;
      final help = option['help'] as String;
      final abbr = option['abbr'] as String;
      final defaultsTo = option['defaultsTo'] as String;
      final allowedValues = option['allowed'] as List<dynamic>? ?? [];
      final enumInfo = option['enumInfo'] as Map<String, dynamic>?;

      // Build option line
      var optionLine = '';
      if (abbr.isNotEmpty) {
        optionLine = '-$abbr, --$name';
      } else {
        optionLine = '    --$name';
      }

      // Add allowed values format
      if (enumInfo != null) {
        final values = enumInfo['values'] as List<dynamic>;
        final keys = values.map((v) => v['key']).join('|');
        optionLine += '=<$keys>';
      } else if (allowedValues.isNotEmpty) {
        optionLine += '=<${allowedValues.join('|')}>';
      } else if (name != 'help') {
        optionLine += '=<value>';
      }

      // Pad to consistent width and add help text
      optionLine = optionLine.padRight(40);
      buffer.writeln('$optionLine $help');

      // Add enum value descriptions with indentation
      if (enumInfo != null) {
        final values = enumInfo['values'] as List<dynamic>;
        for (final value in values) {
          final key = value['key'] as String;
          final description = value['description'] as String;
          final isDefault = defaultsTo == key;
          final defaultText = isDefault ? ' (default)' : '';
          buffer.writeln(
            '          [$key]${''.padRight(23 - key.length)} $description$defaultText',
          );
        }
        buffer.writeln(); // Empty line after enum descriptions
      }
    }

    // Add flags
    for (final flag in flags) {
      final name = flag['name'] as String;
      final help = flag['help'] as String;
      final abbr = flag['abbr'] as String;

      var flagLine = '';
      if (abbr.isNotEmpty) {
        flagLine = '-$abbr, --$name';
      } else {
        flagLine = '    --$name';
      }

      flagLine = flagLine.padRight(40);
      buffer.writeln('$flagLine $help');
    }

    return buffer.toString().trim();
  }

  /// Extracts detailed information about command options
  List<Map<String, dynamic>> _extractDetailedOptions() {
    final options = <Map<String, dynamic>>[];

    // Find the _setupArgs method content
    final setupArgsMatch = RegExp(
      r'void _setupArgs\(\)\s*\{(.*?)\n\s*\}',
      multiLine: true,
      dotAll: true,
    ).firstMatch(content);
    if (setupArgsMatch == null) return options;

    final setupArgsContent = setupArgsMatch.group(1) ?? '';

    // Split by addOption/addMultiOption calls
    final lines = setupArgsContent.split('\n');
    String currentOption = '';
    bool insideOption = false;
    bool isMulti = false;

    for (var line in lines) {
      line = line.trim();

      if (line.contains('..addOption(') || line.contains('..addMultiOption(')) {
        // Process previous option if exists
        if (insideOption && currentOption.isNotEmpty) {
          final option = _parseOptionContent(currentOption);
          if (option['name'].isNotEmpty) {
            option['type'] = isMulti ? 'multiOption' : 'option';
            option['enumInfo'] = _extractEnumInfo(option['name']);
            options.add(option);
          }
        }

        // Start new option
        insideOption = true;
        isMulti = line.contains('..addMultiOption(');
        currentOption = line.replaceFirst('..add', 'add');
      } else if (insideOption) {
        if (line.endsWith(')')) {
          // End of current option
          currentOption += '\n$line';
          final option = _parseOptionContent(currentOption);
          if (option['name'].isNotEmpty) {
            option['type'] = isMulti ? 'multiOption' : 'option';
            option['enumInfo'] = _extractEnumInfo(option['name']);
            options.add(option);
          }
          currentOption = '';
          insideOption = false;
        } else {
          // Continue building current option
          currentOption += '\n$line';
        }
      }
    }

    return options;
  }

  /// Parses the content inside addOption() or addMultiOption() calls
  Map<String, dynamic> _parseOptionContent(String content) {
    final option = <String, dynamic>{
      'name': '',
      'help': '',
      'allowed': <String>[],
      'abbr': '',
      'defaultsTo': '',
      'type': 'option',
    };

    // Extract option name (first quoted string)
    final nameMatch = RegExp(r'''['"]([^'"]+)['"]''').firstMatch(content);
    if (nameMatch != null) {
      option['name'] = nameMatch.group(1) ?? '';
    }

    // Extract help text
    final helpMatch = RegExp(
      r'''help:\s*['"]([^'"]*?)['"]''',
      multiLine: true,
      dotAll: true,
    ).firstMatch(content);
    if (helpMatch != null) {
      option['help'] = helpMatch.group(1) ?? '';
    }

    // Extract abbreviation
    final abbrMatch = RegExp(
      r'''abbr:\s*['"]([^'"]*?)['"]''',
    ).firstMatch(content);
    if (abbrMatch != null) {
      option['abbr'] = abbrMatch.group(1) ?? '';
    }

    // Extract defaultsTo
    final defaultMatch = RegExp(
      r'''defaultsTo:\s*['"]([^'"]*?)['"]''',
    ).firstMatch(content);
    if (defaultMatch != null) {
      option['defaultsTo'] = defaultMatch.group(1) ?? '';
    }

    // Extract allowed values
    final allowedMatch = RegExp(
      r'''allowed:\s*(\[[^\]]+\])''',
      multiLine: true,
      dotAll: true,
    ).firstMatch(content);
    if (allowedMatch != null) {
      final allowedContent = allowedMatch.group(1) ?? '';
      option['allowed'] = _parseAllowedValues(allowedContent);
    } else {
      // Check for enum references like ProjectTemplate.allKeys
      final enumMatch = RegExp(
        r'''allowed:\s*(\w+\.\w+)''',
      ).firstMatch(content);
      if (enumMatch != null) {
        final enumRef = enumMatch.group(1) ?? '';
        option['allowed'] = _parseEnumReference(enumRef);
      }
    }

    return option;
  }

  /// Extracts detailed information about command flags
  List<Map<String, dynamic>> _extractDetailedFlags() {
    final flags = <Map<String, dynamic>>[];

    final flagPattern = RegExp(
      r'''addFlag\(\s*['"]([^'"]+)['"]\s*,\s*(?:[^}]+help:\s*['"]([^'"]*)['"]\s*)?(?:[^}]+abbr:\s*['"]([^'"]*)['"]\s*)?(?:[^}]+defaultsTo:\s*(true|false))?''',
      multiLine: true,
      dotAll: true,
    );

    final matches = flagPattern.allMatches(content);

    for (final match in matches) {
      final flag = <String, dynamic>{
        'name': match.group(1) ?? '',
        'help': match.group(2) ?? '',
        'abbr': match.group(3) ?? '',
        'defaultsTo': match.group(4) ?? 'false',
      };

      flags.add(flag);
    }

    return flags;
  }

  /// Parses allowed values from option definition
  List<String> _parseAllowedValues(String allowedText) {
    if (allowedText.isEmpty) return [];

    // Look for enum references like ScreenType.allKeys
    final enumKeysPattern = RegExp(r'(\w+)\.allKeys');
    final enumMatch = enumKeysPattern.firstMatch(allowedText);

    if (enumMatch != null) {
      final enumName = enumMatch.group(1);
      return _getEnumKeys(enumName ?? '');
    }

    // Parse direct list values like ['android', 'ios', 'web']
    final listPattern = RegExp(r'\[(.*?)\]', dotAll: true);
    final listMatch = listPattern.firstMatch(allowedText);

    if (listMatch != null) {
      final listContent = listMatch.group(1) ?? '';
      return RegExp(r'''['"]([^'"]+)['"]''')
          .allMatches(listContent)
          .map((m) => m.group(1) ?? '')
          .where((value) => value.isNotEmpty)
          .toList();
    }

    return [];
  }

  /// Parses enum reference like ProjectTemplate.allKeys
  List<String> _parseEnumReference(String enumRef) {
    if (enumRef.contains('.allKeys')) {
      final enumName = enumRef.split('.').first;
      return _getEnumKeys(enumName);
    }
    return [];
  }

  /// Gets enum keys based on enum name
  List<String> _getEnumKeys(String enumName) {
    switch (enumName) {
      case 'ProjectTemplate':
        return ['getx', 'clean'];
      case 'ScreenType':
        return ['basic', 'form', 'withState'];
      case 'BindingLocation':
        return ['core', 'shared', 'screen'];
      default:
        return [];
    }
  }

  /// Extracts enum information for better documentation using analyzer
  Map<String, dynamic>? _extractEnumInfo(String optionName) {
    return EnumAnalyzer.extractEnumInfo(optionName, commandFilePath: filePath);
  }
}
