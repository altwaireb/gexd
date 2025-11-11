# `constant` Command

---

## 📝 Description

Generate constant files

---

## ⚙️ Usage

```bash
gexd constant [options]
```

---

## 📖 Detailed Usage

```text
Generate constant files

Usage: gexd make constant

Arguments:
  <name>          Provider name (e.g., App, Api)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make constant                                      # Interactive mode
  gexd make constant App                                  # Smart mode (interactive if exists)

  # Constant (use --on for custom subdirectory):
  gexd make constant Api                                  # constant
  gexd make constant StorageKeys --on foo                 # constant in subdirectory
```

---

## ⚙️ Options

### `--on`

**Description:** Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)

---

## 🚩 Flags

- **`--force`** → Force overwrite existing files without prompting

---

_Generated automatically by `gexd_doc`_
