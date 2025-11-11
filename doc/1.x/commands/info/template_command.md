# `template` Command

---

## 📝 Description

Display template information and directory structure. The `template` command provides comprehensive information about available Gexd templates, their architecture patterns, directory structures, and usage recommendations to help you make informed decisions for your Flutter projects.

---

## ⚙️ Usage

```bash
gexd info template [template_name] [options]
```

---

## 📖 Detailed Usage

```text
Display template information and structure

Usage: gexd info template [template_name] [options]

Arguments:
  <template_name>    Template to display (getx, clean)
                     [Optional: Shows all templates if not specified]

Options:
  --full             Show full directory structure including optional components

Examples:
  gexd info template                  # List all available templates
  gexd info template clean            # Show clean template details
  gexd info template clean --full     # Show full directory structure
  gexd info template getx --full      # Show GetX template with full structure
```

---

## 🎯 Key Features

### 📚 **Template Overview**
- **Complete Template List**: Display all available architecture templates
- **Detailed Descriptions**: Comprehensive explanation of each template's approach
- **Best Use Cases**: Recommended scenarios and project types
- **Key Features**: Architecture-specific capabilities and benefits

### 📁 **Directory Structure**
- **Basic Structure**: Essential directories and organization
- **Full Structure**: Complete directory tree with optional components
- **Visual Tree**: Beautiful ASCII tree representation
- **Component Descriptions**: Explanation of each directory's purpose

### 🏗️ **Architecture Information**
- **Design Principles**: Underlying architectural patterns
- **Organization Strategy**: How code is structured and organized
- **Development Workflow**: Recommended development approaches
- **Best Practices**: Template-specific conventions and guidelines

---

## 🚀 Usage Modes

### **1️⃣ List All Templates**
```bash
gexd info template
```

**Output:**
```
🏗️ Available Templates
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 GetX Standard Architecture (getx)
   Description: Feature-based modular architecture with GetX state management.
   Perfect for rapid development with reactive programming patterns.
   Best For: Medium to large applications, rapid prototyping, GetX enthusiasts

📁 Clean Architecture (clean)
   Description: Domain-driven design with clear separation of concerns.
   Follows Uncle Bob's Clean Architecture principles for maximum maintainability.
   Best For: Enterprise applications, complex business logic, long-term projects

💡 Use gexd info template <name> --full to see detailed structure
```

### **2️⃣ Template Details (Basic)**
```bash
gexd info template clean
```

**Output:**
```
🏗️ Clean Architecture Template
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 Description:
   Domain-driven design with clear separation of concerns.
   Follows Uncle Bob's Clean Architecture principles for maximum maintainability.

🎯 Best For:
   Enterprise applications, complex business logic, long-term projects

✨ Key Features:
   Layered architecture, dependency inversion principle,
   high testability, framework independence, clear boundaries

📁 Directory Structure:

📁 Clean Architecture Template Structure
├── 📁 lib
│   ├── 📁 core   # Core application foundation
│   ├── 📁 domain # Business logic layer
│   ├── 📁 infrastructure # External dependencies
│   ├── 📁 presentation # UI layer
│   └── 📁 shared # Shared components
└── 📁 assets/   # Project assets

💡 Use --full flag to see the complete directory structure
```

### **3️⃣ Complete Structure (Full)**
```bash
gexd info template clean --full
```

**Shows the complete directory tree with all optional components and detailed descriptions.**

---

## 🏗️ Template Comparison

### **📊 GetX Template**

#### **🎯 Architecture Overview**
- **Pattern**: Feature-based modular architecture
- **State Management**: GetX reactive programming
- **Organization**: Module-centric structure
- **Dependencies**: Built-in GetX ecosystem

#### **✨ Key Strengths**
- **Rapid Development**: Minimal boilerplate, quick setup
- **Reactive Programming**: Built-in state management and reactivity
- **Integrated Ecosystem**: Routing, dependency injection, internationalization
- **Learning Curve**: Gentle for developers familiar with GetX

#### **🎯 Best For**
- **Medium to Large Apps**: Suitable for complex applications
- **Rapid Prototyping**: Quick MVP development
- **GetX Enthusiasts**: Teams comfortable with GetX patterns
- **Feature-Rich Apps**: Applications requiring extensive functionality

