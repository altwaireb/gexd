# `model` Command

---

## 📝 Description

Generate type-safe Dart model files from JSON sources with advanced features like nested relationships, serialization, immutability, and complex data structures. Perfect for API integration and data modeling.

---

## ⚙️ Usage

```bash
gexd make model [<name>] [options]
```

---

## 🚀 Key Features

### 🎯 **Multiple Data Sources**
- **JSON Files**: Generate from local JSON files
- **API Endpoints**: Fetch and generate from live APIs
- **Interactive Templates**: Guided model creation

### 🏗️ **Advanced Architecture Support**
- **GetX Templates**: Modular feature-based architecture
- **Clean Architecture**: Domain-driven design with layered structure
- **Custom Organization**: Flexible subdirectory placement

### 🔧 **Model Features**
- **Type Safety**: Automatic type detection and conversion
- **Nested Objects**: Complex relationship handling
- **Immutable Models**: Thread-safe data structures
- **Serialization**: JSON to/from Dart conversion
- **Equatable Integration**: Value equality comparison

### 📁 **Relationship Management**
- **Automatic Detection**: Smart identification of nested objects
- **Separate Folder Generation**: Organized relationship files
- **Dependency Resolution**: Proper import management

---

## 📖 Detailed Usage

```text
Generate model files

Usage: gexd make model [<name>] [options]

Arguments:
  <name>          Model name (e.g., User, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-f, --file=<value>                     Path to JSON file for model generation
-u, --url=<value>                      URL to fetch JSON data for model generation
-t, --template=<basic|custom>          Choose starter template for model generation
          [basic]                      Basic model template
          [custom]                     Custom interactive template

-s, --style=<plain|json|freezed>       Choose model generation style
          [plain]                      Simple Dart classes
          [json]                       JSON serializable models
          [freezed]                    Immutable data classes with Freezed

-r, --relationships-in-folder          Generate relationships in separate <model>_relationships folder
-i, --immutable                        Generate immutable model with final fields
-c, --copyWith                         Add copyWith method for creating modified copies
-e, --equatable                        Use Equatable package for value equality comparison
    --on=<path>                        Specify subdirectory path (max 3 levels)
    --force                            Force overwrite existing files without prompting

Examples:
  gexd make model                                        # Interactive mode
  gexd make model User                                   # Smart mode (interactive if exists)

  # Model from template (default):
  gexd make model User                                   # Basic template
  gexd make model User --template custom                # Custom interactive template

  # Model from JSON file:
  gexd make model User --file assets/models/user.json   # From local file

  # Model from API endpoint:
  gexd make model User --url https://api.example.com/user/123

  # Model with advanced features:
  gexd make model User --immutable --copyWith --equatable

  # Model with different styles:
  gexd make model User --style json                     # JSON serializable
  gexd make model User --style freezed --immutable      # Freezed style

  # Model with relationship management:
  gexd make model User --file assets/models/user.json --relationships-in-folder

  # Model in subdirectory:
  gexd make model User --on auth/models                 # Model in subdirectory
```

---

## 🎯 Real-World Examples

### 📄 **Example JSON Input**

Create a file `assets/models/user.json`:
```json
{
  "id": 1,
  "name": "Ahmed Ali",
  "email": "ahmed@example.com",
  "age": 28,
  "isActive": true,
  "avatar": "https://example.com/avatar.jpg",
  "profile": {
    "bio": "Flutter Developer",
    "website": "https://ahmed.dev",
    "social": {
      "twitter": "@ahmed_dev",
      "github": "ahmed-dev"
    }
  },
  "preferences": {
    "theme": "dark",
    "language": "ar",
    "notifications": {
      "email": true,
      "push": false,
      "sms": true
    }
  },
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-20T15:45:30Z"
}
```

### 🏗️ **Basic Model Generation**

```bash
gexd make model User --file assets/models/user.json
```

**Generated Files:**
```
lib/app/data/models/
├── user.dart                    # Main User model
├── user_relationships/          # Nested relationships
│   ├── user_profile.dart       # Profile nested object
│   ├── user_social.dart        # Social media links
│   ├── user_preferences.dart   # User preferences
│   └── user_notifications.dart # Notification settings
```

### 🎨 **Advanced Model with All Features**

```bash
gexd make model User \
  --file assets/models/user.json \
  --style freezed \
  --immutable \
  --copyWith \
  --equatable \
  --relationships-in-folder \
  --on auth/models
```

**Generated Code Example:**
```dart
// lib/app/modules/auth/models/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_relationships/user_profile.dart';
import 'user_relationships/user_preferences.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User, EquatableMixin {
  const factory User({
    required int id,
    required String name,
    required String email,
    required int age,
    required bool isActive,
    required String avatar,
    required UserProfile profile,
    required UserPreferences preferences,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  List<Object?> get props => [
    id, name, email, age, isActive, 
    avatar, profile, preferences, createdAt, updatedAt
  ];
}
```

### 🔗 **API-Based Model Generation**

```bash
# Generate from live API endpoint
gexd make model Product --url https://api.store.com/products/1 --style json

# Generate with custom organization
gexd make model Order \
  --url https://api.store.com/orders/123 \
  --on ecommerce/data \
  --immutable \
  --copyWith
```

---

## ⚙️ Options

### `--file` (`-f`)

**Description:** Path to JSON file for model generation

**Usage:**
```bash
gexd make model User --file assets/models/user.json
gexd make model Product --file assets/models/product.json
```

**Benefits:**
- Local file processing
- Offline development
- Version controlled schemas

