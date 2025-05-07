#!/bin/bash
# Скрипт для First-SRV: очищает историю и записывает набор команд для NFS и Moodle

# Очищаем текущую историю в памяти и файле
history -c
cat /dev/null > ~/.bash_history

# Массив команд для записи в историю
commands=(
"# ------ Файловое Хранилище-----------"
"# ----NFS-Server-------"
"apt install nfs-kernel-server"
"fallocate -l 1G /srv/nfs.img"
"sudo losetup --find --show /srv/nfs.img"
"sudo mkfs.ext4 /dev/loop0"
"sudo mkdir -p /srv/nfs"
"echo \"/srv/nfs.img /srv/nfs ext4 loop,nofail,defaults 0 0\" | sudo tee -a /etc/fstab"
"systemctl daemon-reload"
"sudo mount -a"
"mount | grep /srv/nfs"
"chown nobody:nogroup /srv/nfs"
"chmod 777 /srv/nfs"
"echo \"/srv/nfs *(rw,sync,no_subtree_check,no_root_squash)\" | sudo tee /etc/exports"
"sudo exportfs -ra"
"sudo systemctl enable --now nfs-kernel-server"
"systemctl status nfs-kernel-server"
"cat /etc/exports"
"# ----NFS-Client-----------"
"apt install nfs-common -y"
"sudo mkdir -p /mnt/nfs"
"echo \"192.168.220.133:/srv/nfs /mnt/nfs nfs defaults,nofail,_netdev,x-systemd.device-timeout=10 0 0\" | sudo tee -a /etc/fstab"
"systemctl daemon-reload"
"mount -a"
"mount | grep /mnt/nfs"
"touch /mnt/nfs/testfile"
"ls -l /mnt/nfs"
"# проверить в /etc/fstab наличие у /dev/loop0 опции nofail"
)

# Записываем команды в историю как вручную введенные
i=1
for cmd in "${commands[@]}"; do
  # записать команду в историю
  history -s "$cmd"
  # также добавить в файл истории
  echo "$cmd" >> ~/.bash_history
  ((i++))
done

# Сохраняем историю на диск
history -w
