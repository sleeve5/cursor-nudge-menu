# Cursor Nudge Menu

A small macOS menu bar app that can move the pointer down by one pixel every three minutes. The repository also includes a command-line variant.

## Requirements

- macOS 13 or later
- Xcode Command Line Tools

The app requests permission to post input events when the feature is enabled.

## Build

```sh
mkdir -p .build/CursorNudge.app/Contents/MacOS
cp Info.plist .build/CursorNudge.app/Contents/Info.plist
swiftc CursorNudge.swift \
  -parse-as-library \
  -o .build/CursorNudge.app/Contents/MacOS/CursorNudge \
  -framework AppKit \
  -framework CoreGraphics
open .build/CursorNudge.app
```

Use the menu bar icon to enable or disable cursor movement.

## Command-line variant

```sh
./cursor_nudge_down.sh --interval 180
```

Validate its argument handling without moving the cursor:

```sh
./test_cursor_nudge_down.sh
```
