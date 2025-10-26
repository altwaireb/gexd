import 'package:grammer/grammer.dart';

import 'recase.dart';

/// String helper utilities for text transformations
///
/// Uses enhanced ReCase implementation with improved acronym handling
class StringHelpers {
  StringHelpers._();

  /// Convert PascalCase to snake_case
  /// Handles common acronyms properly (XML, API, HTML, etc.)
  ///
  /// Examples:
  /// - UserToken -> user_token
  /// - PaymentGateway -> payment_gateway
  /// - XMLParser -> xml_parser (not x_m_l_parser)
  /// - Auth -> auth
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).snakeCase;
  }

  /// Convert snake_case to PascalCase
  ///
  /// Examples:
  /// - user_token -> UserToken
  /// - payment_gateway -> PaymentGateway
  /// - auth -> Auth
  static String toPascalCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).pascalCase;
  }

  /// Convert string to camelCase
  ///
  /// Examples:
  /// - user_token -> userToken
  /// - payment_gateway -> paymentGateway
  /// - Auth -> auth
  static String toCamelCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).camelCase;
  }

  /// Convert string to kebab-case (param-case)
  ///
  /// Examples:
  /// - UserToken -> user-token
  /// - PaymentGateway -> payment-gateway
  /// - Auth -> auth
  static String toKebabCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).paramCase;
  }

  /// Convert string to CONSTANT_CASE
  ///
  /// Examples:
  /// - UserToken -> USER_TOKEN
  /// - PaymentGateway -> PAYMENT_GATEWAY
  /// - Auth -> AUTH
  static String toConstantCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).constantCase;
  }

  /// Convert string to dot.case
  ///
  /// Examples:
  /// - UserToken -> user.token
  /// - PaymentGateway -> payment.gateway
  /// - Auth -> auth
  static String toDotCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).dotCase;
  }

  /// Convert string to path/case
  ///
  /// Examples:
  /// - UserToken -> user/token
  /// - PaymentGateway -> payment/gateway
  /// - Auth -> auth
  static String toPathCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).pathCase;
  }

  /// Convert string to Sentence case
  ///
  /// Examples:
  /// - UserToken -> User token
  /// - PaymentGateway -> Payment gateway
  /// - Auth -> Auth
  static String toSentenceCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).sentenceCase;
  }

  /// Convert string to Title Case
  ///
  /// Examples:
  /// - UserToken -> User Token
  /// - PaymentGateway -> Payment Gateway
  /// - Auth -> Auth
  static String toTitleCase(String input) {
    if (input.isEmpty) return input;
    return ReCase(input).titleCase;
  }

  /// Check if string is in PascalCase format
  ///
  /// Examples:
  /// - UserToken -> true
  /// - userToken -> false
  /// - user_token -> false
  static bool isPascalCase(String input) {
    if (input.isEmpty) return false;
    return RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(input);
  }

  /// Check if string is in camelCase format
  ///
  /// Examples:
  /// - userToken -> true
  /// - UserToken -> false
  /// - user_token -> false
  static bool isCamelCase(String input) {
    if (input.isEmpty) return false;
    return RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(input);
  }

  /// Check if string is in snake_case format
  ///
  /// Examples:
  /// - user_token -> true
  /// - UserToken -> false
  /// - userToken -> false
  static bool isSnakeCase(String input) {
    if (input.isEmpty) return false;
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(input);
  }

  /// Capitalize first letter
  ///
  /// Examples:
  /// - hello -> Hello
  /// - WORLD -> WORLD
  /// - '' -> ''
  static String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  /// Uncapitalize first letter
  ///
  /// Examples:
  /// - Hello -> hello
  /// - WORLD -> wORLD
  /// - '' -> ''
  static String uncapitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }

  /// Convert to singular form
  ///
  /// Examples:
  /// - users -> user
  /// - categories -> category
  static String toSingular(String input) {
    if (input.isEmpty) return input;
    return Grammer(input).toSingular();
  }

  /// Convert to plural form
  ///
  /// Examples:
  /// - user -> users
  /// - category -> categories
  static String toPlural(String input) {
    if (input.isEmpty) return input;
    return Grammer(input).toPlural().first;
  }

  /// Check if string is plural
  ///
  /// Examples:
  /// - users -> true
  /// - user -> false
  static bool isPlural(String input) {
    if (input.isEmpty) return false;
    return Grammer(input).isPlural();
  }

  /// Check if string is singular
  ///
  /// Examples:
  /// - user -> true
  /// - users -> false
  static bool isSingular(String input) {
    if (input.isEmpty) return false;
    return Grammer(input).isSingular();
  }

  /// Check if string is countable noun
  ///
  /// Examples:
  /// - apple -> true
  /// - information -> false
  static bool isCountable(String input) {
    if (input.isEmpty) return false;
    return Grammer(input).isCountable();
  }

  /// Check if string is uncountable noun
  ///
  /// Examples:
  /// - information -> true
  /// - apple -> false
  static bool isNotCountable(String input) {
    if (input.isEmpty) return false;
    return Grammer(input).isNotCountable();
  }

  /// Check if two strings are similar (case insensitive)
  ///
  /// Examples:
  /// - 'User' and 'user' -> true
  /// - 'User' and 'Admin' -> false
  static bool isSimilar(String first, String second) {
    if (first.isEmpty || second.isEmpty) return false;
    return first.toLowerCase() == second.toLowerCase();
  }
}
