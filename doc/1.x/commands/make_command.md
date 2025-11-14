# `make` Command

<div align="center">
  <img src="https://github.com/altwaireb/gexd/raw/main/assets/logo.svg" alt="GEXD" width="150"/>
</div>

---

## 📝 Description

Generate various project files and components. The `make` command is the primary code generation tool in Gexd CLI, offering powerful scaffolding capabilities for Flutter projects with GetX and Clean Architecture patterns.

---

## ⚙️ Usage

```bash
gexd make <subcommand> [<name>] [options]
```

---

## 📚 Available Subcommands

### 🏗️ **Core Components**

#### [`screen`](make/screen_command.md)
**Description:** Generate complete screen components (controller, view, binding)
```bash
gexd make screen LoginPage
gexd make screen UserProfile --type withState --has-model
```

#### [`controller`](make/controller_command.md) 
**Description:** Generate controller files for state management
```bash
gexd make controller AuthController
gexd make controller UserController --type withState
```

#### [`view`](make/view_command.md)
**Description:** Generate view files (UI components)
```bash
gexd make view LoginView
gexd make view UserProfileView --on auth
```

#### [`binding`](make/binding_command.md)
**Description:** Generate binding files for dependency injection
```bash
gexd make binding AuthBinding
gexd make binding CoreBinding --location core
```

---

### 📊 **Data Layer**

#### [`model`](make/model_command.md)
**Description:** Generate type-safe model files from JSON sources with advanced features
```bash
gexd make model User --file assets/user.json
gexd make model Product --url https://api.example.com/products/1
gexd make model User --immutable --copyWith --relationships-in-folder
```

#### [`repository`](make/repository_command.md)
**Description:** Generate repository files for data access layers
```bash
gexd make repository UserRepository --type crud --interface
gexd make repository ApiRepository --on data/repositories
```

#### [`service`](make/service_command.md)
**Description:** Generate service files for business logic
```bash
gexd make service Auth
gexd make service Payment --on services
```

#### [`provider`](make/provider_command.md)
**Description:** Generate provider files for data sources
```bash
gexd make provider ApiProvider
gexd make provider LocalProvider --on data/providers
```

---

### 🏛️ **Architecture Components**

#### [`entity`](make/entity_command.md)
**Description:** Generate entity files for domain layer
```bash
gexd make entity User
gexd make entity Product --on domain/entities
```

#### [`interface`](make/interface_command.md)
**Description:** Generate interface files for contracts and abstractions
```bash
gexd make interface UserInterface --type crud
gexd make interface PaymentInterface --on interfaces
```

#### [`exception`](make/exception_command.md)
**Description:** Generate custom exception classes
```bash
gexd make exception AuthException
gexd make exception ValidationException --on core/exceptions
```

#### [`middleware`](make/middleware_command.md)
**Description:** Generate middleware files for request/response handling
```bash
gexd make middleware AuthMiddleware
gexd make middleware LoggingMiddleware --on core/middleware
```

---

### 🛠️ **Utility Components**

#### [`widget`](make/widget_command.md)
**Description:** Generate reusable widget components
```bash
gexd make widget CustomButton
gexd make widget UserCard --location shared
```

#### [`util`](make/util_command.md)
**Description:** Generate utility helper classes
```bash
gexd make util DateUtils
gexd make util ValidationUtils --on core/utils
```

#### [`constant`](make/constant_command.md)
**Description:** Generate constant definition files
```bash
gexd make constant ApiConstants
gexd make constant AppConstants --on core/constants
```

---

## 🎯 Command Categories

### **📱 UI Components**
- `screen` - Complete screen with controller, view, binding
- `view` - UI view components
- `widget` - Reusable widget components

### **🔧 State Management** 
- `controller` - State controllers
- `binding` - Dependency injection bindings
- `middleware` - Request/response middleware

### **📊 Data Management**
- `model` - Data models with serialization
- `repository` - Data access repositories  
- `service` - Business logic services
- `provider` - Data source providers

### **🏗️ Architecture**
- `entity` - Domain entities
- `interface` - Contract abstractions
- `exception` - Custom exceptions

### **🛠️ Utilities**
- `util` - Helper utilities
- `constant` - Application constants

---

## 🚀 Common Usage Patterns

### 📱 **Complete Feature Generation**
```bash
# Generate a complete user management feature
gexd make screen UserProfile --type withState --has-model
gexd make model User --file assets/user.json --relationships-in-folder
gexd make repository UserRepository --type crud --interface
gexd make service UserService --on auth/services
gexd make binding UserBinding --location screen --on-screen user_profile
```

### 🏗️ **Clean Architecture Setup**
```bash
# Domain layer
gexd make entity User --on domain/entities
gexd make interface UserRepository --on domain/repositories

# Data layer  
gexd make model User --file user.json --on data/models
gexd make repository UserRepositoryImpl --on data/repositories
gexd make provider UserProvider --on data/providers

# Presentation layer
gexd make screen UserProfile --on presentation/pages
gexd make controller UserController --on presentation/controllers
```

### 📊 **API Integration Workflow**
```bash
# 1. Generate model from API
gexd make model Product --url https://api.store.com/products/1

# 2. Create data access layer
gexd make repository ProductRepository --type crud --interface
gexd make provider ApiProvider --on data/providers

# 3. Business logic layer
gexd make service ProductService --on services

# 4. UI layer
gexd make screen ProductList --type withState --model Product
gexd make widget ProductCard --location shared
```

---

## ⚙️ Global Options

Most make subcommands support these common options:

### **📁 Organization**
- `--on <path>` - Specify subdirectory for generated files
- `--force` - Force overwrite existing files without prompting

### **🎨 Customization**  
- `--type <type>` - Specify component type/style
- `--template <template>` - Choose generation template
- `--style <style>` - Select code generation style

### **🔧 Features**
- `--interface` - Generate with interface abstraction
- `--immutable` - Create immutable data structures
- `--copyWith` - Add copy methods for state updates

---

## 💡 Pro Tips

### **🎯 Best Practices**
1. **Start with Architecture**: Generate entities and interfaces first
2. **Use `--on` for Organization**: Keep related files in subdirectories
3. **Enable Interfaces**: Use `--interface` for better testability
4. **Force During Development**: Use `--force` for rapid iteration

### **🚀 Efficiency Tips**
1. **Batch Generation**: Generate related components together
2. **Template Reuse**: Save commonly used flag combinations
3. **API-First Development**: Generate models from live APIs
4. **Relationship Management**: Use `--relationships-in-folder` for complex models

### **🔧 Advanced Workflows**
1. **Feature-Based**: Group components by feature using `--on`
2. **Layer-Based**: Organize by architectural layers
3. **Test-Driven**: Generate interfaces first for better testing
4. **Iterative**: Start simple, add features with `--force`

---

## 📖 Documentation Links

For detailed documentation on each subcommand, click the links above or visit:
- [Screen Command](make/screen_command.md) - Complete UI component generation
- [Model Command](make/model_command.md) - Advanced data model creation
- [Repository Command](make/repository_command.md) - Data access layer patterns
- [Service Command](make/service_command.md) - Business logic organization
- [Widget Command](make/widget_command.md) - Reusable UI components

---

_Generated automatically by `gexd_doc`_
