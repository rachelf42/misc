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
        apt-get install gcc make perl bzip2 tar
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

function make_user {
	apt-get install -y sudo
 	adduser rachel
  	usermod -aG sudo rachel
   	mkdir /home/rachel/.ssh
    	chown rachel:rachel /home/rachel/.ssh
     	chmod 700 /home/rachel/.ssh
}

apt-get update

yes_or_no "Do we need to install the non-root user?" && make_user

chmod -x /etc/update-motd.d/10-help-text
chmod -x /etc/update-motd.d/50-motd-news

echo 'force_color_prompt=yes' >> /home/rachel/.bashrc
echo 'export PS1="[$?] \[\e[32m\]\u\[\e[m\]\[\e[32m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[35m\]\w\[\e[m\] \\$> "' >> /home/rachel/.bashrc
echo 'set tabsize 4' >> /home/rachel/.nanorc
echo 'set tabstospaces' >> /home/rachel/.nanorc
echo 'set autoindent' >> /home/rachel/.nanorc

echo 'force_color_prompt=yes' >> /root/.bashrc
echo 'export PS1="[$?] \[\e[31m\]\u\[\e[m\]\[\e[31m\]@\[\e[m\]\[\e[31m\]\h\[\e[m\]:\[\e[35m\]\w\[\e[m\] \\$> "' >> /root/.bashrc
echo 'set tabsize 4' >> /root/.nanorc
echo 'set tabstospaces' >> /root/.nanorc
echo 'set autoindent' >> /root/.nanorc

echo 'force_color_prompt=yes' >> /etc/skel/.bashrc
echo 'export PS1="[$?] \[\e[33m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[33m\]\h\[\e[m\]:\[\e[35m\]\w\[\e[m\] \\$> "' >> /etc/skel/.bashrc
echo 'set tabsize 4' >> /etc/skel/.nanorc
echo 'set tabstospaces' >> /etc/skel/.nanorc
echo 'set autoindent' >> /etc/skel/.nanorc

yes_or_no "Do we need to set timezone?" && dpkg-reconfigure tzdata

yes_or_no "Do we need to download SSH keys?" && do_ssh_keys

yes_or_no "Do we need VBox Guest Additions? (if yes insert disk before proceeding)" && vbox_guest_additions

yes_or_no "Do we need QEmu Guest Agent?"  && apt install -y qemu-guest-agent

yes_or_no "Fuck snapd?" && apt-mark hold snapd && tee /etc/apt/preferences.d/00-fuck-snapd <<EOD
Package: snapd
Pin: release *
Pin-Priority: -1
EOD

echo 'Doing upgrades'
sleep 10
apt-get -y upgrade

echo 'Finished! Rebooting...'
poweroff --reboot 3
