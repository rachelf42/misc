#!/bin/bash

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) echo "Got YES"; return 0  ;;  
            [Nn]*) echo "Got NO" ; return 1 ;;
        esac
    done
}

function vbox_guest_additions {
        apt install gcc make perl bzip2 tar
	umount /mnt
	mount /dev/cdrom /mnt
	bash /mnt/VBoxLinuxAdditions.run
	umount /mnt
}

function do_ssh_keys {
	wget -O /home/rachel/.ssh/authorized_keys https://github.com/rachelf42.keys
 	chown rachel:rachel /home/rachel/.ssh/authorized_keys
 	wget -O /root/.ssh/authorized_keys https://github.com/rachelf42.keys
}

yes_or_no "Do we need to install the non-root user?" && apt install -y sudo && adduser rachel && usermod -aG sudo rachel

chmod -x /etc/update-motd.d/10-help-text
chmod -x /etc/update-motd.d/50-motd-news

echo 'force_color_prompt=yes' >> /home/rachel/.bashrc
echo 'export PS1="\[$(tput bold)\]\[\033[38;5;2m\]\u@\h\[$(tput sgr0)\]:[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;5m\]\w\[$(tput sgr0)\]]\\$\[$(tput sgr0)\] "' >> /home/rachel/.bashrc
echo 'set tabsize 4' >> /home/rachel/.nanorc
echo 'set tabstospaces' >> /home/rachel/.nanorc

echo 'force_color_prompt=yes' >> /root/.bashrc
echo 'export PS1="\[$(tput bold)\]\[\033[38;5;1m\]\u@\h\[$(tput sgr0)\]:[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;5m\]\w\[$(tput sgr0)\]]\\$\[$(tput sgr0)\] "' >> /root/.bashrc
echo 'set tabsize 4' >> /root/.nanorc
echo 'set tabstospaces' >> /root/.nanorc

echo 'force_color_prompt=yes' >> /etc/skel/.bashrc
echo 'export PS1="\[$(tput bold)\]\[\033[38;5;3m\]\u@\h\[$(tput sgr0)\]:[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;5m\]\w\[$(tput sgr0)\]]\\$\[$(tput sgr0)\] "' >> /etc/skel/.bashrc
echo 'set tabsize 4' >> /etc/skel/.nanorc
echo 'set tabstospaces' >> /etc/skel/.nanorc

apt update

yes_or_no "Do we need to set timezone?" && dpkg-reconfigure tzdata

yes_or_no "Do we need to download SSH keys?" && do_ssh_keys

yes_or_no "Do we need VBox Guest Additions? (if yes insert disk before proceeding)" && vbox_guest_additions

yes_or_no "Do we need QEmu Guest Agent?"  && apt install -y qemu-guest-agent

yes_or_no "Are we on the internal home network? If yes, do we want the APT proxy?" && echo 'Acquire::http::Proxy "http://192.168.0.5:3142";' >> /etc/apt/apt.conf.d/00-rachel-proxy

echo 'Doing upgrades'
sleep 3
apt -y upgrade

echo 'Finished! Rebooting...'
poweroff --reboot 3
