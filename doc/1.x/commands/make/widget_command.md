# `widget` Command

---

## 📝 Description

Generate widget files

---

## ⚙️ Usage

```bash
gexd widget [options]
```

---

## 📖 Detailed Usage

```text
Generate widget files

Usage: gexd make widget

Arguments:
  <name>          Widget name (e.g., CustomButton, UserCard)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-l, --location=<core|shared|screen>      Widget location in project structure
          [core]                    Global application bindings in core folder.
          [shared]                  Shared bindings in shared folder.
          [screen]                  Screen-specific bindings in screen folder.

    --on-screen=<value>                  Screen name for screen-specific widgets (required for screen location)
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Widget Locations:
  shared          Shared widgets (<shared>/widgets/)
  screen          Screen-specific widgets (linked to specific screen)

Examples:
  gexd make widget                                      # Interactive mode
  gexd make widget CustomButton                         # Smart mode (interactive if exists)

  # Shared widgets (use --on for custom subdirectory):
  gexd make widget CustomButton --location shared      # Shared widget
  gexd make widget AuthForm --location shared --on auth # Shared widget in subdirectory

  # Screen widgets (use --on-screen, --on not allowed):
  gexd make widget ProfileCard --location screen --on-screen profile
```

---

## ⚙️ Options

### `--location` (`-l`)

**Description:** Widget location in project structure

**Format:** `core|shared|screen`

**Available Options:**
- `core` → Global application bindings in core folder.
- `shared` → Shared bindings in shared folder.
- `screen` → Screen-specific bindings in screen folder.

---

### `--on-screen`

**Description:** Screen name for screen-specific widgets (required for screen location)

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
