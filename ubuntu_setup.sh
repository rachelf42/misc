#!/bin/bash

echo 'If QEMU Agent / VBox Guest Additions are needed this script will not do it for you.'
echo 'Current (feb2025) Proxmox templates include QGA already'
echo 'Otherwise remember to do that after reboot (or ^C and do it now)'
sleep 5

apt-get update

if id "rachel" >/dev/null 2>&1; then
    echo 'user found'
else
    echo 'user not found'
    apt-get install -y sudo
    adduser rachel
    usermod -aG sudo rachel
    mkdir /home/rachel/.ssh
    chown rachel:rachel /home/rachel/.ssh
    chmod 700 /home/rachel/.ssh
    wget -O /home/rachel/.ssh/authorized_keys https://github.com/rachelf42.keys
fi

rm /root/.ssh/authorized_keys
cat /home/rachel/.ssh/authorized_keys > /root/.ssh/authorized_keys

chmod -x /etc/update-motd.d/10-help-text
chmod -x /etc/update-motd.d/50-motd-news
echo "AcceptEnv PSSH_NODENUM PSSH_NUMNODES PSSH_HOST" > /etc/ssh/sshd_config.d/99-rachelf42.conf

cat <<'EOD' >> /home/rachel/.bashrc
force_color_prompt=yes
export PS1='[$?] \[\e[32m\]\u\[\e[m\]\[\e[32m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\]:\[\e[35m\]\w\[\e[m\] \\$> '
EOD
NANORC=<<EOD
set tabsize 4
set tabstospaces
set autoindent
EOD
echo "$NANORC" >> /home/rachel/.bashrc

cat <<'EOD' >> /root/.bashrc
force_color_prompt=yes
export PS1='[$?] \[\e[31m\]\u\[\e[m\]\[\e[31m\]@\[\e[m\]\[\e[31m\]\h\[\e[m\]:\[\e[35m\]\w\[\e[m\] \\$> '
EOD
echo "$NANORC" >> /root/.nanorc

echo 'force_color_prompt=yes' >> /etc/skel/.bashrc
cat <<'EOD' >> /etc/skel/.bashrc
force_color_prompt=yes
export PS1='[$?] \[\e[33\]\u\[\e[m\]\[\e[33\]@\[\e[m\]\[\e[33\]\h\[\e[m\]:\[\e[35m\]\w\[\e[m\] \\$> '
EOD
echo "$NANORC" >> /etc/skel/.nanorc

if dpkg -l gedit >/dev/null 2>&1; then
    echo "assuming desktop mode"
else
    echo "assuming server mode"
    apt -y install trash-cli && echo "alias rm='echo \"use trash, dummy\"; tput bel; false'" >> /home/rachel/.bashrc
fi
printf 'America\nVancouver\n' | dpkg-reconfigure -f teletype tzdata > /dev/null 2>&1

#purge is dangerous, let user abort
#terraform can just pipe yes
apt purge snapd && apt-mark hold snapd && tee /etc/apt/preferences.d/00-fuck-snapd <<EOD
Package: snapd
Pin: release *
Pin-Priority: -1
EOD

echo 'Doing upgrades'
sleep 10
apt-get -y upgrade

echo 'Finished! Rebooting...'
shutdown --reboot +5
