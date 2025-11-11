# `generate` Command 🌍

The **generate** command is a powerful tool for creating type-safe, feature-rich GetX locale translations from JSON files. It automatically generates Dart translation files with advanced features like variable replacement, smart pluralization, and compile-time safety through generated constants.

---

## 📝 Description

Generate GetX locale translations from JSON files with advanced features:
- 🔑 **Type-safe LocaleKeys** - Compile-time safety with generated constants
- 🔗 **Variable replacement** - Dynamic content with `trVars` 
- 🔢 **Smart pluralization** - Universal language support with `trCount`
- 🌐 **Multi-language support** - Arabic, English, and 100+ languages
- ⚡ **Hot reload friendly** - Real-time translation updates

---

## ⚙️ Usage

```bash
gexd locale generate [source_path] [options]
```

### Quick Start Examples

```bash
# Basic generation (default settings)
gexd locale generate assets/locales

# With sorted keys for better organization  
gexd locale generate assets/locales --sort-keys

# Specify custom key style
gexd locale generate assets/locales --key-style dot --sort-keys

# Interactive mode
gexd locale generate
```

---

## � Detailed Usage

### Command Syntax
```text
gexd locale generate <source_path> [options]

Arguments:
  source_path         Path to directory containing JSON locale files
                     (default: "assets/locales")

Options:
  --sort-keys        Sort translation keys alphabetically for better organization
  --key-style        Key naming style for generated LocaleKeys constants
  -h, --help         Show help information
```

### Input Structure
Your locale files should follow this structure:
```
assets/locales/
├── en_US.json      # English (United States)
├── ar_SA.json      # Arabic (Saudi Arabia)
├── es_ES.json      # Spanish (Spain)
├── fr_FR.json      # French (France)
└── de_DE.json      # German (Germany)
```

### Output Structure
The command generates a single translations file based on your project template:

**GetX Template:**
```
lib/app/locales/
└── translations.g.dart    # Generated translation keys
```

**Clean Template:**
```
lib/locales/
└── translations.g.dart    # Generated translation keys
```

---

## �🚩 Options & Flags

### `--sort-keys`
**Description:** Sort translation keys alphabetically in generated files

**Benefits:**
- Better code organization and readability
- Easier to find specific keys in large projects
- Consistent ordering across team members
- Improved version control diffs

**Example:**
```bash
gexd locale generate assets/locales --sort-keys
```

### `--key-style`
**Description:** Define naming style for generated LocaleKeys constants

**Available Styles:**
- `dot` - Convert dots to underscores: `app.name` → `app_name`
- `camel` - CamelCase style: `app.name` → `appName` 
- `snake` - Snake case style: `app.name` → `app_name`

**Example:**
```bash
gexd locale generate assets/locales --key-style dot
```

---

## 🌟 Advanced Features Generated

### 1. 🔑 Type-Safe LocaleKeys Class

The command automatically generates a `LocaleKeys` class with constants for all translation keys:

**Input JSON:**
```json
{
  "welcome": "Welcome",
  "app": {
    "name": "My App",
    "version": "Version {version}"
  },
  "validation": {
    "required": "{field} is required"
  }
}
```

**Generated LocaleKeys:**
```dart
class LocaleKeys {
  static const String welcome = 'welcome';
  static const String app_name = 'app.name';
  static const String app_version = 'app.version';
  static const String validation_required = 'validation.required';
}
```

**Usage Benefits:**
```dart
// ✅ Compile-time safety
Text(LocaleKeys.welcome.tr)

// ✅ IDE autocomplete
Text(LocaleKeys.app_name.tr)

// ✅ Refactoring support
Text(LocaleKeys.validation_required.trVars({'field': 'Email'}))
```

### 2. 🔗 Variable Replacement with `trVars`

**JSON Definition:**
```json
{
  "welcome": "Welcome {name}",
  "greeting": "Good {time}, {name}!",
  "app": {
    "version": "Version {version}"
  }
}
```

