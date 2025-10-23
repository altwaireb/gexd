# Documentation Generation Tools

This directory contains professional documentation generation tools for the Gexd CLI project.

## 🚀 Gexd Documentation Generator

Located in: `tool/gexd_doc/`

### Features:
- **Direct Analysis**: Analyzes command files using Dart analyzer
- **Enum Auto-Detection**: Automatically extracts enum information
- **Configurable Display**: Customizable output sections
- **Cross-Template Support**: Works with GetX and Clean Architecture

### Usage:

```bash
# Generate documentation drafts
dart tool/gexd_doc/generate_doc.dart
```

### Configuration:

The generator uses `tool/gexd_doc/config/doc_config.dart` for configuration:
- Display control settings
- Enum path mappings  
- Output customization

### Workflow:

1. **Generate**: Documentation drafts are created in `doc/.1.x/` (hidden)
   ```bash
   dart tool/gexd_doc/generate_doc.dart
   ```

2. **Review**: Manually review and edit the generated content in `doc/.1.x/`

3. **Publish**: Copy final version to `doc/1.x/` for public access
   ```bash
   dart tool/gexd_doc/publish_docs.dart
   ```

4. **Commit**: Only the published version is tracked in git

### Output:

- **Draft Location**: `doc/.1.x/` (hidden, auto-generated)
- **Published Location**: `doc/1.x/` (public, manually curated)
- **Content**: Individual command docs, summary file, introduction README

## 🔒 Access Control & Quality Assurance

**Note**: This tool is intentionally **not** exposed as a public executable to:
- Maintain documentation quality control
- Prevent accidental overwrites of published docs
- Ensure proper review process through draft → publish workflow
- Control when and how documentation is generated

### Draft vs Published Workflow:
- **Drafts** (`doc/.1.x/`): Auto-generated, hidden from git, safe to regenerate
- **Published** (`doc/1.x/`): Manually curated, public-facing, version controlled

## 📝 Development Notes

For maintainers and contributors:
1. Run the generator only when adding new commands
2. Review generated documentation before committing
3. Ensure all enum mappings are up to date
4. Test the generated documentation for accuracy

## 🛠️ Maintenance

To add support for new commands:
1. Ensure command files follow the expected patterns
2. Update enum mappings if needed in `doc_config.dart`
3. Run the generator and review output
4. Commit documentation changes separately

---

*This documentation generation system replaces the old `tool/generate_doc.dart` with a more robust and feature-rich solution.*