#### **📁 Directory Highlights**
```
lib/app/
├── modules/           # Feature modules
│   ├── auth/         # Authentication feature
│   ├── home/         # Home feature  
│   └── profile/      # User profile feature
├── core/             # Core utilities
└── data/             # Data layer
```

### **🏛️ Clean Architecture Template**

#### **🎯 Architecture Overview**
- **Pattern**: Layered architecture with dependency inversion
- **State Management**: Framework-agnostic (can use any)
- **Organization**: Layer-centric structure
- **Dependencies**: Minimal, focused on business logic

#### **✨ Key Strengths**
- **High Testability**: Clear separation enables comprehensive testing
- **Framework Independence**: Business logic isolated from UI framework
- **Scalability**: Designed for large, complex applications
- **Maintainability**: Clear boundaries and dependencies

#### **🎯 Best For**
- **Enterprise Applications**: Large-scale business applications
- **Complex Business Logic**: Applications with intricate rules
- **Long-term Projects**: Applications requiring long-term maintenance
- **Team Development**: Large development teams with clear responsibilities

#### **📁 Directory Highlights**
```
lib/
├── domain/           # Business logic
│   ├── entities/     # Core business objects
│   └── usecases/     # Business rules
├── infrastructure/   # External dependencies
│   ├── datasources/ # Data access
│   └── repositories/ # Data abstraction
└── presentation/     # UI layer
    ├── pages/       # Application screens
    └── controllers/ # UI controllers
```

---

## 🔍 Directory Structure Analysis

### **📂 Component Categories**

#### **🏛️ Core Components** (Both Templates)
- **`core/`**: Fundamental application infrastructure
- **`shared/`**: Reusable components across features
- **`assets/`**: Static resources and files

#### **📊 Data Management**
- **GetX**: `lib/app/data/` with models, services, providers
- **Clean**: `lib/infrastructure/` with repositories, datasources

#### **🎨 Presentation Layer**
- **GetX**: `lib/app/modules/` with feature-based organization
- **Clean**: `lib/presentation/` with layered organization

#### **🧠 Business Logic**
- **GetX**: Embedded within modules and services
- **Clean**: Isolated in `lib/domain/` layer

### **🔧 Optional Components** (Shown with --full)
- **Middleware**: Request/response processing
- **Extensions**: Dart type extensions
- **Exceptions**: Custom error handling
- **Interfaces**: Contract definitions
- **Utils**: Helper functions and utilities

---

## 💡 Making Template Decisions

### **🤔 Decision Framework**

#### **Choose GetX Template When:**
- ✅ Rapid development is prioritized
- ✅ Team is familiar with GetX ecosystem
- ✅ Building medium to large applications
- ✅ Want integrated state management solution
- ✅ Prefer feature-based organization

#### **Choose Clean Architecture When:**
- ✅ Building enterprise-grade applications
- ✅ Complex business logic requirements
- ✅ High testability is critical
- ✅ Framework independence is important
- ✅ Large development team with specialized roles

### **📊 Comparison Matrix**

| Aspect | GetX Template | Clean Architecture |
|--------|---------------|-------------------|
| **Learning Curve** | Moderate | Steep |
| **Development Speed** | Fast | Moderate |
| **Testability** | Good | Excellent |
| **Scalability** | Good | Excellent |
| **Framework Coupling** | High (GetX) | Low |
| **Boilerplate** | Low | Moderate |
| **Team Size** | Small-Medium | Medium-Large |
| **Business Complexity** | Moderate | High |

---

## 🚀 Real-World Usage Examples

### **🔍 Template Research**
```bash
# Explore all options before starting new project
gexd info template

# Deep dive into specific template
gexd info template clean --full
gexd info template getx --full

# Make informed decision based on project requirements
```

### **📚 Team Education**
```bash
# Onboard new team members
gexd info template clean --full

# Show architecture during code reviews
gexd info template getx

# Reference during architectural discussions
```

### **🏗️ Project Planning**
```bash
# Planning phase: Understand structure implications
gexd info template clean --full

# Pre-development: Align team on organization
gexd info template getx

# Architecture review: Validate chosen approach
```

