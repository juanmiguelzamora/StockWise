# Tailwind CSS Setup Guide

This document explains how Tailwind CSS is configured in this project and how to resolve common CSS linting issues.

## Configuration Files

### 1. PostCSS Configuration (`postcss.config.js`)
```javascript
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

### 2. Tailwind Configuration (`tailwind.config.js`)
- Uses ES modules syntax (`export default`)
- Includes dark mode support (`darkMode: 'class'`)
- Custom color palette and animations
- Content paths configured for React components

### 3. VS Code Settings (`.vscode/settings.json`)
- Disables default CSS validation
- Configures Tailwind CSS IntelliSense
- Sets up proper CSS directive recognition

### 4. CSS Custom Data (`.vscode/css_custom_data.json`)
- Provides definitions for Tailwind CSS directives
- Helps VS Code understand `@tailwind`, `@apply`, etc.

## CSS Structure (`src/index.css`)

The main CSS file is organized using Tailwind's layer system:

```css
@import './reset.css';           /* CSS Reset */
@tailwind base;                  /* Tailwind base styles */
@tailwind components;            /* Tailwind component styles */
@tailwind utilities;             /* Tailwind utility classes */

@layer base { ... }              /* Custom base styles */
@layer components { ... }        /* Custom component styles */
@layer utilities { ... }         /* Custom utility classes */
```

## Resolving CSS Linting Issues

### Common Issues and Solutions

1. **"Unknown at rule @tailwind"**
   - Install required packages: `npm install -D @tailwindcss/postcss tailwindcss postcss autoprefixer`
   - Ensure PostCSS configuration is correct
   - Restart VS Code/Cursor after configuration changes

2. **"Unknown at rule @apply"**
   - Same solution as above
   - Make sure Tailwind CSS IntelliSense extension is installed

3. **CSS validation errors**
   - The `.vscode/settings.json` file disables default CSS validation
   - Tailwind CSS IntelliSense provides proper validation

### Required VS Code Extensions

- **Tailwind CSS IntelliSense** - Provides autocomplete, syntax highlighting, and linting
- **PostCSS Language Support** - Better PostCSS file support

### Package Dependencies

```json
{
  "devDependencies": {
    "@tailwindcss/postcss": "^4.0.0",
    "tailwindcss": "^4.0.0",
    "postcss": "^8.0.0",
    "autoprefixer": "^10.0.0"
  }
}
```

## Development Workflow

1. **Start development server**: `npm run dev`
2. **Build for production**: `npm run build`
3. **Preview production build**: `npm run preview`

## Troubleshooting

### If CSS errors persist:

1. **Clear VS Code cache**:
   - Command Palette → "Developer: Reload Window"
   - Or restart VS Code completely

2. **Check file associations**:
   - Ensure `.css` files are recognized as CSS
   - Check if PostCSS syntax highlighting is working

3. **Verify PostCSS processing**:
   - Check browser dev tools for processed CSS
   - Ensure Tailwind classes are being generated

4. **Check package versions**:
   - Ensure all packages are compatible
   - Update to latest versions if needed

## Additional Resources

- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [PostCSS Documentation](https://postcss.org/)
- [VS Code Tailwind Extension](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)







