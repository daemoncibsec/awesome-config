#!/bin/bash

update_sys() {
	echo -e "\nBeginning system update."
	sudo apt update

	if [[ $? -eq 0 ]]; then
		echo -e "\nBeginning external repositories installation"
		sudo apt install extrepo -y && sudo extrepo enable librewolf
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "\nEnabled 'librewolf' package in the external repositories for installation.\nApplying changes."
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
	echo -e "\nInstalling packages (this may take a while, please wait)..."
	sudo apt install awesome librewolf tilix kitty picom neovim flameshot thunar ranger gcc python3 fzf btop -y
	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

copy_configurations() {
	user=$1
	echo -e "\nConfiguring Awesome WM..."
	mkdir /home/$user/.config/awesome &>/dev/null
	cp -r awesome /home/$user/.config/awesome

	if [[ $? -eq 0 ]]; then
		echo -e "\nConfiguring Kitty Terminal..."
		mkdir /home/$user/.config/kitty &>/dev/null
		cp -r kitty /home/$user/.config/kitty
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring bash prompt..."
		cp bashrc /home/$user/.bashrc
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring window borders..."
		mkdir -p /home/$user/.config/gtk-3.0/ &>/dev/null
		cp gtk.css /home/$user/.config/gtk-3.0/gtk.css
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring NeoVim Text Editor..."
		mkdir /home/$user/.config/nvim &>/dev/null
		cp -r nvim /home/$user/.config/nvim
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring Thunar File Explorer..."
		mkdir /home/$user/.themes/ &>/dev/null
		cp -r themes/* /home/$user/.themes
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring Btop process manager..."
		cp -r btop /home/$user/.config/btop
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "\nEnabling touchpad compatibility for laptops..."
		mkdir -p /etc/X11/xorg.conf.d/ &>/dev/null
		sudo cp 30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "\nAdding Bash aliases..."
		cp bash_aliases /home/$user/.bash_aliases
	else
		return 1
	fi

	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

main() {
	user=$1
	if [[ $1 == "-h" || $1 == none ]]; then
		echo -e "You must specify the user you want to install the desktop configuration to.\n"
		return 0
	fi
	if [[ $EUID -eq 0 ]]; then
		check_user
		# You must create this function
		if [[ $EUID -eq 0 ]]; then
			update_sys
			if [[ $? -eq 0 ]]; then
				install_packages
				if [[ $? -eq 0 ]]; then
					copy_configurations
				else
					echo -e "\nAn error occured while copying configurations. Aborting."
					return 1
				fi
			else
				echo -e "\nCouldn't update system. Aborting installation."
				return 1
			fi
			chown -R $user:$user /home/$user
			echo -e "\nInstallation completed. Make sure to restart so the changes can apply."
		else
			echo -e "\nYou must run this script with root privileges."
			return 1
		fi
	else
		echo -e "The home directory for the user '$user' does not exist."
		return 1
	fi
}

main
