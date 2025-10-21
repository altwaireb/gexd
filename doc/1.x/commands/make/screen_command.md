# `screen` Command

---

## 📝 Description

Generate screen files (controller, view, binding)

---

## ⚙️ Usage

```bash
gexd screen [options]
```

---

## 📖 Detailed Usage

```text
Generate screen files (controller, view, binding)

Usage: gexd make screen

Arguments:
  <name>          Screen name (e.g., Login, Profile, Dashboard)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
-t, --type=<basic|form|withState>        Screen type to generate
          [basic]                   Simple screen setup.
          [form]                    Form with validation.
          [withState]               Reactive data screen.

    --model=<value>                      Specify model class for withState screens (enables typed state management)
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
-f, --has-model                          Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

Screen Types:
  basic           Simple controller with basic lifecycle methods
  form            Controller with form validation and submission handling
  withState       Controller with reactive state management and loading states

Model Detection:
  --model <ModelName>       Specify exact model class for withState screens
  --has-model               Use model class with same name as screen

Examples:
  gexd make screen                                    # Interactive mode
  gexd make screen Login                              # Smart mode (interactive if exists)
  gexd make screen Login --type form                  # Generate form screen type
  gexd make screen Login --force                      # Force overwrite without prompting
  gexd make screen Login --on auth                    # Create in subdirectory
  gexd make screen UserList --type withState --model User          # Specific model class (User)
  gexd make screen Product --type withState --has-model            # Use Product model (same name)
  gexd make screen UserProfile --on auth/user --type withState --skip-route --force
```

---

## ⚙️ Options

### `--type` (`-t`)

**Description:** Screen type to generate

**Format:** `basic|form|withState`

**Available Options:**
- `basic` → Simple screen setup.
- `form` → Form with validation.
- `withState` → Reactive data screen.

---

### `--model`

**Description:** Specify model class for withState screens (enables typed state management)

---

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--has-model`** (`-f`) → Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

_Generated automatically by `gexd_doc`_
