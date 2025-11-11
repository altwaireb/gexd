# `self-update` Command

---

## 📝 Description

The `self-update` command automatically updates the GEXD CLI tool to the latest available version from pub.dev. It ensures you have access to the newest features, bug fixes, and improvements.

---

## ⚙️ Usage

```bash
gexd self-update [options]
```

### 📋 **Basic Examples:**

```bash
# Update to latest version
gexd self-update

# Check for updates without installing
gexd self-update --dry-run

# Force update (skip confirmations)
gexd self-update --force

# Update to specific version
gexd self-update --version 1.2.3

# Verbose update with detailed output
gexd self-update --verbose
```

---

## 🚩 Flags

| Flag | Description |
|------|-------------|
| `--dry-run` | Check for updates without installing |
| `--force` | Force update without confirmation prompts |
| `--version <version>` | Update to specific version |
| `--verbose` | Show detailed update process |
| `--pre-release` | Include pre-release versions |

---

## 🎯 **Update Process:**

1. **🔍 Version Check** - Compares current vs latest version
2. **📋 Release Notes** - Shows what's new in the update
3. **✅ Confirmation** - Asks for user confirmation
4. **⬇️ Download** - Downloads new version from pub.dev
5. **🔄 Installation** - Replaces current installation
6. **✅ Verification** - Confirms successful update

---

## 📊 **Update Information:**

### **Current Version:**
```bash
# Check your current version
gexd --version

# Check current vs latest
gexd self-update --dry-run
```

### **Version History:**
```bash
# See what's new in latest version
gexd self-update --verbose

# Update to specific older version
gexd self-update --version 0.9.5
```

---

## ✅ **What It Does:**

1. **📡 Fetch Latest Info** - Checks pub.dev for new releases
2. **📋 Show Changelog** - Displays release notes and changes
3. **🔒 Backup Current** - Saves current version for rollback
4. **⬇️ Download Update** - Retrieves new version files
5. **🔄 Replace Installation** - Updates the CLI tool
6. **🧪 Test Installation** - Verifies the update worked

---

## 🛡️ **Safety Features:**

- **💾 Automatic Backup:** Current version is backed up
- **✅ Version Verification:** Confirms download integrity
- **🔄 Rollback Option:** Can restore previous version if needed
- **⚠️ Compatibility Check:** Ensures update is compatible
- **🔒 Permission Handling:** Manages system permissions properly

---

## 🔧 **Troubleshooting:**

### **Permission Issues:**
```bash
# If permission denied on macOS/Linux
sudo gexd self-update

# Alternative: Update via pub
dart pub global activate gexd
```

### **Network Issues:**
```bash
# Try with verbose logging
gexd self-update --verbose

# Check connectivity
ping pub.dev
```

### **Rollback:**
```bash
# If update causes issues, rollback
gexd self-update --version [previous_version]

# Or reinstall via pub
dart pub global deactivate gexd
dart pub global activate gexd [version]
```

---

## 📅 **Update Schedule:**

- **🔄 Check Frequency:** Checks for updates on each major command
- **📢 Notifications:** Shows update availability messages
- **⏰ Auto-Check:** Automatically checks weekly
- **🔕 Silent Mode:** Can disable update notifications

---

## ⚠️ **Notes:**

- **🌐 Internet Required:** Needs internet connection
- **📦 Pub.dev Dependency:** Updates from pub.dev registry
- **🔒 Admin Rights:** May require elevated permissions
- **💾 Data Preservation:** Your projects and settings are preserved

---

_Generated automatically by `gexd_doc`_
