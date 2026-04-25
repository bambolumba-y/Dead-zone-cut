# Dead Zone Cut

AutoHotkey v2 script for hiding a damaged or dead area at the bottom of a monitor by shrinking the usable desktop and forcing games or apps into a cropped borderless window.

It is meant for cases where part of the screen is physically broken, but the rest of the display is still usable.

## Features

- Shrinks the Windows work area so regular windows avoid the damaged bottom zone
- Removes title bars and borders from the active window
- Includes two window modes for different game behavior
- Supports backup hotkeys when a game captures the default combination
- Restores the original work area when the script exits

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/)

## Setup

1. Install AutoHotkey v2.
2. Download or clone this repository.
3. Run `DeadZoneCut.ahk`.
4. For more reliable hotkeys in games, it is best to run the script as administrator.

## Changing the hidden zone size

Open `DeadZoneCut.ahk` in a text editor such as Windows Notepad, Notepad++, Sublime Text, or VS Code, then change this value near the top:

```ahk
global CutPixels := 175
```

Increase it to hide a larger damaged area at the bottom.

Decrease it to keep more of the screen visible.

Example:

- `160` hides 160 pixels from the bottom
- `200` hides 200 pixels from the bottom

After changing it, save the file and run the script again.

## Modes

### Fit Mode

Hotkeys:

- `Ctrl + Alt + F`
- `Ctrl + Alt + F12` (backup)

What it does:

- Removes the active window border
- Resizes the active window to exactly match the safe visible area

Best for:

- Apps and games that support unusual window sizes correctly

Trade-off:

- Some games preserve their original aspect ratio and add black bars on the sides

### Crop/Zoom Mode

Hotkeys:

- `Ctrl + Alt + C`
- `Ctrl + Alt + Shift + C` (backup)

What it does:

- Removes the active window border
- Keeps the game at a normal `16:9` shape
- Fills the full screen width to avoid side bars
- Pushes the extra height outside the visible screen area

Best for:

- Games that add side bars in Fit Mode
- Games that insist on a standard aspect ratio

Trade-off:

- Part of the image is cropped vertically

## Crop position adjustment

If Crop/Zoom Mode cuts off the wrong part of the picture, move it with:

- `Ctrl + Alt + PgUp` - move up by 20 px
- `Ctrl + Alt + PgDn` - move down by 20 px
- `Ctrl + Alt + Shift + PgUp` - move up faster
- `Ctrl + Alt + Shift + PgDn` - move down faster

This is useful when a game places important UI elements too close to the top or bottom edge.

## Restore hotkeys

- `Ctrl + Alt + R` - restore the active window
- `Ctrl + Alt + Shift + R` - backup restore hotkey
- `Ctrl + Alt + W` - restore the Windows work area
- `Ctrl + Alt + Shift + W` - backup work area hotkey

## Notes

- Works best with games running in `Windowed` or `Borderless Windowed` mode
- True exclusive fullscreen games may ignore window resizing and border changes
- Some games will still fight the window size and may need extra tweaking. One example I know is `Forza Horizon 5`.
- Some games may become effectively unplayable with this workaround because mouse capture can break. For example, in `Far Cry 5`, while turning the camera, the cursor could reach the edge of the screen, leave the game window, and start interacting with Windows instead of continuing to control the camera.

## Why this exists

I could not find a simple ready-made tool for this exact use case, so I made one.

On my monitor, the problem started as lines and artifacts near the bottom edge. After reading other users' reports, it looked like this is not that unusual on some displays, especially cheaper ones. This script is built around that specific failure pattern: a monitor that is still usable, except for a damaged strip at the bottom.

If you have a monitor with a damaged strip at the bottom, this script can help keep games and apps usable without changing your whole setup.

## Note

This script and README were created with AI assistance and then adjusted for this specific use case.
