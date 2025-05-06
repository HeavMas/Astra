#!/bin/bash

if ! samba-tool group list | grep -q '^first$'; then
  echo "Создание группы first в домене..."
  samba-tool group add first
fi

for i in {1..3}; do
  username="user-$i"

  if ! samba-tool user list | grep -q "^$username$"; then
    echo "Создание пользователя $username в домене..."
    samba-tool user add "$username" "P@ssw0rd" --given-name="User-$i" --surname="First"
  fi
 
  if ! samba-tool group listmembers first | grep -q "^$username$"; then
    echo "Добавление пользователя $username в группу first..."
    samba-tool group addmembers first "$username"
  fi
done

echo "Настройка sudo прав для группы first..."
if [ ! -f /etc/sudoers.d/first_group ]; then
  cat << 'EOF' > /etc/sudoers.d/first_group
%first ALL=(root) /bin/cat, /bin/grep, /usr/bin/id
EOF
  chmod 440 /etc/sudoers.d/first_group
fi

