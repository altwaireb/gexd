import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import '../config/doc_config.dart';

/// Automatically extracts enum information using Dart analyzer
///
/// This class uses the Dart analyzer package to parse enum files and extract
/// detailed information including enum values, descriptions, and metadata.
/// Falls back to regex-based extraction if analyzer fails.
class EnumAnalyzer {
  /// Extracts enum information for a given option name
  ///
  /// Uses analyzer to parse enum files and extract complete information.
  /// Falls back to manual extraction if analyzer approach fails.
  static Map<String, dynamic>? extractEnumInfo(
    String optionName, {
    String? commandFilePath,
  }) {
    try {
      // Try analyzer approach first
      final enumInfo = _extractWithAnalyzer(
        optionName,
        commandFilePath: commandFilePath,
      );
      if (enumInfo != null) return enumInfo;

      // Fallback to manual approach
      return _extractManually(optionName);
    } catch (e) {
      // If anything fails, use manual extraction
      return _extractManually(optionName);
    }
  }

  /// Extracts enum info using Dart analyzer (preferred method)
  static Map<String, dynamic>? _extractWithAnalyzer(
    String optionName, {
    String? commandFilePath,
  }) {
    final enumName = _mapOptionToEnumName(
      optionName,
      commandFilePath: commandFilePath,
    );
    if (enumName == null) return null;

    // Get enum file path
    final enumPath = DocConfig.enumPaths[enumName];
    if (enumPath == null) {
      // Try auto-discovery
      final discoveredPath = _discoverEnumPath(enumName);
      if (discoveredPath == null) return null;
      return _parseEnumFile(discoveredPath, enumName);
    }

    return _parseEnumFile(enumPath, enumName);
  }

  /// Parses enum file using analyzer
  static Map<String, dynamic>? _parseEnumFile(
    String filePath,
    String enumName,
  ) {
    final file = File(filePath);
    if (!file.existsSync()) return null;

    try {
      final result = parseFile(
        path: file.absolute.path,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      final visitor = EnumVisitor(enumName);
      result.unit.accept(visitor);

      return visitor.enumInfo;
    } catch (e) {
      // If analyzer fails, return null to trigger fallback
      return null;
    }
  }

  /// Discovers enum file path automatically
  static String? _discoverEnumPath(String enumName) {
    for (final searchDir in DocConfig.possibleEnumPaths) {
      final dir = Directory(searchDir);
      if (!dir.existsSync()) continue;

      // Look for files that might contain this enum
      final files = dir
          .listSync()
          .where((entity) => entity is File && entity.path.endsWith('.dart'))
          .cast<File>();

      for (final file in files) {
        // Check if file name matches enum pattern
        final fileName = p.basenameWithoutExtension(file.path);
        if (_isEnumFileMatch(fileName, enumName)) {
          return file.path;
        }
      }
    }
    return null;
  }

  /// Checks if file name matches enum name pattern
  static bool _isEnumFileMatch(String fileName, String enumName) {
    // Convert PascalCase to snake_case for comparison
    final snakeCaseEnum = _pascalToSnakeCase(enumName);
    return fileName.toLowerCase() == snakeCaseEnum.toLowerCase();
  }

  /// Converts PascalCase to snake_case
  static String _pascalToSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => '_${match.group(1)!.toLowerCase()}',
        )
        .substring(1); // Remove leading underscore
  }

  /// Maps option name to enum name using direct code analysis
  static String? _mapOptionToEnumName(
    String optionName, {
    String? commandFilePath,
  }) {
    if (commandFilePath != null) {
      return _analyzeCommandForEnumType(commandFilePath, optionName);
    }

    // Fallback to basic mapping if no command file provided
    final mapping = {
      'template': 'ProjectTemplate',
      'component': 'NameComponent',
    };
    return mapping[optionName];
  }

  /// Analyzes command file to determine enum type for specific option
  static String? _analyzeCommandForEnumType(
    String commandFilePath,
    String optionName,
  ) {
    final file = File(commandFilePath);
    if (!file.existsSync()) return null;

    try {
      final result = parseFile(
        path: file.absolute.path,
        featureSet: FeatureSet.latestLanguageVersion(),
      );

      final visitor = CommandAnalysisVisitor(optionName);
      result.unit.accept(visitor);

      return visitor.foundEnumType;
    } catch (e) {
      return null;
    }
  }

  /// Fallback manual extraction (keeps existing regex approach)
  static Map<String, dynamic>? _extractManually(String optionName) {
    final enumMappings = {
      'template': 'ProjectTemplate',
      'type': 'ScreenType',
      'location': 'BindingLocation',
      'component': 'NameComponent',
    };

    final enumName = enumMappings[optionName];
    if (enumName == null) return null;

    switch (enumName) {
      case 'ProjectTemplate':
        return {
          'name': 'ProjectTemplate',
          'values': [
            {'key': 'getx', 'description': 'GetX modular design.'},
            {'key': 'clean', 'description': 'Layered DDD design.'},
          ],
        };
      case 'ScreenType':
        return {
          'name': 'ScreenType',
          'values': [
            {'key': 'basic', 'description': 'Simple screen setup.'},
            {'key': 'form', 'description': 'Form with validation.'},
            {'key': 'withState', 'description': 'Reactive data screen.'},
          ],
        };
      case 'BindingLocation':
        return {
          'name': 'BindingLocation',
          'values': [
            {
              'key': 'core',
              'description': 'Global application bindings in core folder.',
            },
            {
              'key': 'shared',
              'description': 'Shared bindings in shared folder.',
            },
            {
              'key': 'screen',
              'description': 'Screen-specific bindings in screen folder.',
            },
          ],
        };
      case 'NameComponent':
        return {
          'name': 'NameComponent',
          'values': [
            {'key': 'pascal', 'description': 'PascalCase naming.'},
            {'key': 'camel', 'description': 'camelCase naming.'},
            {'key': 'snake', 'description': 'snake_case naming.'},
          ],
        };
      default:
        return null;
    }
  }
}

