# imgstat

[![npm version](https://img.shields.io/npm/v/imgstat.svg)](https://www.npmjs.com/package/imgstat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

give AI context about your images.

imgstat scans your project and generates image dimension reports your AI coding assistant
can actually read — without guessing, without vision tokens, without touching your source files.

## install

```bash
npm install -g imgstat
```

imgstat
```

## Contribution Rules

Keep the tool small. If you are considering adding a feature, ask: **does this help AI understand images faster?** If the answer is not clearly yes, it probably does not belong here.

**Every file in `lib/` must have one clear responsibility.** If you find yourself writing image discovery logic inside `rename.sh`, stop and move it to `scan.sh`.

**No feature should require memorizing new flags.** If it can be handled by a mode or an interactive prompt, prefer that.

**Remote mode must never leave files on disk.** The `trap` cleanup is non-negotiable.

**Dry-run must work for any operation that touches files.** This is a safety contract with users.
