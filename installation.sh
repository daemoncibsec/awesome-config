#!/bin/bash

# Ensure you have sudo permissions before starting the script. Otherwise, of course, will not work.

sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf
sudo apt update
sudo apt install awesome librewolf tilix kitty picom neovim flameshot thunar -y
cp -r awesome ~/.config/awesome
cp -r kitty ~/.config/kitty
cp bashrc ~/.bashrc
mkdir ~/.config/gtk-3.0
cp gtk.css ~/.config/gtk-3.0/gtk.css
cp -r nvim ~/.config/nvim
mkdir ~/.themes/
cp -r themes/* ~/.themes
sudo cp 30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
