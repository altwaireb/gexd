# Assets Examples for Gexd CLI

This directory contains example files that demonstrate how to use various Gexd CLI commands with different data sources.

## 📂 Directory Structure

```
assets/
├── models/           # JSON examples for model generation
│   └── user.json     # User model with nested objects
└── locales/          # Locale files for internationalization
    ├── en_US.json    # English (US) translations
    ├── ar_SA.json    # Arabic (Saudi Arabia) translations (RTL)
    └── fr_FR.json    # French (France) translations
```

## 🗂️ Model Example

### User Model (`models/user.json`)
**Usage:**
```bash
gexd make model User --file example/assets/models/user.json --immutable --copyWith
```

**Features Demonstrated:**
- Nested objects (profile, preferences, social)
- Different data types (string, int, bool, datetime)
- Complex object structures
- API-style timestamps

**Generated Classes:**
- `User` (main model)
- `UserProfile` (nested profile data)
- `UserPreferences` (user settings)
- `UserSocial` (social media links)
- `UserNotifications` (notification preferences)

## 🌍 Locale Examples

### Multi-language Support
**Usage:**
```bash
gexd locale generate assets/locales --key-style dot --sort-keys
```

**Supported Languages:**
- **English (`en_US.json`)**: Base language with complete translations
- **Arabic (`ar_SA.json`)**: RTL language with rich pluralization support
- **French (`fr_FR.json`)**: European language variant

**🚀 Advanced Features:**

#### 1. Variable Replacement (`trVars`)
```dart
// Dynamic content with variables
Text('welcome'.trVars({'name': 'John'})) // "Welcome John"
Text('greeting'.trVars({'name': 'Ali', 'time': 'morning'})) // "Good morning, Ali!"
```

#### 2. Smart Pluralization (`trCount`)
```dart
// Universal pluralization for all languages
Text('items'.trCount({'count': '0'})) // "No items"
Text('items'.trCount({'count': '1'})) // "One item" 
Text('items'.trCount({'count': '5'})) // "5 items"

// Arabic with rich plural forms (zero, one, two, few, many, other)
Text('notifications'.trCount({'count': '2'})) // "لديك إشعاران"
Text('notifications'.trCount({'count': '15'})) // "لديك 15 إشعاراً"
```

#### 3. Combined Features
```dart
// Pluralization with additional variables
Text('messages'.trCount({'count': '5', 'sender': 'Ali'})) // "5 messages from Ali"
```

### Key Features:
- **Variable Replacement**: Dynamic content with `{variable}` syntax
- **Universal Pluralization**: Support for zero, one, two, few, many, other
- **Multi-variable Support**: Combine count with other variables
- **RTL Support**: Proper Arabic text and pluralization
- **Language-Specific Rules**: Customize plural forms per language

📖 **[See LOCALE_FEATURES.md](LOCALE_FEATURES.md) for complete usage examples and best practices**

## 🚀 Quick Examples

### Generate User Model from Example
```bash
# Generate a User model with all features
gexd make model User --file example/assets/models/user.json \
  --immutable --copyWith --equatable --style json

# Generate User model in subdirectory
gexd make model User --file example/assets/models/user.json \
  --on auth/models --style freezed

# Generate User model with relationships in separate folder
gexd make model User --file example/assets/models/user.json \
  --relationships-in-folder --immutable --copyWith
```

### Generate Locales from Examples  
```bash
# Generate translations with dot notation
gexd locale generate example/assets/locales \
  --key-style dot --sort-keys --force

# Generate with camelCase keys
gexd locale generate example/assets/locales \
  --key-style camelCase --output lib/l10n/translations.g.dart
```

## 💡 Tips for Using These Examples

1. **Copy to Your Project**: Copy these files to your project's assets folder
2. **Modify as Needed**: Customize the JSON structure for your specific needs
3. **Test Different Styles**: Try different `--style` options (plain, json, freezed)
4. **Use Relationships**: Enable `--relationships-in-folder` for complex models
5. **Add More Languages**: Create additional locale files following the same structure

## 🔧 Advanced Usage Patterns

### Combining Model Features
```bash
# Full-featured model generation
gexd make model User --file assets/models/user.json \
  --style freezed --immutable --copyWith --equatable \
  --relationships-in-folder --on auth/models --force
```

### Custom Locale Generation
```bash
# Advanced locale generation with custom output
gexd locale generate assets/locales \
  --key-style snake --output lib/core/translations.dart \
  --sort-keys --force
```

These examples provide a solid foundation for understanding how Gexd CLI can generate production-ready code from simple JSON files! 🎉