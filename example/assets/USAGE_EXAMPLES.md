# 🎯 Quick Usage Examples

This file provides copy-paste commands to quickly test Gexd CLI with the provided example assets.

## 📋 Prerequisites

```bash
# Ensure you're in a Gexd project directory
gexd create test_project --template clean
cd test_project
```

## 🗂️ Model Generation Examples

### 1. User Model - Basic Generation
```bash
# Copy the example file to your project
cp ../gexd/example/assets/models/user.json assets/models/

# Generate basic User model
gexd make model User --file assets/models/user.json

# Generate with advanced features
gexd make model User --file assets/models/user.json \
  --immutable --copyWith --equatable --style json
```

### 2. User Model - Different Styles
```bash
# Generate User model with Freezed style
gexd make model User --file assets/models/user.json \
  --style freezed --immutable --relationships-in-folder

# Generate in subdirectory
gexd make model User --file assets/models/user.json \
  --on auth/models --style json --copyWith
```

### 3. User Model - Advanced Options
```bash
# Generate with all relationships in separate folder
gexd make model User --file assets/models/user.json \
  --relationships-in-folder --immutable --equatable

# Generate in auth domain folder
gexd make model User --file assets/models/user.json \
  --on auth/models --style freezed --force
```

### 4. From API Endpoint (Example URLs)
```bash
# Generate from JSONPlaceholder API
gexd make model Post --url https://jsonplaceholder.typicode.com/posts/1

# Generate User from API
gexd make model ApiUser --url https://jsonplaceholder.typicode.com/users/1 \
  --immutable --copyWith
```

## 🔗 Complex Relationships Examples

### Understanding `--relationships-in-folder`

The `--relationships-in-folder` flag is powerful for handling complex nested JSON structures. It automatically detects nested objects and creates separate model files for better organization.

### Example JSON Structure
```json
{
  "id": 1,
  "name": "Ahmed Ali",
  "profile": {
    "bio": "Flutter Developer",
    "social": {
      "twitter": "@ahmed_dev",
      "github": "ahmed-dev"
    }
  },
  "preferences": {
    "notifications": {
      "email": true,
      "push": false
    }
  }
}
```

### 1. Default Relationship Handling
```bash
# Generate with relationships in separate folder (default: true)
gexd make model User --file assets/models/user.json --relationships-in-folder

# Output structure:
# lib/app/data/models/
# ├── user.dart                    # Main User model
# └── user_relationships/          # Nested relationships
#     ├── user_profile.dart        # Profile nested object
#     ├── user_social.dart         # Social media nested object
#     ├── user_preferences.dart    # Preferences nested object
#     └── user_notifications.dart  # Notifications nested object
```

### 2. Single File Approach
```bash
# Generate everything in one file (disable relationships folder)
gexd make model User --file assets/models/user.json --no-relationships-in-folder

# Output: Single lib/app/data/models/user.dart with all nested classes
```

### 3. Complex E-commerce Example
```bash
# Create complex product JSON first
cat > assets/models/product.json << 'EOF'
{
  "id": 1,
  "name": "iPhone 15",
  "price": 999.99,
  "category": {
    "id": 2,
    "name": "Electronics",
    "parent": {
      "id": 1,
      "name": "Technology"
    }
  },
  "variants": [
    {
      "id": 1,
      "color": "Black",
      "size": "128GB",
      "price": 999.99,
      "inventory": {
        "stock": 50,
        "warehouse": {
          "id": 1,
          "location": "Dubai"
        }
      }
    }
  ],
  "vendor": {
    "id": 1,
    "name": "Apple Inc.",
    "contact": {
      "email": "contact@apple.com",
      "phone": "+1-800-APL-CARE"
    }
  }
}
EOF

# Generate with full relationship structure
gexd make model Product \
  --file assets/models/product.json \
  --relationships-in-folder \
  --style freezed \
  --immutable \
  --copyWith \
  --equatable \
  --on shop/models

# Generated structure:
# lib/app/modules/shop/models/
# ├── product.dart
# └── product_relationships/
#     ├── product_category.dart
#     ├── product_parent.dart
#     ├── product_variant.dart
#     ├── product_inventory.dart
#     ├── product_warehouse.dart
#     ├── product_vendor.dart
#     └── product_contact.dart
```

### 4. API Integration with Relationships
```bash
# Generate from real API with complex relationships
gexd make model GithubUser \
  --url https://api.github.com/users/octocat \
  --relationships-in-folder \
  --style json \
  --immutable \
  --copyWith \
  --on api/models

# Generate blog post with author relationship
gexd make model BlogPost \
  --url https://jsonplaceholder.typicode.com/posts/1 \
  --relationships-in-folder \
  --on blog/models
```

### 5. Benefits of Relationship Management

