#!/bin/bash

update_sys() {
	echo -E "\nBeginning system update."
	sudo apt update

	if [[ $? -eq 0 ]]; then
		echo -E "\nBeninning external repositories installation"
		sudo apt install extrepo -y && sudo extrepo enable librewolf
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "\nEnabled 'librewolf' package in the external repositories for installation.\nApplying changes."
		sudo apt update
	else
		return 1
	fi

	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

install_packages() {
	echo -E "\nInstalling packages"
	sudo apt install awesome librewolf tilix kitty picom neovim flameshot thunar ranger gcc python3 fzf -y
	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

copy_configurations() {
	echo -E "\nConfiguring Awesome WM..."
	mkdir ~/.config/awesome &>/dev/null
	cp -r awesome ~/.config/awesome

	if [[ $? -eq 0 ]]; then
		echo -E "\nConfiguring Kitty Terminal..."
		mkdir ~/.config/kitty &>/dev/null
		cp -r kitty ~/.config/kitty
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "Configuring bash prompt..."
		cp bashrc ~/.bashrc
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "Configuring window borders..."
		mkdir -p ~/.config/gtk-3.0/ &>/dev/null
		cp gtk.css ~/.config/gtk-3.0/gtk.css
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "Configuring NeoVim Text Editor..."
		mkdir ~/.config/nvim &>/dev/null
		cp -r nvim ~/.config/nvim
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "Configuring Thunar File Explorer..."
		mkdir ~/.themes/ &>/dev/null
		cp -r themes/* ~/.themes
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "Configuring Btop process manager..."
		cp -r btop ~/.config/btop
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "\nEnabling touchpad compatibility for laptops..."
		mkdir -p /etc/X11/xorg.conf.d/ &>/dev/null
		sudo cp 30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -E "\nAdding Bash aliases..."
		cp bash_aliases ~/.bash_aliases
	else
		return 1
	fi

	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

main() {
	if [[ $EUID -eq 0 ]]; then
		update_sys
		if [[ $? -eq 0 ]]; then
			install_packages
			if [[ $? -eq 0 ]]; then
				copy_configurations
			else
				echo -E "\nAn error occured while copying configurations. Aborting."
				return 1
			fi
		else
			echo -E "\nCouldn't update system. Aborting installation."
			return 1
		fi
		chown -R $USER:$USER /home/$USER
		echo -E "\nInstallation completed. Make sure to restart so the changes can apply."
	else
		echo -E "\nYou must run this script with root privileges."
		return 1
	fi
}

main
