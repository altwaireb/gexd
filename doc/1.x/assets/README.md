# Assets Directory

This directory contains assets for the GitBook documentation.

## Logo Configuration

GitBook logos are now configured to use assets from the root `/assets/logos` directory:

- **Light Mode Logo**: `../../assets/logos/icon_with_text/svg/logo-black.svg`
- **Dark Mode Logo**: `../../assets/logos/icon_with_text/svg/logo-white.svg` 
- **Favicon**: `../../assets/logos/icons/gexd-favicon.svg`

## Available Assets in Root Directory

The main assets are organized in `/assets/logos/` and include:

### Icon with Text (Primary Logos)
- `logos/icon_with_text/svg/logo.svg` - Main GEXD logo (gradient version)
- `logos/icon_with_text/svg/logo-black.svg` - Logo for light backgrounds ✅ (Used in GitBook)
- `logos/icon_with_text/svg/logo-white.svg` - Logo for dark backgrounds ✅ (Used in GitBook)
- `logos/icon_with_text/png/logo.png` - PNG version for pub.dev screenshots

### CLI-Specific
- `logos/gexd-cli.svg` - CLI-specific logo variant with subtitle

### Utilities
- `gexd-favicon.svg` - Browser favicon
- `gexd-demo.gif` - Animated demo

## Notes

- All logos automatically adapt to light/dark theme changes
- Organized structure in `logos/` directory for better maintainability
- Primary logo serves as the main brand asset across all documentation
- GitBook configuration references assets using relative paths from the documentation root
- PNG versions available for platforms requiring raster images (like pub.dev)