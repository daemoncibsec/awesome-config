#!/bin/bash

# Ensure you have sudo permissions before starting the script. Otherwise, of course, will not work.

sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update
sudo apt install awesome librewolf tilix kitty picom neovim flameshot nautilus -y
cp -R awesome ~/.config/awesome
cp -R kitty ~/.config/kitty
cp bashrc ~/.bashrc
cp gtk.css ~/.config/gtk-3.0/gtk.css
cp -R nvim ~/.config/nvim
sudo cp 30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
