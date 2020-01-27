## introduction
this is my simple dotfiles for a simple setup of bspwm in GNU/Linux, the goal of this setup is to be as minimal as possible on resources without completely dropping the eye candy<br />

## preview images
![nord](https://i.imgur.com/e9VaQyL.png)<br />
This is my setup with my customish kinda nord theme.<br />

![black gradient](https://i.imgur.com/NdhGfRI.png)<br />
Same setup but with black gardients.<br />

## software used:
| software  | what i use |
| ------------- | ------------- |
| distros  | Void, Alpine, Debian GNU/Linux |
| wms  | bspwm (sometimes switch to 2bwm) |
| shells  | bash or ash |
| terminal  | st |
| browser  | tabbed + surf, palemoon or firefox-esr |
| image viewer  | sxiv |
| file manager  | nnn |
| text editor  | neovim |
| video player  | mpv + youtube-dl |
| multiplexer  | tmux |
| compositor  | compton |
| downloader | axel, transmission |

## some tips for my setup:
this is all the "core" and recommended software you will need for my setup:<br />

### void linux
the base:`bspwm sxhkd nnn neovim (or vim) xorg-minimal xf86-input-synpatics xf86-input-evdev alsa-utils xbacklight unzip openntpd hsetroot font-hack-ttf xrdb simple-mtpfs ntfs-3g wireless_tools xdg-utils xprop tlp`<br />
for my st/dmenu build: `base-devel libXft-devel libXinerama-devel terminus-font font-Siji`<br />
for my lemonbar setup:`lemonbar-xft (or lemonbar but you will need some tweaking) xtitle xdotool`<br />
optinal stuff to your likings: `tmux xwinwrap mpv youtube-dl sxiv scrot redshift`<br />

if you have an intel igpu install: `xf86-video-intel`<br />
if you have a nvidia gpu you can install: `xf86-video-nouveau`<br />
if you have an amd gpu install: `xf86-video-amdgpu`<br />
if you have bluetooth and want to use it install: `bluez`<br />
if you have a bluetooth headset you will need: `bluez-alsa`<br />
if you have a gamepad or a joystick and want to use it you will need: `xf86-input-joystick`<br />

if you want to compile `surf` from source and have a working youtube layout you will need this `libgtkdgl-devel libgcrypt-devel webkit2gtk-devel gstreamer1-devel gst-plugins-good1 gst-plugins-base1-devel gst-libav curl`<br />

#### activate your internet after installation
*ip link show <br />
sudo ip link set up wlp#s# <br />
sudo ip link set up enp#s# <br />*

*wpa_passphrase 'SSID' 'PASSWORD' >> /etc/wpa_supplicant/wpa_supplicant-wlp#s#.conf <br />
sudo ln -s /etc/sv/wpa_supplicant /var/service/ <br />
sudo ln -s /etc/sv/dhcpcd /var/service/ <br />
sudo wpa_supplicant -B -i wlp#s# -c /etc/wpa_supplicant/wpa_supplicant-wlp#s#.conf <br />*

replace the `#` with the values shown in ip link show!

#### removing unsed services
in `/var/service/`<br />
you can remove things like TTY3, TTY4, TTY5, TTY6, and SSHD (if you don't use them) don't worry they are just symlinks so they can easily be restored<br />

#### mounting drives
I don't use gvfs or udiskie to mount my drives instead i use a simple script that uses fstab (can be found in `~/.local/bin/scripts/dmenumount` it's actually the same script that Luke Smith showcase in one of his videos) it only require dmenu, same script is used to mount android mtp but it require `simple-mtpfs` to be installed on your machine to work<br />

#### watching videos
even if my surf setup support watching videos directly in the browser i don't really do it there, instead i use `mpv + youtube-dl` if you have them both installed and use my config files you can just run from the terminal or dmenu `mpv ~link of the video~` without the ~ and it will run it, because i have a really bad internet connexion i have set youtube-dl to always pick 480p or lower if you want to change that you can edit the config file here `~/.config/mpv/config`

**ps:** my keybindings are all in `~/. config/bspwm/sxhkdrc` they are all commented so if you want to know which keybind do what or want to change it to your likings it's all there!<br />

### alpine linux
the base:`xorg-server xrdb alsa-utils alsa-lib alsaconf lm-sensors pm-utils xbacklight tlp bspwm sxhkd st ncurses-terminfo ncurses nnn neovim ttf-hack terminus-font  simple-mtpfs unzip openntpd ntfs-3g xdg-utils xprop`<br />
for my st/dmenu build: `git make gcc g++ libx11-dev libxft-dev libxinerama-dev font-siji`<br />
for my lemonbar setup:`lemonbar xtitle xdotool`<br />
optinal stuff to your likings: `tmux mpv sxiv setroot compton lemonbar youtube-dl redshift`<br />

if you have an intel igpu install: `xf86-video-intel`<br />
if you have a nvidia gpu you can install: `xf86-video-nouveau`<br />
if you have an amd gpu install: `xf86-video-amdgpu`<br />
if you have bluetooth and want to use it install: `bluez`<br />
if you have a bluetooth headset you will need: `bluez-alsa`<br />
if you have a gamepad or a joystick and want to use it you will need: `xf86-input-joystick`<br />

## other screenshots:
![1](https://i.imgur.com/XhcBTJp.png)
