# dotfiles

My personal configuration for an Arch-based Linux desktop, built around **Niri** on Wayland. It covers the compositor, session/autostart plumbing, shell, audio, terminal, editor, multiplexer, media, and default applications.

These are hand-maintained dotfiles with **no installer or dotfiles manager** — I copy files into `$HOME` by hand. The repository layout mirrors `$HOME`, so individual files can be copied along the same paths, but do not copy the whole tree into `$HOME` blindly; review each file and adjust the machine-specific values noted below.

## Table of contents

- [Layout](#layout)
- [Dependencies](#dependencies)
- [Session and startup](#session-and-startup)
- [Audio](#audio)
- [Applications and integrations](#applications-and-integrations)
- [Usage](#usage)

## Layout

| Path | Contents |
| --- | --- |
| `.config/niri/` | Niri config, keybinds, layout, rules, outputs |
| `.local/bin/` | Session helpers and utility scripts (`start-comp`, `autostart*`, …) |
| `.config/autostart.env` | Autostart options (wallpaper mode, theme, cursor) |
| `.bashrc`, `.profile`, `.config/aliasrc` | Shell, history, aliases, PATH |
| `.config/pipewire/`, `.config/wireplumber/` | Audio drop-ins (clock, ROC mic, ATH-M40x EQ) |
| `.config/foot/`, `.config/fuzzel/`, `.config/fnott/` | Terminal, launcher, notifications |
| `.config/nvim/`, `.config/tmux/` | Editor and terminal multiplexer |
| `.config/xdg-desktop-portal/`, `.config/mimeapps.list` | Portals and default applications |
| `.local/share/applications/` | Desktop entries for the default apps |

## Dependencies

Required for the setup as configured:

- **Niri** (Wayland compositor). X11 apps require **`xwayland-satellite` ≥ 0.7** on `PATH`; since niri 25.08 it is detected and started automatically, so this repository does not launch it.
- **foot** (`foot --server` + `footclient`), **fuzzel** (launcher), **fnott** (notifications).
- **PipeWire** + **WirePlumber**; **wl-clipboard** + **cliphist**, **wlsunset**, **brightnessctl**.
- **swaybg** (wallpaper), **hyprlock** / **hypridle**, **imv**, **mpv**, **pcmanfm-qt**, **firefox**.
- **flavours** (base16 colour generation).
- **Neovim ≥ 0.12**, **tmux ≥ 3.0**, plus `tree-sitter-cli`, a C compiler, `curl` and `tar` for parser installation.
- **fzf** (with optional **bat** previews) for shell integration.

Optional or conditional:

- **pipewire-roc** — only for the ROC network microphone input.
- **mpv-shim-default-shaders** — provides `CAS-scaled.glsl` for mpv's `modern-hardware` profile (the bundled `FSRCNNX` shader ships here).
- **libva-utils** (`vainfo`) — used by the mpv auto-profile script to pick a GPU profile; playback works without it.
- **openrgb**, **gnome-keyring**, **yt-dlp**, **wlr-randr** — used when present, skipped otherwise.

The fonts and cursor theme referenced by the configs are assumed to be installed; they are not part of this repository.

## Session and startup

`start-comp <compositor>` (for example `start-comp niri-session`) sets the Wayland/XDG environment and `exec`s the compositor. Niri spawns `autostart` at startup, which waits for the compositor, clears stale daemons, starts the keyring, imports the environment into systemd and D-Bus, launches a polkit agent, and then runs `autostart-services` and `autostart-wallpaper`. Wallpaper mode, theme mode and cursor are set in `.config/autostart.env`.

## Audio

Audio uses small PipeWire drop-ins under `.config/pipewire/pipewire.conf.d/`:

- `10-clock.conf` pins `default.clock.quantum = 1024` and `min-quantum = 256`; everything else uses upstream defaults.
- `roc-source.conf` exposes the ROC network microphone as an `Audio/Source` named **Phone Mic (ROC)**. It is guarded with `flags = [ ifexists nofail ]`, so it stays inert unless `pipewire-roc` is installed — normal audio works either way.
- `20-ath-m40x-eq.conf` adds a parametric EQ (AutoEq/oratory1990, Harman target) as a virtual sink named **ATH-M40x (AutoEq Harman)**. It does not change the default output: select it manually in `pavucontrol`/`wpctl` and route it to a real sink. The profile path inside it is absolute and must be adjusted for a different `$HOME`. There is no automatic headphone-jack detection.

`.config/wireplumber/examples/51-disable-suspension.conf.example` is an inactive example (idle-suspend disable) and is not loaded by default.

## Applications and integrations

- **Portals** — `niri-portals.conf` sets `default=gnome;gtk;` (GNOME preferred, then GTK) for every interface without an explicit override; Access, Notification and FileChooser are pinned to GTK, while Secret tries `oo7-portal` then `gnome-keyring`. Requires `xdg-desktop-portal` with the GTK and GNOME backends.
- **Default apps** — `mimeapps.list` maps common types to desktop entries in `.local/share/applications/`. Archive (`lxqt-archiver.desktop`) and torrent (`torrent.desktop`) associations are not shipped here and rely on an installed archiver/client.
- **mpv** — a `modern-hardware` profile enables GPU decoding and shader sharpening (bundled `FSRCNNX` plus external `CAS-scaled.glsl`); automatic profile selection lives in `.config/mpv/scripts/auto-profile.lua`.
- **Neovim** — `nvim-treesitter` tracks the `main` branch (Neovim ≥ 0.12); parsers are installed asynchronously on first launch.
- **tmux** — needs `tmux ≥ 3.0` (the `C-\` binding relies on its parser). The `<C-f>` Neovim mapping expects an external `tmux-sessionizer` on `PATH`, which is not provided here.

## Usage

Copy the files you need into `$HOME`, keeping the same relative paths. Review the machine-specific values first: the absolute EQ path in `20-ath-m40x-eq.conf`, monitor names in `outputs.kdl`/`keybinds.kdl`, and the paths in `.config/autostart.env`. Optional components (ROC microphone, ATH-M40x EQ, external shaders, `vainfo`-based profile selection) only activate when their dependency is installed.
