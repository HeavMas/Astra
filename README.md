## 📘 Astra Linux Server Setup & Administration

### 🔧 Сетевые настройки

**Показать интерфейсы:**

```bash
nmcli device show
```

**Назначить статический IP-адрес:**

```bash
sudo nmcli connection modify enp1s0 \
  ipv4.addresses 192.168.10.110/24 \
  ipv4.gateway 192.168.10.1 \
  ipv4.dns "192.168.10.110,77.88.8.8" \
  ipv4.method manual \
  ipv6.method disabled
```

**Проверить/редактировать через TUI:**

```bash
nmtui
```

**Перезапустить сеть:**

```bash
sudo systemctl restart NetworkManager
```

---

### 👥 Основные системные команды

**Установить hostname:**

```bash
sudo hostnamectl set-hostname <имя_хоста>
```

**Посмотреть hostname:**

```bash
hostnamectl
```

**Добавить запись в /etc/hosts:**

```bash
sudo nano /etc/hosts
```

---

### 📂 Права и доступы

**Установить права на директорию:**

```bash
sudo chmod -R 755 /path/to/dir
```

**Сделать владельцем пользователя:**

```bash
sudo chown -R username:groupname /path/to/dir
```

**Проверить права:**

```bash
ls -l
```

---

### 👤 Пользователи и группы

**Создать пользователя:**

```bash
sudo adduser username
```

**Создать группу:**

```bash
sudo groupadd groupname
```

**Добавить пользователя в группу:**

```bash
sudo usermod -aG groupname username
```

**Ограниченные sudo-привилегии:**

```bash
sudo visudo
```

Добавить, например:

```text
username ALL=(ALL) /usr/bin/apt, /bin/systemctl
```

---

### 📜 Bash-скрипты

**Создание и запуск:**

```bash
nano script.sh
chmod +x script.sh
./script.sh
```

**Через интерпретатор:**

```bash
bash script.sh
```

---

### 🧹 Очистка истории (bash)

**Очистить текущую сессию:**

```bash
history -c
```

**Удалить файл истории:**

```bash
rm ~/.bash_history
```

**Обнулить в памяти:**

```bash
unset HISTFILE
```

---

### 🔍 Диагностика

**Проверить порты:**

```bash
ss -tulnp
```

**Ping и DNS:**

```bash
ping 8.8.8.8
dig ya.ru
```

**Проверка соединения с хостом:**

```bash
nc -zv 192.168.10.1 22
```

---

### 🧪 Специфические команды из задания

**Настройка DNS-сервера (bind):**

```bash
sudo systemctl enable --now named
sudo systemctl status named
```

**Проверка зоны:**

```bash
named-checkzone ds-hub.ru /etc/bind/db.ds-hub.ru
```

**Проверка резолва:**

```bash
dig @localhost example.ds-hub.ru
```

**Проверка регистрации Windows-клиента в домене (Samba AD):**

```bash
samba-tool domain level show
```

**Проверка SID и групп:**

```bash
wbinfo -u
wbinfo -g
```

---

### 🧰 Проверка NAT и связи с другими машинами

**Проверить маршрут:**

```bash
ip route
```

**Посмотреть iptables (esli ispol'zuyetsya):**

```bash
sudo iptables -t nat -L -n -v
```
