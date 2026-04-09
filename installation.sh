#!/bin/bash

user=$1

spin() {
	local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧')
	local mensaje="${1:-Procesando...}"
	shift

	"$@" &>/dev/null &
	local pid=$!

	while kill -0 $pid 2>/dev/null; do
		for f in "${spinner[@]}"; do
			printf "\r $f $mensaje"
			sleep 0.1
		done
	done

	wait $pid
	if [ $? -eq 0 ]; then
		printf "\r ✓ $mensaje\n"
	else
		printf "\r ✗ Error: $mensaje"
	fi
}

# Example:
# spin "Actualizando repositorios..." sudo apt update

check_user () {
	if [[ -d "/home/$user" ]]; then
		return 0
	else
		echo -e "\nThe home directory for the user '$user' does not exist.\n"
		return 1
	fi
}

update_sys() {
	spin "Beginning system update" sudo apt update

	if [[ $? -eq 0 ]]; then
		spin "Beginning external repositories installation - May take around 20 minutes" sudo apt install extrepo -y && sudo extrepo enable librewolf
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo "   Enabled 'librewolf' package in the external repositories for installation"
		spin "Applying changes" sudo apt update
	else
		return 1
	fi

	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

install_packages() {
	spin "Installing packages - Will definitely take some time, around 1 hour" sudo apt install awesome librewolf tilix kitty picom neovim flameshot thunar ranger gcc python3 fzf btop picom -y
	if [[ $? -ne 0 ]]; then		
		return 1
	fi

	return 0
}

copy_configurations() {
	echo -e "\nConfiguring Awesome WM..."
	mkdir -p /home/$user/.config/awesome &>/dev/null
	cp -r awesome/* /home/$user/.config/awesome

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring Kitty Terminal..."
		mkdir -p /home/$user/.config/kitty &>/dev/null
		cp -r kitty/* /home/$user/.config/kitty
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
		mkdir -p /home/$user/.config/nvim &>/dev/null
		cp -r nvim/* /home/$user/.config/nvim
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring Thunar File Explorer..."
		mkdir -p /home/$user/.themes/ &>/dev/null
		cp -r themes/* /home/$user/.themes
	else
		return 1
	fi

	if [[ $? -eq 0 ]]; then
		echo -e "Configuring Btop process manager..."
		cp -r btop/* /home/$user/.config/btop
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
	if [[ "$user" == "-h" || -z "$1" ]]; then
		echo -e "You must specify the user you want to install the desktop configuration to.\n"
		return 0
	else
		echo -e "\nProceeding with the installation of the configuration for the user '$user'."
		if [[ $EUID -eq 0 ]]; then
			check_user
			if [[ $? -eq 0 ]]; then
				update_sys
				if [[ $? -eq 0 ]]; then
					install_packages
					if [[ $? -eq 0 ]]; then
						copy_configurations
						if [[ $? -eq 0 ]]; then
							chown -R $user:$user /home/$user
							echo -e "\nInstallation completed. Make sure to restart so the changes can apply."
						else
							echo -e "\nAn error occured while copying configurations. Aborting."
						fi
					else
						echo -e "\nPackages installation error. Aborting."
						return 1
					fi
				else
					echo -e "\nCouldn't update system. Aborting installation.\n"
					return 1
				fi
			else
				return 1
			fi
		else
			echo -e "\nYou must run this script with root privileges.\n"
			return 1
		fi
	fi
	return 0
}

main "$@"
