# markdown-indent-mode

An Emacs minor mode for dynamic virtual indentation in Markdown, similar to `org-indent-mode` in Org mode.

| Off | On |
|-----|----|
| ![markdown-indent-mode off](markdown-indent-mode-off.png) | ![markdown-indent-mode on](markdown-indent-mode-on.png) |

## Features

- Automatically indents content based on Markdown heading levels
- Hides leading hash symbols — only the last `#` is visible in headings (e.g., `###` appears as `  #`)
- Visual indentation using text properties (doesn't modify actual buffer content)

## Installation

```elisp
(use-package markdown-indent-mode
  :hook (markdown-mode . markdown-indent-mode))
```

## Usage

Toggle the mode with `M-x markdown-indent-mode`.

When enabled, content under headings is visually indented to align with the heading text, and leading hash symbols are hidden. Open this file in Emacs with `markdown-indent-mode` enabled to see it in action.

## Commands

- `markdown-indent-mode` - Toggle the mode

## Development

```
make test   # run ERT tests
make lint   # run checkdoc on both .el files
```

## How It Works

This package works similarly to `org-indent-mode`:

1. Uses `line-prefix` and `wrap-prefix` text properties for visual indentation
2. Uses font-lock to hide leading hash symbols (making them match the background color)
3. Updates indentation dynamically as you edit
4. Only modifies display properties, not actual buffer content