---

### `--url` (`-u`)

**Description:** URL to fetch JSON data for model generation

**Usage:**
```bash
gexd make model User --url https://api.example.com/user/123
gexd make model Post --url https://jsonplaceholder.typicode.com/posts/1
```

**Benefits:**
- Live API integration
- Real-time schema updates
- Production data structures

---

### `--template` (`-t`)

**Description:** Choose starter template for model generation

**Format:** `basic|custom`

**Available Options:**
- `basic` → Simple model generation with minimal configuration
- `custom` → Interactive template with guided options

**Usage:**
```bash
gexd make model User --template basic     # Quick generation
gexd make model User --template custom    # Interactive setup
```

---

### `--style` (`-s`)

**Description:** Choose model generation style

**Format:** `plain|json|freezed`

**Available Options:**
- `plain` → Simple Dart classes
- `json` → JSON serializable models with toJson/fromJson
- `freezed` → Immutable data classes with code generation

**Usage:**
```bash
gexd make model User --style plain    # Basic Dart class
gexd make model User --style json     # With JSON serialization
gexd make model User --style freezed  # Immutable with Freezed
```

---

### `--on`

**Description:** Specify subdirectory path for model placement

**Format:** `path/to/directory` (max 3 levels)

**Usage:**
```bash
gexd make model User --on auth/models          # auth/models/user.dart
gexd make model Product --on shop/data/models  # shop/data/models/product.dart
gexd make model Order --on ecommerce          # ecommerce/order.dart
```

---

## 🚩 Flags

### `--relationships-in-folder` (`-r`)

**Description:** Generate nested objects in separate organized folder structure

**Default:** `true`

**Usage:**
```bash
# Generates nested relationships in separate folder
gexd make model User --file user.json --relationships-in-folder

# Generates everything in single file
gexd make model User --file user.json --no-relationships-in-folder
```

**Output Structure:**
```
lib/app/data/models/
├── user.dart                    # Main model
└── user_relationships/          # Nested models
    ├── user_profile.dart
    ├── user_social.dart
    └── user_preferences.dart
```

**Benefits:**
- **Clean Organization**: Separate files for each nested object
- **Better Maintainability**: Easy to locate and modify specific models
- **Import Management**: Automatic import handling
- **Scalability**: Handles complex nested structures gracefully

---

### `--immutable` (`-i`)

**Description:** Generate immutable model with final fields

**Usage:**
```bash
gexd make model User --immutable
```

**Generated Code:**
```dart
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;
}
```

---

### `--copyWith` (`-c`)

**Description:** Add copyWith method for creating modified copies

**Usage:**
```bash
gexd make model User --copyWith --immutable
```

**Generated Code:**
```dart
User copyWith({
  int? id,
  String? name,
  String? email,
}) {
  return User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
  );
}
```

---

### `--equatable` (`-e`)

**Description:** Use Equatable package for value equality comparison

**Usage:**
```bash
gexd make model User --equatable
```

**Generated Code:**
```dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.name});
  
  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
```

---

### `--force`

**Description:** Force overwrite existing files without prompting

**Usage:**
```bash
gexd make model User --force  # Overwrites without asking
```

---

## 🎯 Common Workflows

### 🚀 **Quick API Integration**
```bash
# 1. Generate from API
gexd make model User --url https://api.example.com/user/1

# 2. Add features
gexd make model User --url https://api.example.com/user/1 \
  --immutable --copyWith --equatable --force
```

### 🏗️ **Complex Model with Relationships**
```bash
# Generate user model with nested relationships
gexd make model User \
  --file assets/models/user.json \
  --relationships-in-folder \
  --style freezed \
  --immutable \
  --on auth/models
```

### 🔄 **Iterative Development**
```bash
# 1. Start simple
gexd make model Product --file assets/models/product.json

# 2. Add features iteratively
gexd make model Product --file assets/models/product.json --copyWith --force

# 3. Upgrade to Freezed
gexd make model Product --file assets/models/product.json \
  --style freezed --immutable --copyWith --equatable --force
```

---

## 💡 Best Practices

### 🎯 **Model Organization**
1. **Use `--on` for logical grouping**: Group related models in subdirectories
2. **Enable `--relationships-in-folder`**: Keep complex models organized
3. **Use descriptive names**: Choose clear, descriptive model names

### 🔧 **Feature Selection**
1. **Start with `--style json`**: Good for API integration
2. **Add `--immutable --copyWith`**: For state management
3. **Use `--equatable`**: For value comparison in lists/sets
4. **Upgrade to `--style freezed`**: For production apps

### 🛡️ **Development Workflow**
1. **Test with small JSON first**: Validate structure before complex models
2. **Use `--force` during development**: Quick iteration
3. **Version control your JSON**: Track schema changes
4. **Document your models**: Add comments for complex relationships

---

## 🔧 Troubleshooting

### ❌ **Common Issues**

**Issue**: Nested objects not generating properly
```bash
# ✅ Solution: Enable relationships folder
gexd make model User --file assets/models/user.json --relationships-in-folder
```

**Issue**: Complex API responses
```bash
# ✅ Solution: Save API response to file first
curl "https://api.example.com/user/1" > assets/models/user.json
gexd make model User --file assets/models/user.json
```

**Issue**: Existing files conflict
```bash
# ✅ Solution: Use force or choose different location
gexd make model User --file assets/models/user.json --force
# OR
gexd make model User --file assets/models/user.json --on v2/models
```

---

_Generated automatically by `gexd_doc`_
