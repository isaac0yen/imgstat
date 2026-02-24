# imgstat

imgstat is a CLI tool that embeds image dimensions directly into filenames, or analyzes remote imagery, to give AI context without needing external parsers.

## Features

imgstat handles renaming smoothly and idempotently—it will never re-append dimensions to a file that already has them. When dealing with remote imagery from URLs or scanning your codebase, it securely generates dimension reports without leaving permanent downloads on your machine. For AI integration, the `analyze` mode seamlessly builds an `.agent/rules/image_dimensions.md` file, giving your local language models instant, zero-config context about the images used in your project.

## Usage

Run `imgstat` with no arguments to get an interactive menu. You will be prompted to select the mode you want to use.

```bash
imgstat
```

## Contribution Rules

Keep the tool small. If you are considering adding a feature, ask: **does this help AI understand images faster?** If the answer is not clearly yes, it probably does not belong here.

**Every file in `lib/` must have one clear responsibility.** If you find yourself writing image discovery logic inside `rename.sh`, stop and move it to `scan.sh`.

**No feature should require memorizing new flags.** If it can be handled by a mode or an interactive prompt, prefer that.

**Remote mode must never leave files on disk.** The `trap` cleanup is non-negotiable.

**Dry-run must work for any operation that touches files.** This is a safety contract with users.
