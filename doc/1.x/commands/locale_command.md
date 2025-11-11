# `locale` Command

---

## 📝 Description

Manage GetX locale translations with powerful internationalization tools. The `locale` command provides comprehensive translation management for Flutter applications, including automatic code generation, multi-language support, and advanced features like variable replacement and smart pluralization.

---

## ⚙️ Usage

```bash
gexd locale <subcommand> [options]
```

---

## 🧩 Aliases

`l`

---

## 📚 Available Subcommands

### 🌍 **Translation Management**

#### [`generate`](locales/generate_command.md)
**Description:** Generate GetX locale translations from JSON files with advanced features
```bash
gexd locale generate assets/locales
gexd locale generate assets/locales --sort-keys --key-style dot
```

**Key Features:**
- 🔑 **Type-safe LocaleKeys** - Compile-time safety with generated constants
- 🔗 **Variable replacement** - Dynamic content with `trVars({})` 
- 🔢 **Smart pluralization** - Universal language support with `trCount({})`
- 🌐 **Multi-language support** - Arabic, English, and 100+ languages
- ⚡ **Hot reload friendly** - Real-time translation updates

---

## 🚀 Common Usage Patterns

### 📄 **Basic Translation Setup**
```bash
# 1. Create locale files structure
mkdir -p assets/locales
echo '{"welcome": "Welcome {name}"}' > assets/locales/en_US.json
echo '{"welcome": "مرحباً {name}"}' > assets/locales/ar_SA.json

# 2. Generate translations
gexd locale generate assets/locales --sort-keys
```

### 🎯 **Advanced Multi-language Project**
```bash
# Generate with all features enabled
gexd locale generate assets/locales \
  --key-style dot \
  --sort-keys \
  --output lib/generated/translations.g.dart
```

### 🔄 **Development Workflow**
```bash
# 1. Create/update your locale JSON files
# assets/locales/en_US.json, assets/locales/ar_SA.json, etc.

# 2. Generate translations with hot reload support
gexd locale generate assets/locales --sort-keys

# 3. Use in your Flutter app
# Text(LocaleKeys.welcome.trVars({'name': userName}))
```

---

## 🎯 Supported Features

### 🔑 **Type-Safe Translations**
- **LocaleKeys Generation**: Compile-time safety for all translation keys
- **IDE Autocomplete**: Full IntelliSense support for translation keys
- **Refactoring Support**: Safe renaming and deletion of translation keys

### 🌐 **Multi-Language Support**
- **JSON-Based**: Simple JSON file structure for translations
- **Nested Keys**: Support for hierarchical translation organization
- **Variable Syntax**: Both `{variable}` and `@variable` formats supported

### 🔗 **Dynamic Content**
- **Variable Replacement**: `LocaleKeys.welcome.trVars({'name': 'Ahmed'})`
- **Smart Pluralization**: `LocaleKeys.items.trCount({'count': '5'})`
- **Combined Features**: Variables + pluralization in single translation

### 📁 **Project Integration**
- **GetX Template**: Generates to `lib/app/locales/translations.g.dart`
- **Clean Template**: Generates to `lib/locales/translations.g.dart`
- **Custom Output**: Specify your own output location

---

## 📖 Translation File Structure

### **Input Structure (JSON Files)**
```
assets/locales/
├── en_US.json    # English (United States)
├── ar_SA.json    # Arabic (Saudi Arabia)  
├── es_ES.json    # Spanish (Spain)
├── fr_FR.json    # French (France)
└── de_DE.json    # German (Germany)
```

### **Example JSON Content**
```json
{
  "app": {
    "name": "My App",
    "version": "Version {version}"
  },
  "welcome": "Welcome {name}",
  "items": {
    "__count": {
      "zero": "No items",
      "one": "One item", 
      "other": "{count} items"
    }
  }
}
```

### **Generated Output**
```dart
// lib/generated/translations.g.dart
class LocaleKeys {
  static const String app_name = 'app.name';
  static const String app_version = 'app.version';
  static const String welcome = 'welcome';
  static const String items = 'items';
}
```

---

## 🚀 Real-World Examples

