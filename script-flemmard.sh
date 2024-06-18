#!/bin/bash

# Check if the terminal supports colour and set up variables if it does.
NumColours=$(tput colors)

if test -n "$NumColours" && test $NumColours -ge 8; then

    clear="$(tput sgr0)"
    blackN="$(tput setaf 0)";		blackN="$(tput bold setaf 0)"
    redN="$(tput setaf 1)";		redB="$(tput bold setaf 1)"
    greenN="$(tput setaf 2)";		greenB="$(tput bold setaf 2)"
    yellowN="$(tput setaf 3)";		yellowB="$(tput bold setaf 3)"
    blueN="$(tput setaf 4)";		blueB="$(tput bold setaf 4)"
    magentaN="$(tput setaf 5)";		magentaB="$(tput bold setaf 5)"
    cyanN="$(tput setaf 6)";		cyanB="$(tput bold setaf 6)"
    whiteN="$(tput setaf 7)";		whiteB="$(tput bold setaf 7)"

fi

# Function to echo text using terminal colour codes ###########################
function colEcho() {
    echo -e "$1$2$clear"
}


# Function to wait for a user keypress.
UserWait () {
    read -n 1 -s -r -p "Press any key to continue" < /dev/tty
    echo -e "\r                         \r"
}

# Function to check we are not running with the elevated privileges. ##########
function CheckNotElevated {

    if (( "$EUID" == "0" )); then
        colEcho $redB "ERROR: Running with elevated privileges - do not run using sudo\n"
        exit 1
    fi
}


CheckNotElevated


# Set variables to support different distros.
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	pkgmgr="apt"
	install_arg="install"
	update_arg="update"
elif grep -qs "freebsd" /etc/os-release; then
	os="freebsd"
	pkgmgr="pkg"
	install_arg="install"
	update_arg="update"
elif [[ -e /etc/debian_version ]]; then
	os="debian"
	pkgmgr="apt"
	install_arg="install"
	update_arg="update"
elif [[ -e /etc/almalinux-release || -e /etc/rocky-release || -e /etc/centos-release ]]; then
	colEcho $redB "Fuck Red-Hat for putting source code behind paywalls."
	os="centos"
	pkgmgr="yum"
	install_arg="install"
	update_arg="update"
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	pkgmgr="yum"
	install_arg="install"
	update_arg="update"
elif [[ -e /etc/arch-release ]]; then
	os="arch"
	pkgmgr="pacman"
	install_arg="-S --needed --noconfirm"
	update_arg="-Syy"
else
	colEcho "ERROR: Distro not recognised - exiting..."
	exit 1
fi



# sudo $pkgmgr $update_arg
# if ! [ $(which wget 2>/dev/null) ]; then
# 	sudo $pkgmgr $install_arg wget
# fi

# if ! [ $(which curl 2>/dev/null) ]; then
# 	sudo $pkgmgr $install_arg curl
# fi

# if ! [ $(which 7z 2>/dev/null) ]; then
# 	if [[ -e /etc/arch-release ]]; then
# 		sudo $pkgmgr $install_arg p7zip
# 	elif [[ -e /etc/fedora-release  ]]; then
# 		sudo $pkgmgr $install_arg p7zip-full p7zip-plugins
# 	elif [ "$os" == "centos" ]; then
# 		sudo $pkgmgr $install_arg p7zip p7zip-plugins
# 	else
# 		sudo $pkgmgr $install_arg p7zip-full
# 	fi
# fi

# if ! [ $(sudo which mkntfs 2>/dev/null) ]; then 
# 	if [ "$os" == "centos" ]; then
# 		sudo $pkgmgr $install_arg ntfsprogs
# 	else
# 		sudo $pkgmgr $install_arg ntfs-3g
# 	fi
# fi

# if ! [ $(which aria2c 2>/dev/null) ]; then
# 	sudo $pkgmgr $install_arg aria2
# fi

