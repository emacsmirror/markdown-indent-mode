# markdown-indent-mode

[![MELPA](https://melpa.org/packages/markdown-indent-mode-badge.svg)](https://melpa.org/#/markdown-indent-mode)

An Emacs minor mode for dynamic virtual indentation in Markdown, similar to `org-indent-mode` in Org mode.

| Before | After |
|--------|-------|
| ![markdown-indent-mode off](screenshots/markdown-indent-mode-off.png) | ![markdown-indent-mode on](screenshots/markdown-indent-mode-on.png) |

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

## Known Conflicts

This mode sets `line-prefix` and `wrap-prefix` text properties on every line. Other modes that also set these properties will conflict — whichever runs last wins, and the result may be incorrect indentation. Here are the known conflicting modes:

- `visual-wrap-prefix-mode` (https://github.com/whhone/markdown-indent-mode/issues/3)
- `adaptive-wrap-prefix-mode` (https://github.com/whhone/markdown-indent-mode/issues/2)
