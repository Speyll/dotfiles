## Introduction
A simple help for my bspwm / Void linux setup (some tips and configuration) to know better about my config and why i did this and that. <br />
the goal of my configuration is to be as minimal as possible but still be usable and pretty. <br />
I'm using `Void linux` base install (no DE), with `bspwm, lemonbar (the xft fork), dmenu, st (the Luke Smith fork haha), xcompmgr, lxappearance, mpv and feh` <br />

## Disclaimer
Attention! I'm far from being a pro in Ricing or in Void Linux so I'm sure it can be done a lot better <br/>
_Sorry if my English is bad sometimes, not my native language, but I will try and do my best to be comprehensive_ :grin: <br />

## Preview
![clean](https://raw.githubusercontent.com/Speyll/Minimal-Void-Bspwm/master/screenshots/image1.png) <br />
**Clean**: Without any software open. Only `lemonbar-xft` is visible. <br />

![workflow](https://raw.githubusercontent.com/Speyll/Minimal-Void-Bspwm/master/screenshots/image2.png) <br />
![workflow2](https://raw.githubusercontent.com/Speyll/Minimal-Void-Bspwm/master/screenshots/image3.png) <br />
**My workflow**: `Software open: Surf with tabbed, st, nano, pcmanfm, feh` <br />
I recently moved from Firefox to Surf (I keep Firefox around a little bit) pretty happy with the browser (to watch videos I use YouTube-dl and stream it directly to mpv) and yes, I use pcmanfm I know, I know I could use something like nnn to keep it really minimal but you know it's just for convenience really and everything don't need to be in the terminal haha <br />

![ressources](https://raw.githubusercontent.com/Speyll/Minimal-Void-Bspwm/master/screenshots/image4.png) <br />
**Resources**: Like you see I have only `106M` of ram used at launch  `(usually around 96M without xcompmgr active)` how I achieve that is pretty simple, first not using systemd helps, I'm not saying systemd is bad, it's really just matter of taste I actually prefer runit it has a lower footprint than systemd so for me it's a win win situation, I also don't use the full xorg packages but instead install `xorg-minimal` with `xprop xrdb xsel xset xsetroot xsettingsd xtitle xbacklight do xf86-video-Intel` <br />
Then i delete `TTY3, TTY4, TTY5, TTY6` and `SSHD` services in `/var/service/` (don't worry they are just symlinks so they can be restored) <br />
and it's basiclly done !


## Themes and fonts:

**GTK Theme**:  `Victory` https://github.com/newhoa/victory-gtk-theme <br />
**Icon Theme**: `Arc icons` https://github.com/horst3180/arc-icon-theme <br />

**Fonts**: `Terminus, Font Awesome` <br />
