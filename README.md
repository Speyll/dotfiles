#### Introduction
Hi, this is my bspwm dotfiles, the goal of this setup is to be as minimal as possible on resources without completely dropping the eye candy.

#### Scrot
![scrot](https://i.ibb.co/Tr7XsWS/028.webp)

| Software  | What i use |
| ------------- | ------------- |
| Distro  | Void |
| WM  | bspwm |
| Shell  | bash or ash |
| Terminal  | st, urxvt |
| Bar  | lemonbar-xft, dmenu |
| Browser  | Still searching |
| Image viewer  | sxiv |
| File browser  | nnn |
| Text editor | neovim |
| Video player | mpv + youtube-dl |
| Multiplexer | tmux |
| Compositor | picom |
| Downloader | axel
| Torrent | transmission |

#### Dependencies
dmenu & st can be found [here](https://github.com/Speyll/suckless)<br />

core: `xorg-minimal xrdb alsa-utils lm-sensors xbacklight tlp bspwm sxhkd st-terminfo hsetroot base-devel openntpd simple-mtpfs xsetroot xprop xdg-utils ffmpeg libva-utils libva-vdpau-driver vdpauinfo`<br />

build st & dmenu: `pkg-config gcc libXft-devel libXinerama-devel`<br />

fonts: `font-kakwafont font-Siji`<br />

lemonbar: `lemonbar-xft`<br />

optional: `font-ibm-plex-otf tmux mpv youtube-dl sxiv scrot unzip axel nnn ncurses neovim`<br />

#### Mount drives
I don't use gvfs or udiskie to mount my drives instead i use a simple script that uses fstab (`~/.local/bin/scripts/dmenumount` it's actually the same script that Luke Smith showcase in one of his videos) it only require dmenu, same script is used to mount android-mtp but it require `simple-mtpfs` to be installed on your machine to work.

#### Watch videos
I have a really slow internet so i have set youtube-dl to always pick 480p or lower if you want to change that edit the config file in `~/.config/mpv/mpv.conf`