# Identify latest Ventoy release.
venver=$(curl -sL https://api.github.com/repos/ventoy/Ventoy/releases/latest | grep '"tag_name":' | cut -d'"' -f4)

# Download latest verion of Ventoy.
colEcho $cyanB "\nDownloading Ventoy Version:$whiteB ${venver: -6}"
wget -q --show-progress https://github.com/ventoy/Ventoy/releases/download/v${venver: -6}/ventoy-${venver: -6}-linux.tar.gz -O ventoy.tar.gz

colEcho $cyanB "\nExtracting Ventoy..."
tar -xf ventoy.tar.gz

colEcho $cyanB "Removing the extracted Ventory tar.gz file..."
rm -rf ventoy.tar.gz

# Remove the ./ventoy folder if it exists before renaming ventoy folder.
if [ -d ./ventoy ]; then
	colEcho $cyanB "Removing the previous ./ventoy folder..."
	rm -rf ./ventoy/
fi

colEcho $cyanB "Renaming ventoy folder to remove the version number..."
mv ventoy-${venver: -6} ventoy



# Advise user to connect and select the required USB device.
colEcho $yellowB "\nPlease Plug your USB in now if it is not already connected..."
colEcho $yellowB "\nPress any key once it has been detected by your system..."
UserWait

colEcho $yellowB "Please Find the ID of your USB below:"

lsblk --nodeps --output "NAME,SIZE,VENDOR,MODEL,SERIAL" | grep -v loop

colEcho $yellowB "Enter the device for the USB drive NOT INCLUDING /dev/ OR the Number After."
colEcho $yellowB "for example enter sda or sdb"
read letter < /dev/tty

drive=/dev/$letter

checkingconfirm=""

while [[ "$checkingconfirm" != [NnYy]* ]]; do
	read -e -p "You want to install Ventoy to $drive ? (Y/N) " checkingconfirm < /dev/tty
	if [[ "$checkingconfirm" == [Nn]* ]]; then
		colEcho $yellowB "Installation Cancelled."
		exit
	elif [[ "$checkingconfirm" == [Yy]* ]]; then
		colEcho $cyanB "Installation confirmed and will commence in 5 seconds..."
		sleep 5
	else
		colEcho $redB "Invalid input. Please enter 'Y' or 'N'."
	fi
done


colEcho $cyanB "Installing Ventoy on$whiteB $drive"
sudo sh ./ventoy/Ventoy2Disk.sh -I $drive -s -g -r $((18*1024))
if [ "$?" != "0" ]; then
	colEcho $redB "ERROR: Unable to install Ventoy. Exiting..."
	exit 1
fi

## creer 3eme partition sur cle usb
echo "create SPACE"
sleep 5
sudo fdisk $drive <<EOF
n



w
EOF
sleep 5
sudo mkfs.exfat $drive"3" -L "SPACE"

colEcho $cyanB "Unmounting drive$whiteB $drive"
sudo umount $drive

samba_path="//192.168.1.250/install/"

echo "mounting directory"
mkdir -p space_mountdir
mkdir -p samba_mountdir
mkdir -p ventoy_mountdir
sudo mount $drive"3" ./space_mountdir
sudo mount $drive"1" ./ventoy_mountdir
sudo mount -t cifs $samba_path ./samba_mountdir -o guest

## install les  truc sur SPACE
colEcho $cyanB "Mounting SPACE"
echo "setup SPACE"
cd ./space_mountdir
sudo git clone https://github.com/yfabrik/scripts-install-windows
cd ..
colEcho $cyanB "copy image.wim"
sudo rsync -ah --progress ./samba_mountdir/disks/win.wim.d/{bureau,famille}.wim ./space_mountdir/
# sudo cp ./samba_mountdir/disks/win.wim.d/{bureau,famille}.wim ./space_mountdir/
#curl FILE://./samba_mountdir/disks/win.wim.d/{bureau,famille}.wim -o ./space_mountdir/ ##need full path ?

#install les truc sur ventoy
colEcho $cyanB "setup ventoy"
colEcho $cyanB "setup injection"
mkdir -p windows/system32

colEcho $cyanB "create injection bureau"
cat > windows/system32/starnet.cmd << EOF
::startnet.cmd
wpeinit
for %%a in (d e f g h i j k l m n o p q r s t u v w x y z) do @vol %%a: 2>nul |find "SPACE" >nul && set drv=%%a:
call %drv%\scripts-install-windows\scripts\auto-install.bat %drv%\bureau.wim
call %drv%\scripts-install-windows\scripts\cp-files.bat
EOF
sudo 7z a ventoy_mountdir/inject_bureau.7z windows/

colEcho $cyanB "create injection famille"
cat > windows/system32/starnet.cmd << EOF
::startnet.cmd
wpeinit
for %%a in (d e f g h i j k l m n o p q r s t u v w x y z) do @vol %%a: 2>nul |find "SPACE" >nul && set drv=%%a:
call %drv%\scripts-install-windows\scripts\auto-install.bat %drv%\famille.wim
copy /y %drv%\scripts-install-windows\files\unattend.xml W:\Windows\System32\Sysprep\unattend.xml
EOF
sudo 7z a ventoy_mountdir/inject_famille.7z windows/

sudo rm -r ./windows/

colEcho $cyanB "create ventoy plugin config"
cat > ventoy.json << EOF
{
    "injection":[
        {
            "image": "/WinPE_famille.iso",
            "archive": "/inject_famille.7z"
        },
        {
            "image": "/WinPE_Bureau.iso",
            "archive": "/inject_bureau.7z"
        }
    ]
}
EOF
sudo mkdir -p ventoy_mountdir/ventoy
sudo mv ventoy.json ventoy_mountdir/ventoy/
colEcho $cyanB "add winpe"
sudo rsync -ah --progress ./samba_mountdir/disks/winPE/WinPE_amd64_massdriver.iso ./ventoy_mountdir/WinPE_famille.iso
#sudo cp ./samba_mountdir/disks/winPE/WinPE_amd64_massdriver.iso ./ventoy_mountdir/WinPE_famille.iso
colEcho $cyanB "clone winpe"
sudo rsync -ah --progress ./ventoy_mountdir/WinPE_famille.iso ./ventoy_mountdir/WinPE_bureau.iso
#sudo cp ./ventoy_mountdir/WinPE_famille.iso ./ventoy_mountdir/WinPE_bureau.iso


# clean
colEcho $cyanB "unmounting directory"
sudo umount ./space_mountdir
sudo umount ./ventoy_mountdir
sudo umount ./samba_mountdir
sudo rm -r {space_,samba_,ventoy_}mountdir

colEcho $cyanB DONE
