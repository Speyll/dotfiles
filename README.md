## introduction
this is my simple dotfiles for a simple setup of bspwm in Void Linux (and Alpine), the goal of this setup is to be as minimal as possible on resources without completely dropping the eye candy<br />

## preview images
![busy](https://raw.githubusercontent.com/Speyll/void-bspwm/master/screenshots/busy.png)<br />
this is tmux with vim, sxiv is the image viewer and nnn is the file manager/browser<br />
![surf](https://raw.githubusercontent.com/Speyll/void-bspwm/master/screenshots/customsurf.png)<br />
custom surf (added homepage patch) in tabbed and a poorlymade startpage both tabbed and surf can be downloaded here ![mysuckless](https://github.com/Speyll/mysuckless)<br />
![mpv and dmenubar](https://raw.githubusercontent.com/Speyll/void-bspwm/master/screenshots/dmenubar_and_vidya.png) <br />
I have a lemonbar setup (can be toggled with sxhkd) but I rarely use it, prefer the barless way instead i use dmenu as a bar, it's amazing how much you can do with it, for my video player it's a pretty basic mpv with some youtube-dl<br />

## other specifications:

| software  | what i use |
| ------------- | ------------- |
| distro  | void linux and alpine linux |
| wm  | bspwm (sometimes switch to 2bwm) |
| shell  | bash or ash |
| terminal  | st |
| brower  | surf + tabbed (or firefox-esr) |
| image viewer  | sxiv |
| file manager  | nnn |
| text editor  | neovim |
| video player  | mpv + youtube-dl |
| multiplexer  | tmux |
| compositor  | compton |
| downloader | axel |

## some tips for my setup:
this is all the "core" and recommended software you will need for my setup:<br />
the base:`bspwm sxhkd nnn neovim (or vim) xorg-minimal xf86-input-synpatics xf86-input-evdev alsa-utils xbacklight unzip openntpd hsetroot font-hack-ttf xrdb simple-mtpfs ntfs-3g wireless_tools xdg-utils xprop tlp`<br />
for my st/dmenu build: `base-devel libXft-devel libXinerama-devel terminus-font font-Siji`<br />
for my lemonbar setup:`xtitle xclip`<br />
optinal stuff to your likings: `tmux xwinwrap mpv youtube-dl sxiv scrot`<br />

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