### **📖 Documentation Generation**
```bash
# Generate structure documentation for wikis
gexd info template clean --full > docs/architecture.md

# Create template comparison documents
gexd info template > docs/template-options.md
```

---

## 🎨 Advanced Usage Patterns

### **🔬 Architecture Analysis**
```bash
# Compare structures side by side
gexd info template getx --full > getx_structure.txt
gexd info template clean --full > clean_structure.txt
diff getx_structure.txt clean_structure.txt
```

### **📋 Project Setup Workflow**
```bash
# 1. Research templates
gexd info template

# 2. Analyze specific template
gexd info template clean --full

# 3. Create project with informed choice
gexd create my_project --template clean

# 4. Verify structure matches expectations
cd my_project && ls -la lib/
```

### **🔧 Development Integration**
```bash
# During development: Reference structure for component placement
gexd info template clean --full | grep -A5 "presentation"

# Architecture validation: Ensure compliance with template
gexd info template clean
```

---

## 📊 Structure Output Formats

### **🌳 Tree Structure Format**
```
📁 Clean Architecture Template Structure
├── 📁 lib
│   ├── 📁 core   # Core application foundation
│   │   ├── 📁 bindings   # Initial dependency bindings
│   │   └── 📁 themes   # App theme definitions
│   ├── 📁 domain   # Business logic layer
│   │   ├── 📁 entities   # Core business objects
│   │   └── 📁 usecases   # Business rules
│   └── 📁 presentation   # UI layer
│       ├── 📁 pages   # Application screens
│       └── 📁 controllers   # UI controllers
└── 📁 assets/   # Project assets
```

### **📋 Component Descriptions**
Each directory includes:
- **📁 Icon**: Visual identification
- **Name**: Directory/file name
- **# Comment**: Purpose and usage description

### **🎯 Organizational Logic**
- **Hierarchical**: Shows parent-child relationships
- **Categorized**: Groups related components
- **Descriptive**: Explains purpose of each component
- **Visual**: Easy to scan and understand

---

## ❓ Troubleshooting

### **Common Issues**

#### **❌ "Unknown template: template_name"**
```bash
# Problem: Invalid template name provided
gexd info template invalid_name
# Error: Unknown template: invalid_name

# ✅ Solution: Check available templates
gexd info template  # Shows all available templates
```

#### **❌ Command not displaying properly**
```bash
# Problem: Terminal encoding issues
gexd info template clean --full
# Output appears garbled

# ✅ Solution: Ensure UTF-8 terminal support
export LANG=en_US.UTF-8
gexd info template clean --full
```

#### **❌ Structure seems incomplete**
```bash
# Problem: Basic structure missing details
gexd info template clean
# Shows minimal structure

# ✅ Solution: Use --full flag for complete structure
gexd info template clean --full
```

### **🔧 Advanced Troubleshooting**

#### **Template Updates**
```bash
# If template structure seems outdated
gexd self-update  # Update to latest version
gexd info template clean --full  # Get latest structure
```

#### **Comparison Issues**
```bash
# For detailed template comparison
gexd info template getx --full > /tmp/getx.txt
gexd info template clean --full > /tmp/clean.txt
code --diff /tmp/getx.txt /tmp/clean.txt  # Visual comparison
```

---

## 🔗 Related Commands

### **📋 Project Creation**
- [`gexd create`](../create_command.md) - Create new project with chosen template
- [`gexd init`](../init_command.md) - Initialize existing project with template

### **🔧 Project Management**
- [`gexd info config`](config_command.md) - Check current project template
- [`gexd upgrade`](../upgrade_command.md) - Update project to latest template

### **🛠️ Development**
- [`gexd make`](../make_command.md) - Generate components following template structure
- [`gexd locale generate`](../locales/generate_command.md) - Add internationalization

---

## 📚 Further Reading

### **🏗️ Architecture Guides**
- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GetX Pattern Documentation](https://github.com/jonataslaw/getx)

### **📖 Best Practices**
- [Flutter Architecture Patterns](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Dependency Injection in Flutter](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)

---

_Generated automatically by `gexd_doc`_