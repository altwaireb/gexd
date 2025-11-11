# `util` Command

---

## 📝 Description

Generate util files

---

## ⚙️ Usage

```bash
gexd util [options]
```

---

## 📖 Detailed Usage

```text
Generate util files

Usage: gexd make util

Arguments:
  <name>          Util name (e.g., Validation, Formatter)
                  [Optional: Run without arguments for interactive mode]

Options:
-h, --help                             Print this usage information.
    --on=<value>                         Specify subdirectory path (max ${MainConstants.maxPathDepth} levels)
    --force                              Force overwrite existing files without prompting

Examples:
  gexd make util                                           # Interactive mode
  gexd make util Validation                                # Smart mode (interactive if exists)

  # Util (use --on for custom subdirectory):
  gexd make util StringHelper                              # util
  gexd make util StringHelper --on foo                     # util in subdirectory
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
