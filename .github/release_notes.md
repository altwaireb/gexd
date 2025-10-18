## 🚀 Gexd CLI Release

### 📦 Available Downloads:
- **Linux x64**: `gexd-linux-x64`
- **Windows x64**: `gexd-windows-x64.exe`
- **macOS Intel**: `gexd-macos-x64`
- **macOS Apple Silicon**: `gexd-macos-arm64`

### 📥 Installation:

#### Option 1: Download Binary (Recommended)
1. Download the appropriate binary for your platform from the assets below
2. Make it executable (Linux/macOS): `chmod +x gexd-*`
3. Move to PATH: `sudo mv gexd-* /usr/local/bin/gexd`

#### Option 2: Install via pub.dev
```bash
dart pub global activate gexd
```

### 🎯 Quick Start:
```bash
# Create a new GetX project
gexd create my_app --template getx

# Initialize existing project with Gexd templates
gexd init

# Generate screen components
gexd make screen Home --type withState
gexd make screen Login --type form
```

### 🔧 Available Commands:
- `gexd create` - Create new Flutter project with templates
- `gexd init` - Initialize existing project with Gexd patterns  
- `gexd make screen` - Generate screen files (controller, view, binding)
- `gexd --help` - Show detailed help

### 📚 Documentation:
- [Getting Started Guide](https://github.com/altwaireb/gexd#readme)
- [Command Reference](https://github.com/altwaireb/gexd/wiki)
- [Examples](https://github.com/altwaireb/gexd/tree/main/examples)

### 🐛 Report Issues:
Found a bug? [Open an issue](https://github.com/altwaireb/gexd/issues/new)