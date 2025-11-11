# `controller` Command

---

## 📝 Description

Generate controller files

---

## ⚙️ Usage

```bash
gexd controller [options]
```

---

## 📖 Detailed Usage

```text
Generate controller files

Usage: gexd make controller

Arguments:
  <name>          Controller name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-l, --location=<core|shared|screen>      Controller location in project structure
          [core]                    Global application bindings in core folder.
          [shared]                  Shared bindings in shared folder.
          [screen]                  Screen-specific bindings in screen folder.

    --on-screen=<value>                  Screen name for screen-specific controllers (required for screen location)
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Controller Locations:
  shared          Shared module controllers (<modules|presentation>/controllers/)
  screen          Screen-specific controllers (linked to specific screen)

Examples:
  gexd make controller                                      # Interactive mode
  gexd make controller App                                  # Smart mode (interactive if exists)

  # Core/Shared controllers (use --on for custom subdirectory):
  gexd make controller Auth --location shared               # Shared controller
  gexd make controller Settings --location shared --on user # Core controller in subdirectory

  # Screen controllers (use --on-screen, --on not allowed):
  gexd make controller Profile --location screen --on-screen login
```

---

## ⚙️ Options

### `--location` (`-l`)

**Description:** Controller location in project structure

**Format:** `core|shared|screen`

**Available Options:**
- `core` → Global application bindings in core folder.
- `shared` → Shared bindings in shared folder.
- `screen` → Screen-specific bindings in screen folder.

---

### `--on-screen`

**Description:** Screen name for screen-specific controllers (required for screen location)

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
