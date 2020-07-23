# ramnes/dotfiles

These dotfiles do a lot of things, eh.

They configure:
* `git`
* `ssh`
* `qtile`
* `roxterm`
* `bash`
* `emacs`
* `tmux`
* `htop`
* `rofi`

They use:
* `pip`
* `go`
* `virtualenv`
* `feh`
* `setxkbmap`
* `xrandr`
* `autorandr`
* `compton`
* `nm-applet`
* `redshift`
* `gnome-screenshot`
* `i3lock`

They bundle:
* `context-color`, that gives a different color for each output of a command
* `kt` and `kctx`, for an easier administration of Kubernetes clusters
  (requires `kubectl`)
* `mouserate`, that gives you your current mouse polling rate (requires `xev`)
* `splatmoji`, to pick up fancy emojis (requires `rofi`, `xdotool` and `xsel`)
* `spotify-dbus`, to control Spotify from the command line (requires `dbus`)
* `tm`, to write on multiple servers shells at once (requires `tmux`)

I will probably be too lazy to keep these lists up to date, so you should
rather refer to the different files in tree, I tried to make it pretty
explicit. `contrib/` contains all the bundled tools, `bin/` has the installer
and stuff, and everything else is a configuration.


## Install

```sh
$ git clone --recurse-submodules git@github.com:ramnes/dotfiles.git .dotfiles
$ ./.dotfiles/bin/bootstrap.sh
```

This will create a lot of symbolic links in `/home/${USER}/`, and gently ask
for authorization if it needs to overwrite anything.


## More

Hereafter is a list of things you might want (or not) to add as root along with
the installation of the dotfiles.

In `/etc/environment`:

```sh
GTK_IM_MODULE=cedilla
QT_IM_MODULE=cedilla
```

In `/etc/X11/xorg.conf.d/10keyboard.conf`:

```sh
Section "InputClass"
    Identifier "keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
    Option "XkbVariant" "intl"
    Option "XkbOptions" "compose:lwin,ctrl:swap_lwin_lctl,caps:ctrl_modifier,shift:both_capslock_cancel"
EndSection
```

In `/etc/X11/xorg.conf.d/40monitor.conf`:

```sh
Section "Monitor"
    Identifier "eDP1"
    Modeline "1920x1080"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
    Option "PreferredMode" "1920x1080"
EndSection
Section "Monitor"
    Identifier "DP1"
    Option "LeftOf" "eDP1"
EndSection
```

In `/etc/X11/xorg.conf.d/50touchpad.conf`:

```sh
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Option "NaturalScrolling" "on"
EndSection
```

In `/etc/inittab` (yep, I'm still not using systemd), replace tty1 with:

```
c1:12345:respawn:/sbin/agetty --autologin <username> --noclear 38400 tty1 linux
```