**Flutter Usage:**
```dart
// Dynamic content replacement
Text(LocaleKeys.welcome.trVars({'name': 'John'}))
// Output: "Welcome John"

Text(LocaleKeys.greeting.trVars({'name': 'Sarah', 'time': 'morning'}))
// Output: "Good morning, Sarah!"

Text(LocaleKeys.app_version.trVars({'version': '1.2.0'}))
// Output: "Version 1.2.0"
```

### 3. 🔢 Smart Pluralization with `trCount`

**English Pluralization:**
```json
{
  "items": {
    "__count": {
      "zero": "No items",
      "one": "One item", 
      "other": "{count} items"
    }
  }
}
```

**Arabic Advanced Pluralization:**
```json
{
  "notifications": {
    "__count": {
      "zero": "لا توجد إشعارات",
      "one": "لديك إشعار واحد",
      "two": "لديك إشعاران",
      "few": "لديك {count} إشعارات", 
      "many": "لديك {count} إشعاراً",
      "other": "لديك {count} إشعار"
    }
  }
}
```

**Flutter Usage:**
```dart
// Automatic plural form selection
Text(LocaleKeys.items.trCount({'count': '0'}))    // "No items"
Text(LocaleKeys.items.trCount({'count': '1'}))    // "One item" 
Text(LocaleKeys.items.trCount({'count': '5'}))    // "5 items"

// Arabic pluralization
Text(LocaleKeys.notifications.trCount({'count': '0'}))  // "لا توجد إشعارات"
Text(LocaleKeys.notifications.trCount({'count': '1'}))  // "لديك إشعار واحد"
Text(LocaleKeys.notifications.trCount({'count': '2'}))  // "لديك إشعاران"
Text(LocaleKeys.notifications.trCount({'count': '15'})) // "لديك 15 إشعاراً"
```

---

## 📁 Example Project Structure

### Input Files
```
assets/locales/
├── en_US.json
├── ar_SA.json
└── es.json
```

**en_US.json:**
```json
{
  "app": {
    "name": "Shopping App",
    "version": "Version {version}"
  },
  "welcome": "Welcome {name}",
  "buttons": {
    "login": "Login",
    "logout": "Logout",
    "checkout": "Checkout"
  },
  "validation": {
    "required": "{field} is required",
    "minLength": "{field} must be at least {min} characters"
  },
  "cart": {
    "items": {
      "__count": {
        "zero": "No items in cart",
        "one": "1 item in cart",
        "other": "{count} items in cart"
      }
    }
  }
}
```

**ar_SA.json:**
```json
{
  "app": {
    "name": "تطبيق التسوق",
    "version": "الإصدار {version}"
  },
  "welcome": "مرحباً {name}",
  "buttons": {
    "login": "تسجيل الدخول", 
    "logout": "تسجيل الخروج",
    "checkout": "الدفع"
  },
  "validation": {
    "required": "{field} مطلوب",
    "minLength": "{field} يجب أن يكون {min} أحرف على الأقل"
  },
  "cart": {
    "items": {
      "__count": {
        "zero": "لا توجد عناصر في السلة",
        "one": "عنصر واحد في السلة", 
        "two": "عنصران في السلة",
        "few": "{count} عناصر في السلة",
        "many": "{count} عنصراً في السلة",
        "other": "{count} عنصر في السلة"
      }
    }
  }
}
```

---

## 🚀 Real-World Usage Examples

### Variable Syntax Options

GetX supports two variable replacement syntaxes in your JSON files:

**1. Curly Brace Syntax** `{variable}` (Recommended)
```json
{
  "welcome": "Welcome {name}",
  "greeting": "Good {time}, {name}!",
  "item_count": "You have {count} items"
}
```

**2. GetX @ Syntax** `@variable`
```json
{
  "welcome": "Welcome @name",
  "greeting": "Good @time, @name!",
  "item_count": "You have @count items"
}
```

