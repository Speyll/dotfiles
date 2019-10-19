## introduction
this is my simple dotfiles for a simple setup of bspwm in Void Linux, the goal of this setup is to be as minimal as possible on resources without completely dropping the eye candy<br />

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
| distro  | voidlinux |
| wm  | bspwm (somtimes switch to 2bwm) |
| shell  | bash |
| terminal  | st |
| brower  | surf + tabbed |
| image viewer  | sxiv |
| file manager  | nnn |
| text editor  | vim |
| video player  | mpv + youtube-dl |
| multiplexer  | tmux |
| compositor  | compton |
| downloader | axel |

## some tips for my setup:
this is all the "core" and recommended software you will need for my setup:<br />
`bspwm sxhkd nnn vim xorg-minimal xf86-input-synpatics xf86-input-evdev alsa-utils cherry-font font-Siji mpv xbacklight unzip openntpd sxiv hsetroot font-hack-ttf scrot xrdb simple-mtpfs xtitle xclip tmux base-devel libXft-devel libXinerama-devel xwinwrap youtube-dl ntfs-3g wireless_tools xdg-utils xprop`<br />

if you have an intel igpu install: `xf86-video-intel`<br />
if you have a nvidia gpu you can install: `xf86-video-nouveau`<br />
if you have an amd gpu install: `xf86-video-amdgpu`<br />
if you have bluetooth and want to use it install: `bluez`<br />
if you have a bluetooth headset you will need: `bluez-alsa`<br />
if you have a gamepad or a joyestick and want to use it you will need: `xf86-input-joyestick`<br />

if you want to compile `surf` from source and have a working youtube layout you will need this `libgtkdgl-devel libgcrypt-devel webkit2gtk-devel gstreamer1-devel gst-plugins-good1 gst-plugins-base1-devel gst-libav curl`<br />

## activate your internet after installation
ip link show <br />
sudo ip link set up wlp#s0 <br />
sudo ip link set up enp#s0 <br />

wpa_passphrase 'SSID' 'PASSWORD' >> /etc/wpa_supplicant/wpa_supplicant-wlp#s0.conf <br />
sudo ln -s /etc/sv/wpa_supplicant /var/service/ <br />
sudo ln -s /etc/sv/dhcpcd /var/service/ <br />
sudo wpa_supplicant -B -i wlp#s0 -c /etc/wpa_supplicant/wpa_supplicant-wlp#s0.conf <br />

replace the `#` with the value shown in ip link show!
