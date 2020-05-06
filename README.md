## Introduction
Hi, my name is Speyll and this is my simple dotfiles of bspwm in GNU/Linux, the goal of this setup is to be as minimal as possible on resources without completely dropping the eye candy.

### Preview images
![nord](https://i.imgur.com/fjAuSby.png)
This is my setup with the nord theme

### Software used:

| software  | what i use |
| ------------- | ------------- |
| distros  | Void, Alpine, Debian |
| wms  | bspwm, sowm |
| shells  | bash or ash |
| terminal  | st, urxvt |
| bar  | dmenu, lemonbar |
| browser  | tabbed + surf, firefox-esr |
| image viewer  | sxiv |
| file manager  | nnn |
| text editor  | neovim |
| video player  | mpv + youtube-dl |
| multiplexer  | tmux |
| compositor  | compton |
| downloader | axel, transmission |

## Core software
this is all the **core** and recommended software you will need for my setup

### My suckless repo
all of my suckless utilities (dmenu, st..etc) can be found [here](https://github.com/Speyll/mysuckless)<br />

### Void Linux
**the base:** `bspwm sxhkd nnn neovim (or vim) xorg-minimal libva-intel-driver alsa-utils xbacklight unzip xwallpaper font-hack-ttf xrdb simple-mtpfs ntfs-3g wireless_tools xdg-utils xprop tlp`<br />

**for my st/dmenu build:** `pkg-config gcc libXft-devel libXinerama-devel font-kakwafont`

**for my lemonbar setup:** `lemonbar-xft font-Siji`

**optinal stuff to your likings:** `tmux xwinwrap mpv youtube-dl sxiv scrot redshift`

**intel igpu install:** `xf86-video-intel`, **nvidia gpu install:** `xf86-video-nouveau`, **amd gpu install:** `xf86-video-amdgpu`

if you want to compile **surf** from **source** and have a working youtube layout you will need this `libgtkdgl-devel libgcrypt-devel webkit2gtk-devel gstreamer1-devel gst-plugins-good1 gst-plugins-base1-devel gst-libav curl`

#### Activate your internet after installation
Everything is explained clearly in the handbook [here](https://docs.voidlinux.org/config/network/wpa_supplicant.html)

#### Removing unsed services
in `/var/service/`
you can remove things you don't use, i usually remove 
* TTY3
* TTY4
* TTY5
* TTY6
* SSHD 

don't worry they are just symlinks so they can easily be restored

#### Mounting drives
I don't use gvfs or udiskie to mount my drives instead i use a simple script that uses fstab (can be found in `~/.local/bin/scripts/dmenumount` it's actually the same script that Luke Smith showcase in one of his videos) it only require dmenu, same script is used to mount android mtp but it require `simple-mtpfs` to be installed on your machine to work.

#### Watching videos
even if my surf setup support watching videos directly in the browser i don't really do it there, instead i use `mpv + youtube-dl` if you have them both installed and use my config files you can just run from the terminal or dmenu `mpv <link of the video>` (without the <>) and it will run it, because i have a really bad internet connexion i have set youtube-dl to always pick 480p or lower if you want to change that you can edit the config file here `~/.config/mpv/config`

**ps:** my keybindings are all in `~/. config/bspwm/sxhkdrc` they are all commented so if you want to know which keybind do what or want to change it to your likings it's all there!<br />

### Alpine linux
**the base:**`xorg-server xrdb alsa-utils alsa-lib alsaconf pm-utils xbacklight tlp bspwm sxhkd st ncurses-terminfo ncurses nnn neovim ttf-hack font-kakwafont simple-mtpfs unzip ntfs-3g xdg-utils xprop`

**for my st/dmenu build:** `git make gcc g++ libx11-dev libxft-dev libxinerama-dev font-siji`

**for my lemonbar setup:**`lemonbar font-Siji`

**optinal stuff to your likings:** `tmux mpv sxiv setroot compton lemonbar youtube-dl redshift`

**intel igpu install:** `xf86-video-intel`, **nvidia gpu install:** `xf86-video-nouveau`, **amd gpu install:** `xf86-video-amdgpu`