**Usage in Dart (Both syntaxes work identically):**
```dart
// Using trVars for variable replacement
Text(LocaleKeys.welcome.trVars({'name': userName})),
Text(LocaleKeys.greeting.trVars({'time': 'morning', 'name': userName})),

// Both JSON syntaxes produce the same Dart usage
Text(LocaleKeys.item_count.trVars({'count': itemCount.toString()})),
```

### Shopping Cart Widget
```dart
class CartWidget extends StatelessWidget {
  final int itemCount;
  final String userName;
  final String appVersion;

  Widget build(BuildContext context) {
    return Column(
      children: [
        // App header with version
        Text(LocaleKeys.app_version.trVars({'version': appVersion})),
        
        // Welcome user
        Text(LocaleKeys.welcome.trVars({'name': userName})),
        
        // Cart items with smart pluralization
        Text(LocaleKeys.cart_items.trCount({'count': itemCount.toString()})),
        
        // Action buttons
        ElevatedButton(
          onPressed: _checkout,
          child: Text(LocaleKeys.buttons_checkout.tr),
        ),
      ],
    );
  }
}
```

### Form Validation
```dart
class CustomValidator {
  static String? validateField(String? value, String fieldName) {
    if (value?.isEmpty ?? true) {
      return LocaleKeys.validation_required.trVars({'field': fieldName});
    }
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return LocaleKeys.validation_minLength.trVars({
        'field': 'Password',
        'min': '8'
      });
    }
    return null;
  }
}
```

---

## 💡 Best Practices

### ✅ Translation File Organization
```json
{
  "app": {
    "name": "App Name",
    "version": "Version {version}"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout"
  },
  "validation": {
    "required": "{field} is required",
    "minLength": "{field} must be at least {min} characters"
  }
}
```

### ✅ Pluralization Guidelines
- Always provide `other` as fallback
- Use language-specific plural rules
- Test with edge cases (0, 1, 2, large numbers)
- Include variables in plural forms when needed

### ✅ Variable Naming
- Use descriptive names: `{userName}` not `{a}`
- Be consistent across languages
- Document expected variables in code comments

### ✅ LocaleKeys Usage
```dart
// ✅ Recommended - Type-safe
Text(LocaleKeys.welcome.trVars({'name': userName}))

// ❌ Avoid - Runtime errors possible  
Text('welcome'.trVars({'name': userName}))
```

---

## 🔧 Integration with GetX

### Setup in main.dart
```dart
import 'package:get/get.dart';
import 'generated/translations.g.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: LocaleKeys.app_name.tr,
      translations: Translations(),
      locale: Get.deviceLocale,
      fallbackLocale: Locale('en'),
      home: HomeScreen(),
    );
  }
}
```

### Dynamic Language Switching
```dart
// Change language at runtime
Get.updateLocale(Locale('ar'));  // Switch to Arabic
Get.updateLocale(Locale('en'));  // Switch to English

// Get current locale
Locale currentLocale = Get.locale ?? Locale('en');
```

---

## 🐛 Troubleshooting

### Common Issues

**Issue:** LocaleKeys class not generated  
**Solution:** Ensure JSON files are valid and run the command again

**Issue:** Variables not working  
**Solution:** Check variable syntax `{variableName}` in JSON

**Issue:** Pluralization not working  
**Solution:** Verify `__count` structure in JSON files

**Issue:** Translations not updating  
**Solution:** Hot restart the app after generating new translations

### Validation Tips
- Validate JSON syntax before generation
- Test all plural forms in your target languages
- Verify variable names match between JSON and code
- Check that all required languages have the same keys

---

## 📚 Related Resources

- **[LOCALE_FEATURES.md](../../example/assets/LOCALE_FEATURES.md)** - Advanced usage examples
- **[GetX Documentation](https://github.com/jonataslaw/getx)** - GetX internationalization
- **[Flutter Intl](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)** - Flutter internationalization guide

---

_Generated automatically by `gexd_doc` | Enhanced with comprehensive examples and best practices_