#### ✅ **With `--relationships-in-folder` (Recommended)**
- **Clean Organization**: Each nested object gets its own file
- **Better Maintainability**: Easy to locate and modify specific models
- **Import Management**: Automatic import handling
- **Scalability**: Handles deeply nested structures
- **Team Development**: Multiple developers can work on different relationship files

#### ❌ **Without `--relationships-in-folder`**
- **Large Files**: Everything in one file can become unwieldy
- **Merge Conflicts**: Higher chance of conflicts in team development
- **Navigation**: Harder to navigate complex nested structures
- **Maintenance**: Difficult to maintain large files with many nested classes

### 6. Real-World Workflow
```bash
# 1. Start with simple model to test structure
gexd make model User --file assets/models/user.json

# 2. Check the generated structure
ls -la lib/app/data/models/

# 3. If satisfied, regenerate with relationships and features
gexd make model User \
  --file assets/models/user.json \
  --relationships-in-folder \
  --style freezed \
  --immutable \
  --copyWith \
  --equatable \
  --force

# 4. Verify the relationship structure
ls -la lib/app/data/models/user_relationships/

# 5. Use in your code
cat > lib/example_usage.dart << 'EOF'
import 'app/data/models/user.dart';

void main() {
  final user = User.fromJson(jsonData);
  print('User: ${user.name}');
  print('Bio: ${user.profile.bio}');
  print('Twitter: ${user.profile.social.twitter}');
  
  final updatedUser = user.copyWith(
    name: 'New Name',
    profile: user.profile.copyWith(
      bio: 'Updated Bio'
    )
  );
}
EOF
```

## 🌍 Locale Generation Examples

### 1. Basic Locale Generation
```bash
# Copy translation files to your project
mkdir -p assets/locales
cp ../gexd/example/assets/locales/*.json assets/locales/

# Generate basic translations
gexd locale generate assets/locales
```

### 2. Advanced Locale Generation
```bash
# Generate with dot notation (recommended)
gexd locale generate assets/locales \
  --key-style dot --sort-keys --force

# Generate with camelCase keys
gexd locale generate assets/locales \
  --key-style camelCase \
  --output lib/generated/app_translations.dart

# Generate with custom output location
gexd locale generate assets/locales \
  --key-style snake \
  --output lib/core/localization/translations.g.dart \
  --sort-keys --force
```

## 🔧 Combined Workflow Examples

### Complete E-commerce Setup
```bash
# 1. Create project structure
gexd create ecommerce_app --template clean
cd ecommerce_app

# 2. Copy all example assets
cp -r ../gexd/example/assets/* assets/

# 3. Generate User model
gexd make model User --file assets/models/user.json \
  --on auth/models --immutable --copyWith --equatable

# 4. Generate localization
gexd locale generate assets/locales \
  --key-style dot --sort-keys --force

# 5. Generate screen for the User model
gexd make screen UserProfile --type withState --has-model --on auth

# 6. Generate User repository
gexd make repository User --type crud --interface --on auth/data

# 7. Generate Auth service
gexd make service AuthService --on auth/services
```

### Multi-language Blog App
```bash
# 1. Create blog project
gexd create blog_app --template getx
cd blog_app

# 2. Setup translations
mkdir -p assets/locales
cp ../gexd/example/assets/locales/*.json assets/locales/

# Add more languages
echo '{"app":{"name":"Mi App"}}' > assets/locales/es_ES.json
echo '{"app":{"name":"Meine App"}}' > assets/locales/de_DE.json

# 3. Generate locale support
gexd locale generate assets/locales --key-style dot --sort-keys

# 4. Use the User model for blog authors
gexd make model User --file assets/models/user.json \
  --immutable --copyWith --relationships-in-folder --on blog/models

# 5. Generate blog screens using User model
gexd make screen UserProfile --type withState --has-model --on blog
gexd make screen AuthorList --type withState --model User
gexd make screen UserSettings --type form
```

## 🧪 Testing the Generated Code

### Verify Model Generation
```bash
# Check generated User model
ls -la lib/app/data/models/ # Clean Architecture
ls -la lib/app/modules/auth/models/ # GetX Architecture

# Check User model relationships (if --relationships-in-folder was used)
ls -la lib/app/data/models/user_relationships/
```

### Verify Locale Generation  
```bash
# Check generated translations
ls -la lib/generated/ # Default location
cat lib/generated/translations.g.dart # View generated file
```

### Run the Project
```bash
# Get dependencies and run
flutter pub get
flutter run
```

## 💡 Pro Tips

1. **Always backup** your files before using `--force`
2. **Use `--relationships-in-folder`** for complex models with many nested objects
3. **Choose the right style**: 
   - `plain` for simple models
   - `json` for API integration
   - `freezed` for immutable data classes
4. **Organize with `--on`**: Use subdirectories to keep your code organized
5. **Test with small examples** first before generating from complex APIs
6. **Use consistent naming**: Follow Dart naming conventions for better code generation

Happy coding with Gexd! 🚀