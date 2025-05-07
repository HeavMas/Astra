#!/bin/bash

sudo sed -i \
  -e 's/^deb cdrom:/#deb cdrom:/' \
  -e 's/^#deb https:\/\/download.astralinux.ru\/astra\/stable\/1.8_x86-64\/repository-main\//deb https:\/\/download.astralinux.ru\/astra\/stable\/1.8_x86-64\/repository-main\//' \
  -e 's/^deb https:\/\/download.astralinux.ru\/astra\/stable\/1.8_x86-64\/repository-devel\//#deb https:\/\/download.astralinux.ru\/astra\/stable\/1.8_x86-64\/repository-devel\//' \
  -e 's/^#deb https:\/\/download.astralinux.ru\/astra\/stable\/1.8_x86-64\/repository-extended\//deb https:\/\/download.astralinux.ru\/astra\/stable\/1.8_x86-64\/repository-extended\//' \
  /etc/apt/sources.list

apt update

apt install -y dnsutils network-manager bind9 bind9utils openssh-server docker docker-compose

if ! id sshuser &>/dev/null; then
    useradd -m -u 1010 -s /bin/bash sshuser
    echo "sshuser:P@ssw0rd" | chpasswd
    echo "sshuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sshuser
    chmod 440 /etc/sudoers.d/sshuser
fi

echo "Authorized access only" > /etc/issue.net
chmod 644 /etc/issue.net

sed -i 's/^#Port 22/Port 2024/' /etc/ssh/sshd_config
sed -i 's/^#MaxAuthTries 6/MaxAuthTries 2/' /etc/ssh/sshd_config
echo "AllowUsers sshuser" >> /etc/ssh/sshd_config
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

systemctl restart sshd

iptables -A INPUT -p tcp --dport 2024 -j ACCEPT

hostnamectl set-hostname first-srv
