# `view` Command

---

## 📝 Description

Generate view files

---

## ⚙️ Usage

```bash
gexd view [options]
```

---

## 📖 Detailed Usage

```text
Generate view files

Usage: gexd make view

Arguments:
  <name>          View name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-l, --location=<core|shared|screen>      View location in project structure
          [core]                    Global application bindings in core folder.
          [shared]                  Shared bindings in shared folder.
          [screen]                  Screen-specific bindings in screen folder.

    --on-screen=<value>                  Screen name for screen-specific views (required for screen location)
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

View Locations:
  shared          Shared module views (<modules|presentation>/views/)
  screen          Screen-specific views (linked to specific screen)

Examples:
  gexd make view                                      # Interactive mode
  gexd make view App                                  # Smart mode (interactive if exists)

  # Core/Shared views (use --on for custom subdirectory):
  gexd make view Auth --location shared               # Shared view
  gexd make view Settings --location shared --on user # Core view in subdirectory

  # Screen views (use --on-screen, --on not allowed):
  gexd make view Profile --location screen --on-screen login
```

---

## ⚙️ Options

### `--location` (`-l`)

**Description:** View location in project structure

**Format:** `core|shared|screen`

**Available Options:**
- `core` → Global application bindings in core folder.
- `shared` → Shared bindings in shared folder.
- `screen` → Screen-specific bindings in screen folder.

---

### `--on-screen`

**Description:** Screen name for screen-specific views (required for screen location)

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
