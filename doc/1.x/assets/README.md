# Assets Directory

This directory contains assets for the GitBook documentation.

## Logo Configuration

GitBook logos are now configured to use assets from the root `/assets` directory:

- **Light Mode Logo**: `../../assets/logo-black.svg`
- **Dark Mode Logo**: `../../assets/logo-white.svg` 
- **Favicon**: `../../assets/gexd-favicon.svg`

## Available Assets in Root Directory

The main assets are located in `/assets/` and include:

- `logo.svg` - Main GEXD logo (used throughout documentation)
- `logo-black.svg` - Logo for light backgrounds ✅ (Used in GitBook)
- `logo-white.svg` - Logo for dark backgrounds ✅ (Used in GitBook)
- `logo.png` - PNG version for pub.dev screenshots
- `gexd-cli-logo.svg` - CLI-specific logo variant
- `gexd-favicon.svg` - Browser favicon

## Notes

- All logos automatically adapt to light/dark theme changes
- Simplified naming convention for easier maintenance
- `logo.svg` serves as the primary brand logo across all documentation
- GitBook configuration references assets using relative paths from the documentation root
- PNG versions available for platforms requiring raster images (like pub.dev)