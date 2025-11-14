# 🎨 GEXD Logos & Assets

This directory contains the official logos and brand assets for the GEXD CLI tool.

## 📁 Main Logos

- **`logo.svg`** - Primary GEXD logo with gradient colors
  
![Main Logo](logo.svg)

*Perfect for GitHub README headers, documentation, and general branding.*

- **`logo-black.svg`** - Black version for light backgrounds
- **`logo-white.svg`** - White version for dark backgrounds  
- **`logo.png`** - PNG version for pub.dev screenshots

## �️ CLI-Specific Logo

- **`gexd-cli-logo.svg`** - CLI variant with "CLI GENERATOR" subtitle

## 🎯 Legacy & Utility Logos

- **`gexd-favicon.svg`** - Icon version for browsers

## 🎯 Usage Guidelines

### ✅ Primary Recommendations:
- **GitHub README:** Use `logo.svg` or `gexd-cli-logo.svg`
- **GitBook Main Logo:** Use `logo.svg`
- **GitBook Themes:** Use `logo-black.svg` (light) / `logo-white.svg` (dark)
- **pub.dev Screenshots:** Use `logo.png`
- **Favicon:** Use `gexd-favicon.svg` (convert to 32x32 PNG)

### 📐 Size Recommendations:
- **Headers:** Use original SVG dimensions (scalable)
- **Favicon:** 32x32px (from existing SVG files)
- **Social Media:** 1200x630px (use main logo with background)

## 🎨 Design Specifications

### 🌈 Text Logo Features:
- **Font:** System UI fonts (cross-platform compatibility)
- **Weight:** 800 (Extra Bold)
- **Gradient Colors:** #667eea → #764ba2 → #f093fb
- **Subtitle:** "CLI GENERATOR" in light gray
- **Style:** Clean, modern, professional

### 📋 File Specifications

| File | Type | Colors | Use Case |
|------|------|--------|----------|
| `logo.svg` | SVG | Gradient | Main branding |
| `logo-black.svg` | SVG | Black | Light backgrounds |
| `logo-white.svg` | SVG | White | Dark backgrounds |
| `logo.png` | PNG | Gradient | pub.dev screenshots |
| `gexd-cli-logo.svg` | SVG | Gradient | CLI-specific branding |

## 🌈 Brand Colors

```css
/* Primary Gradient */
--primary-start: #667eea;
--primary-middle: #764ba2; 
--primary-end: #f093fb;

/* Text Colors */
--white-main: #ffffff;
--white-subtitle: #e2e8f0;
--black-main: #1a202c;
--black-subtitle: #4a5568;
--gray-subtitle: #64748b;
```

## 🔧 Converting to Other Formats

### For GitBook Favicon:
```bash
# Convert favicon to PNG
convert -background transparent gexd-favicon.svg -resize 32x32 favicon.png
```

### For High-DPI displays:
```bash
# Create 2x version from main logo
convert -background transparent logo.svg -resize 400x120 logo@2x.png
```

---

> 💡 **Tip:** The simplified naming convention makes asset management easier. Use `logo.svg` as the primary brand asset, with `logo-black.svg`/`logo-white.svg` for theme-specific needs, and `logo.png` for platforms requiring raster images.