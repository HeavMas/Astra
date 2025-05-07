#!/bin/bash
# Скрипт для Moodle на First-SRV продолжение истории
commands2=(
"# ------first-srv-------"
"# ----moodle----"
"apt install apache2 php libapache2-mod-php php-mysql php-xml php-curl php-zip php-gd php-intl php-mbstring php-pspell php-soap -y"
"systemctl enable --now apache2"
"systemctl status apache2"
"apt install mariadb-server mariadb-client -y"
"systemctl enable --now mariadb"
"systemctl status mariadb"
"mysql -u root << 'SQL'
CREATE DATABASE moodledb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodle'@'localhost' IDENTIFIED BY 'P@ssw0rd';
GRANT ALL PRIVILEGES ON moodledb.* TO 'moodle'@'localhost';
FLUSH PRIVILEGES;
EXIT;
SQL"
"wget https://download.moodle.org/download.php/direct/stable500/moodle-latest-500.tgz"
"tar xzf moodle-latest-500.tgz"
"mv moodle /var/www/html/moodle"
"mkdir /var/moodledata"
"chown -R www-data:www-data /var/www/html/moodle /var/moodledata"
"chmod -R 755 /var/www/html/moodle"
"nano /etc/apache2/sites-available/moodle.conf"
"a2ensite moodle.conf"
"a2enmod rewrite"
"systemctl reload apache2"
"# AstraMode off in apache2.conf"
"systemctl reload apache2"
"chown -R www-data:www-data /var/moodledata"
"chmod 770 /var/moodledata"
"nano /etc/php/8.2/apache2/php.ini"
"# max_input_vars = 5000"
"systemctl restart apache2"
)
for cmd in "${commands2[@]}"; do
  history -s "$cmd"
  echo "$cmd" >> ~/.bash_history
done
history -w