/// AST visitor to analyze command files for enum types
class CommandAnalysisVisitor extends RecursiveAstVisitor<void> {
  final String targetOptionName;
  String? foundEnumType;

  CommandAnalysisVisitor(this.targetOptionName);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Look for addOption calls
    if (node.methodName.name == 'addOption') {
      _analyzeAddOptionCall(node);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Look for Option constructors
    final typeName = node.constructorName.type.name.lexeme;
    if (typeName == 'Option') {
      _analyzeOptionConstructor(node);
    }
    super.visitInstanceCreationExpression(node);
  }

  void _analyzeAddOptionCall(MethodInvocation node) {
    final args = node.argumentList.arguments;

    for (final arg in args) {
      if (arg is NamedExpression && arg.name.label.name == 'name') {
        final nameValue = _extractStringValue(arg.expression);
        if (nameValue == targetOptionName) {
          // Found our option, now look for allowed values or type info
          _extractEnumTypeFromArguments(args);
          return;
        }
      }
    }
  }

  void _analyzeOptionConstructor(InstanceCreationExpression node) {
    final args = node.argumentList.arguments;

    // Check if this is our target option
    String? optionName;
    for (final arg in args) {
      if (arg is NamedExpression && arg.name.label.name == 'name') {
        optionName = _extractStringValue(arg.expression);
        break;
      }
    }

    if (optionName == targetOptionName) {
      _extractEnumTypeFromArguments(args.cast<Expression>());
    }
  }

  void _extractEnumTypeFromArguments(List<Expression> args) {
    for (final arg in args) {
      if (arg is NamedExpression) {
        // Look for allowed values or similar patterns
        if (arg.name.label.name == 'allowed' ||
            arg.name.label.name == 'allowedValues') {
          foundEnumType = _inferEnumTypeFromValues(arg.expression);
          if (foundEnumType != null) return;
        }
      }
    }

    // If no direct enum reference found, try to infer from usage patterns
    _inferEnumTypeFromContext();
  }

  String? _inferEnumTypeFromValues(Expression expression) {
    // Try to extract enum type from allowed values
    if (expression is ListLiteral) {
      final elements = expression.elements;
      if (elements.isNotEmpty) {
        // Look for enum value patterns
        for (final element in elements) {
          if (element is PropertyAccess) {
            final target = element.target;
            if (target is Identifier) {
              return target.name; // This should be the enum class name
            }
          }
        }
      }
    }
    return null;
  }

  void _inferEnumTypeFromContext() {
    // Context-based inference based on option name and command context
    switch (targetOptionName) {
      case 'type':
        // Could be ScreenType, ProviderType, etc. - need more context
        foundEnumType = _inferTypeEnum();
        break;
      case 'location':
        // Could be BindingLocation, ControllerLocation, etc.
        foundEnumType = _inferLocationEnum();
        break;
    }
  }

  String? _inferTypeEnum() {
    // This will be enhanced to analyze the command class name or imports
    // For now, default behavior
    return 'ScreenType';
  }

  String? _inferLocationEnum() {
    // This will be enhanced to analyze the command class name or imports
    // For now, default behavior
    return 'BindingLocation';
  }

  String? _extractStringValue(Expression expression) {
    if (expression is SimpleStringLiteral) {
      return expression.value;
    }
    return null;
  }
}

/// AST visitor to extract enum information
class EnumVisitor extends RecursiveAstVisitor<void> {
  final String targetEnumName;
  Map<String, dynamic>? enumInfo;

  EnumVisitor(this.targetEnumName);

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    if (node.name.lexeme == targetEnumName) {
      final values = <Map<String, dynamic>>[];

      for (final constant in node.constants) {
        final enumValue = _extractEnumConstant(constant);
        if (enumValue != null) {
          values.add(enumValue);
        }
      }

      enumInfo = {'name': targetEnumName, 'values': values};
    }
    super.visitEnumDeclaration(node);
  }

  /// Extracts information from enum constant
  Map<String, dynamic>? _extractEnumConstant(EnumConstantDeclaration constant) {
    final name = constant.name.lexeme;

    // Look for constructor arguments to extract key and description
    final arguments = constant.arguments?.argumentList.arguments;
    if (arguments == null) return {'key': name, 'description': ''};

    String? key;
    String? description;

    for (final arg in arguments) {
      if (arg is NamedExpression) {
        final paramName = arg.name.label.name;
        final value = _extractStringValue(arg.expression);

        if (paramName == 'key') {
          key = value;
        } else if (paramName == 'description') {
          description = value;
        }
      }
    }

    return {'key': key ?? name.toLowerCase(), 'description': description ?? ''};
  }

  /// Extracts string value from expression
  String? _extractStringValue(Expression expression) {
    if (expression is SimpleStringLiteral) {
      return expression.value;
    }
    return null;
  }
}
