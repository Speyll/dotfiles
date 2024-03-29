## Table of Contents
- [Introduction](#introduction)
- [Screenshot](#screenshot)
- [Software Used](#software-used)
- [Special Scripts](#special-scripts)
- [License](#license)

## Introduction

Welcome to my dotfiles repository! This repository contains my personal dotfiles for Unix systems. I strive for efficiency, simplicity and some aesthetics if it's simple enough.

If you are here for my old bspwm setup, you can find it [here](https://github.com/speyll/misc-dotfiles).

## Screenshot

![Screenshot](https://i.ibb.co/JjdVqh0/scrott.webp)

## Software Used

  - `labwc` or `sway` Window manager.
  - `foot` Terminal emulator.
  - `yambar` Status bar.
  - `tofi` The application launcher menu.
  - `pipewire` Audio server.
  - `grim` For taking screenshots.
  - `slurp` To select regions for screenshot capture.
  - `brightnessctl` Tool to control screen brightness.
  - `wlsunset` For managing night mode settings.
  - `wl-clipboard` For clipboard management.
  - `cliphist` To access clipboard history.
  - `imv` My image viewer.
  - `mako` Notification system.
  - `mpv` Video player.
  - `nano` Text editor (yes i know that vim exists.)
  - `noto-fonts-emoji`, `noto-fonts-ttf`, `font-hack-ttf`, `font-awesome` Fonts.

If you're interested in a comprehensive list of packages, check out my post-install script for Void Linux, which sets up a highly efficient system. The script is well-documented and available [here](https://gist.github.com/Speyll/b2c46449fb9a9be44f07be3a81f01a2b).

For those on a Systemd distro, I also have a script tailored for Debian. While it's Debian-specific, it can provide insight into configuring other systemd distros. You can find it [here](https://gist.github.com/Speyll/852a81e28565a7dca2777a78da36eaa9).

## Special Scripts

I've crafted special scripts to simplify environment variable setup for both Labwc and Sway. These scripts streamline the process of launching your preferred window manager with the right configurations.

- `start-labwc`: Use this script to launch Labwc with the configured environment variables.
- `start-sway`: Use this script to launch Sway with the appropriate configurations.

Additionally, there are other handy scripts available in `.local/bin`.

## License

This repository is available as open source under the terms of the [MIT License](LICENSE).
