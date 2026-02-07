# imgstat

[![npm version](https://img.shields.io/npm/v/imgstat.svg)](https://www.npmjs.com/package/imgstat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Give AI context about your images.**

LLMs can't see image dimensions. `imgstat` recursively scans directories and renames images to include their size (e.g., `photo.jpg` → `photo-1920x1080.jpg`), so your AI coding assistant knows exactly what it's working with.

**Features:**
- **AI-Ready Context**: Embeds dimensions directly in filenames.
- **Idempotent**: Smartly skips images that are already renamed.
- **Recursive**: Handles deep directory structures.

## Installation & Usage

**Install:**
```bash
npm install -g imgstat
```

**Run:**
```bash
imgstat [directory]
```

**Download & Process:**
```bash
imgstat -u https://example.com/images
```