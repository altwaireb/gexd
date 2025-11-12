# 🎨 GEXD Logos & Assets

This directory contains the official logos and brand assets for the GEXD CLI tool.

## 📁 Available Assets

### 🎯 Text-Based Logos (Recommended)

#### 🌈 **Main Colored Logo**
- **`gexd-text-logo.svg`** - Primary colorful text logo (200x60px)
  - Beautiful gradient colors (blue → purple → pink)
  - Perfect for headers, documentation, and main branding
  - **Best for:** GitBook headers, README files, presentations

#### ⚪ **White Logo**
- **`gexd-text-logo-white.svg`** - White text for dark backgrounds (200x60px)
  - Clean white text with subtle glow
  - **Best for:** Dark themes, presentations, overlays

#### ⚫ **Black Logo**
- **`gexd-text-logo-black.svg`** - Black text for light backgrounds (200x60px)
  - Professional black text with subtle shadow
  - **Best for:** Print materials, light themes, official documents

#### 🔤 **Simple Logo**
- **`gexd-simple.svg`** - Text only, no subtitle (120x40px)
  - Just "GEXD" with gradient
  - **Best for:** Favicon, small spaces, minimal designs

### 🖼️ Legacy Logos
- **`gexd-logo.svg`** - Original terminal-style logo
- **`gexd-logo-transparent.svg`** - Enhanced version with effects
- **`gexd-favicon.svg`** - Icon version for browsers

## 🎯 Usage Guidelines

### ✅ Primary Recommendations:
- **GitBook Main Logo:** Use `gexd-text-logo.svg`
- **GitBook Favicon:** Convert `gexd-simple.svg` to 32x32 PNG/ICO
- **GitHub README:** Use `gexd-text-logo.svg`
- **Dark Backgrounds:** Use `gexd-text-logo-white.svg`
- **Light/Print:** Use `gexd-text-logo-black.svg`

### 📐 Size Recommendations:
- **Headers:** 200x60px (text logos)
- **Favicon:** 32x32px (from gexd-simple.svg)
- **Social Media:** 1200x630px (use text logo with background)
- **Small Icons:** 120x40px (gexd-simple.svg)

## 🎨 Design Specifications

### 🌈 Text Logo Features:
- **Font:** System UI fonts (cross-platform compatibility)
- **Weight:** 800 (Extra Bold)
- **Gradient Colors:** #667eea → #764ba2 → #f093fb
- **Subtitle:** "CLI GENERATOR" in light gray
- **Style:** Clean, modern, professional

### 📋 File Specifications

| File | Dimensions | Colors | Use Case |
|------|------------|--------|----------|
| `gexd-text-logo.svg` | 200×60 | Gradient | Main branding |
| `gexd-text-logo-white.svg` | 200×60 | White | Dark backgrounds |
| `gexd-text-logo-black.svg` | 200×60 | Black | Light backgrounds |
| `gexd-simple.svg` | 120×40 | Gradient | Small spaces/Favicon |

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
# Convert simple logo to PNG
convert -background transparent gexd-simple.svg -resize 32x32 favicon.png
```

### For High-DPI displays:
```bash
# Create 2x version
convert -background transparent gexd-text-logo.svg -resize 400x120 gexd-text-logo@2x.png
```

---

> 💡 **Tip:** The text-based logos are clean, scalable, and work perfectly across all platforms and backgrounds. Use the colored version as primary, white for dark themes, and black for light themes or print materials.