### 📱 **Shopping App Translations**
```bash
# Create comprehensive e-commerce translations
cat > assets/locales/en_US.json << 'EOF'
{
  "app": {
    "name": "ShopApp",
    "version": "Version {version}"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout",
    "welcome": "Welcome back, {name}!"
  },
  "cart": {
    "items": {
      "__count": {
        "zero": "Your cart is empty",
        "one": "1 item in cart",
        "other": "{count} items in cart"
      }
    },
    "total": "Total: ${amount}"
  },
  "validation": {
    "required": "{field} is required",
    "email": "Please enter a valid email"
  }
}
EOF

# Generate with optimal settings
gexd locale generate assets/locales --key-style dot --sort-keys
```

### 🌍 **Multi-Regional App**
```bash
# Arabic (Saudi Arabia)
cat > assets/locales/ar_SA.json << 'EOF'
{
  "app": {
    "name": "تطبيقي"
  },
  "welcome": "مرحباً {name}",
  "notifications": {
    "__count": {
      "zero": "لا توجد إشعارات",
      "one": "إشعار واحد",
      "two": "إشعاران", 
      "few": "{count} إشعارات",
      "many": "{count} إشعاراً",
      "other": "{count} إشعار"
    }
  }
}
EOF

# Generate with full Arabic support
gexd locale generate assets/locales --sort-keys
```

---

## 💡 Best Practices

### 🎯 **File Organization**
1. **Use Locale Codes**: `en_US.json`, `ar_SA.json` instead of simple `en.json`
2. **Consistent Structure**: Keep the same key structure across all languages
3. **Logical Grouping**: Group related translations under common parents

### 🔧 **Development Workflow**
1. **Start Simple**: Begin with basic translations, add features incrementally
2. **Use --sort-keys**: Keep translations organized and version-control friendly
3. **Test Pluralization**: Verify plural forms work correctly for each language
4. **Hot Reload**: Generate translations during development for immediate feedback

### 🌐 **Translation Quality**
1. **Native Speakers**: Use native speakers for translation accuracy
2. **Context Aware**: Provide context for translators about variable usage
3. **Plural Forms**: Research correct plural forms for each target language
4. **Cultural Adaptation**: Consider cultural differences, not just language translation

---

## 🔧 Advanced Configuration

### **Custom Output Locations**
```bash
# GetX architecture  
gexd locale generate assets/locales --output lib/app/locales/translations.g.dart

# Clean architecture
gexd locale generate assets/locales --output lib/locales/translations.g.dart

# Custom location
gexd locale generate assets/locales --output lib/core/i18n/app_translations.dart
```

### **Key Naming Conventions**
```bash
# Dot notation (recommended)
gexd locale generate assets/locales --key-style dot
# Output: LocaleKeys.auth_login, LocaleKeys.cart_items

# CamelCase notation  
gexd locale generate assets/locales --key-style camelCase
# Output: LocaleKeys.authLogin, LocaleKeys.cartItems

# Snake case notation
gexd locale generate assets/locales --key-style snake
# Output: LocaleKeys.auth_login, LocaleKeys.cart_items
```

---

## 📖 Documentation Links

For detailed documentation on locale subcommands:
- [Generate Command](locales/generate_command.md) - Comprehensive translation generation guide

---

## 🎯 Quick Reference

### **Most Common Commands**
```bash
# Basic setup
gexd locale generate assets/locales

# Production ready
gexd locale generate assets/locales --sort-keys --key-style dot

# Development with custom output
gexd locale generate assets/locales --sort-keys --output lib/l10n/translations.g.dart
```

### **Usage in Flutter**
```dart
import 'package:get/get.dart';
import 'generated/translations.g.dart';

// Simple translation
Text(LocaleKeys.welcome.tr)

// With variables
Text(LocaleKeys.welcome.trVars({'name': 'Ahmed'}))

// With pluralization  
Text(LocaleKeys.items.trCount({'count': itemCount.toString()}))

// Combined features
Text(LocaleKeys.cart_items.trCount({'count': count.toString(), 'user': userName}))
```

---

_Generated automatically by `gexd_doc`_
