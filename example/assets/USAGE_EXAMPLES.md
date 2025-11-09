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

## 🌍 Locale Generation Examples

### 1. Basic Locale Generation
```bash
# Copy translation files to your project
mkdir -p assets/translations
cp ../gexd/example/assets/translations/*.json assets/translations/

# Generate basic translations
gexd locale generate assets/translations
```

### 2. Advanced Locale Generation
```bash
# Generate with dot notation (recommended)
gexd locale generate assets/translations \
  --key-style dot --sort-keys --force

# Generate with camelCase keys
gexd locale generate assets/translations \
  --key-style camelCase \
  --output lib/generated/app_translations.dart

# Generate with custom output location
gexd locale generate assets/translations \
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
gexd locale generate assets/translations \
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
mkdir -p assets/translations
cp ../gexd/example/assets/translations/*.json assets/translations/

# Add more languages
echo '{"app":{"name":"Mi App"}}' > assets/translations/es.json
echo '{"app":{"name":"Meine App"}}' > assets/translations/de.json

# 3. Generate locale support
gexd locale generate assets/translations --key-style dot --sort-keys

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