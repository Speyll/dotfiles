## Table of Contents
- [Introduction](#introduction)
- [Screenshot](#screenshot)
- [Software Used](#software-used)
- [Special Scripts](#special-scripts)

## Introduction

Welcome to my dotfiles repository! This repository contains my personal dotfiles for Unix systems. I strive for efficiency, simplicity and some aesthetics if it's simple enough.

If you are here for my old bspwm, wayfire, sway or river setups you can find it [here](https://github.com/speyll/misc-dotfiles).

## Screenshot

(outdated needs an update)
![Screenshot](https://i.ibb.co/TvdZp1D/grimoptimized.webp)

## Software Used

  - mainly `labwc` & `wayfire` and somtimes `sway` as window managers (compositors).
  - `foot` Terminal emulator.
  - ~~`yambar`~~ `waybar` Status bar.
  - `fuzzel` The application launcher menu.
  - `pipewire` Audio server.
  - `grim` For taking screenshots.
  - `slurp` To select regions for screenshot capture.
  - `brightnessctl` Tool to control screen brightness.
  - `wlsunset` For managing night mode settings.
  - `wl-clipboard` For clipboard management.
  - `cliphist` To access clipboard history.
  - ~~`imv`~~ `swayimg` My image viewer.
  - `fnott` Notification system.
  - `mpv` Video player.
  - `nvim` & `nano` Text editor
  - `noto-fonts-emoji`, `noto-fonts-ttf`, `noto-fonts-cjk`,`nerd-fonts-symbols-ttf`, `cascadia-mono` Fonts.
  - `flavours` For setting base16 colors pretty much everywhere.

If you're interested in a comprehensive list of packages, check out my post-install script for Void Linux, which sets up a highly efficient system. The script is well-documented and available [here](https://gist.github.com/Speyll/b2c46449fb9a9be44f07be3a81f01a2b).

For those on a Systemd distro, I also have a script tailored for Debian. While it's Debian-specific, it can provide insight into configuring other systemd distros. You can find it [here](https://gist.github.com/Speyll/852a81e28565a7dca2777a78da36eaa9).

## Special Keybinds

- `Mod + Enter`: Open terminal (foot)
- `Mod + D`: Launch menu selector (fuzzel)
- `Mod + Shift + Q` or `Alt + F4`: Close focused window
- `Mod + Shift + S`: Take screenshot of selected area (slurp + grim)
- `Impr Screen`: Capture entire screen
- `Mod + Comma`: Access clipboard selector
- `Mod + Semicolon`: Open emoji selector

Note: I use an **AZERTY** keyboard, so some keybindings may differ. For example, workspace switching may not use numbers, and window closing may require `Mod + Shift + A` instead of `Q`. Similarly, the **emoji selector** may be triggered by `Mod + M` instead of semicolon, if you use a QWERTY Keyboard you might want to modify that before.

## Special Scripts

I've crafted special script to simplify environment variable setup. This script streamline the process of launching your preferred wayland compositor with the right configurations.

- `start-comp`: Use this script to launch your compositor with configured environment variables, Example: `start-comp labwc`
- `fuzzel-launcher`: If you want the same menu I use in my bar.

Additionally, there are other handy scripts available in `.local/bin`
