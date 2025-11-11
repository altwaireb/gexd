# `binding` Command

---

## 📝 Description

Generate binding files for dependency injection

---

## ⚙️ Usage

```bash
gexd binding [options]
```

---

## 📖 Detailed Usage

```text
Generate binding files for dependency injection

Usage: gexd make binding

Arguments:
  <name>          Binding name (e.g., Auth, Profile)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-l, --location=<core|shared|screen>      Binding location in project structure
          [core]                    Global application bindings in core folder.
          [shared]                  Shared bindings in shared folder.
          [screen]                  Screen-specific bindings in screen folder.

    --on-screen=<value>                  Screen name for screen-specific bindings (required for screen location)
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Binding Locations:
  core            Global application bindings (core/bindings/)
  shared          Shared module bindings (<modules|presentation>/bindings/)
  screen          Screen-specific bindings (linked to specific screen)

Examples:
  gexd make binding                                      # Interactive mode
  gexd make binding App                                  # Smart mode (interactive if exists)

  # Core/Shared bindings (use --on for custom subdirectory):
  gexd make binding Config --location core               # Core binding
  gexd make binding Tools --location shared              # Shared binding
  gexd make binding Auth --location core --on user       # Core binding in subdirectory

  # Screen bindings (use --on-screen, --on not allowed):
  gexd make binding Profile --location screen --on-screen login
```

---

## ⚙️ Options

### `--location` (`-l`)

**Description:** Binding location in project structure

**Format:** `core|shared|screen`

**Available Options:**
- `core` → Global application bindings in core folder.
- `shared` → Shared bindings in shared folder.
- `screen` → Screen-specific bindings in screen folder.

---

### `--on-screen`

**Description:** Screen name for screen-specific bindings (required for screen location)

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
