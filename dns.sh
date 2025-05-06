#!/usr/bin/env bash
# Автоматизация настройки DNS-сервера на Astra Linux First-SRV
# Запускайте от root или через sudo

set -euo pipefail

# Параметры
ASTRA_MIRROR="https://download.astralinux.ru/astra/stable/1.8_x86-64"
DOMAIN="it-sirius.any"
REVERSE_NET="100.168.192"
ZONE_DIR="/etc/bind/zones"
SOA_SERIAL=$(date +%Y%m%d%H)
FORWARDERS=("8.8.8.8" "1.1.1.1")

# 1) Установка network-manager
echo "[1/12] Установка network-manager"
apt update
apt install -y network-manager

# 2) Настройка репозиториев Astra
echo "[2/12] Настройка /etc/apt/sources.list"
cat > /etc/apt/sources.list << EOF
# Astra Linux 1.8 x86-64
#deb cdrom:[OS Astra Linux 1.8.1.6 1.8_x86-64 DVD ]/ 1.8_x86-64 contrib main non-free non-free-firmware

deb ${ASTRA_MIRROR}/repository-main/ 1.8_x86-64 main contrib non-free non-free-firmware
#deb ${ASTRA_MIRROR}/repository-devel/ 1.8_x86-64 main contrib non-free non-free-firmware

deb ${ASTRA_MIRROR}/repository-extended/ 1.8_x86-64 main contrib non-free non-free-firmware
EOF

# 3) apt update & install bind9
echo "[3/12] apt update и установка bind9"
apt update
apt install -y bind9 bind9utils

# 4) Создание директории для зон
echo "[4/12] Создание директории зон: ${ZONE_DIR}"
mkdir -p "${ZONE_DIR}"

# 5) Настройка named.conf.options
echo "[5/12] Конфигурируем /etc/bind/named.conf.options"
cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";

    // пересылка всех незнакомых запросов
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };

    // разрешаем запросы из наших сетей
    allow-query { any; };
    recursion yes;

    dnssec-validation no;
    auth-nxdomain no;    # conform to RFC1035
};
EOF

# 6) Настройка named.conf.local
echo "[6/12] Конфигурируем /etc/bind/named.conf.local"
cat > /etc/bind/named.conf.local << EOF
zone "${DOMAIN}" {
    type master;
    file "${ZONE_DIR}/db.${DOMAIN}";
    allow-update { none; };
};

zone "${REVERSE_NET}.in-addr.arpa" {
    type master;
    file "${ZONE_DIR}/db.${REVERSE_NET}";
    allow-update { none; };
};
EOF

# 7) Прямая зона
echo "[7/12] Создаем прямую зону ${ZONE_DIR}/db.${DOMAIN}"
cat > "${ZONE_DIR}/db.${DOMAIN}" << EOF
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        ${SOA_SERIAL} ; serial
        3600       ; refresh
        1800       ; retry
        604800     ; expire
        86400 )    ; minimum

    IN  NS  ns1.${DOMAIN}.

; NS-сервер
ns1         IN  A   192.168.100.132

; Реальные устройства
first-srv   IN  A   192.168.100.132
second-srv  IN  A   192.168.150.133

; Условные
first-rtr   IN  A   192.168.220.1
second-rtr  IN  A   192.168.220.2
first-cli   IN  A   192.168.220.10

; CNAME
moodle      IN  CNAME   first-rtr.${DOMAIN}.
wiki        IN  CNAME   first-rtr.${DOMAIN}.

; ==== SRV для Samba AD DC на second-srv ====
_ldap._tcp.${DOMAIN}.    3600 IN SRV 0 100 389   second-srv.${DOMAIN}.
_kerberos._udp.${DOMAIN}.3600 IN SRV 0 100 88    second-srv.${DOMAIN}.
_gc._tcp.${DOMAIN}.      3600 IN SRV 0 100 3268  second-srv.${DOMAIN}.
EOF

# 8) Обратная зона
echo "[8/12] Создаем обратную зону ${ZONE_DIR}/db.${REVERSE_NET}"
cat > "${ZONE_DIR}/db.${REVERSE_NET}" << EOF
\$TTL 86400
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        ${SOA_SERIAL} ; serial
        3600
        1800
        604800
        86400 )

    IN  NS  ns1.${DOMAIN}.

; PTR-записи
1     IN PTR  first-rtr.${DOMAIN}.
2     IN PTR  second-rtr.${DOMAIN}.
10    IN PTR  first-cli.${DOMAIN}.
132   IN PTR  first-srv.${DOMAIN}.
133   IN PTR  second-srv.${DOMAIN}.
EOF

# 9) Проверка конфигурации и зон
echo "[9/12] Проверка конфигурации named"
named-checkconf

echo "[10/12] Проверка прямой зоны"
named-checkzone ${DOMAIN} "${ZONE_DIR}/db.${DOMAIN}"

echo "[11/12] Проверка обратной зоны"
named-checkzone ${REVERSE_NET}.in-addr.arpa "${ZONE_DIR}/db.${REVERSE_NET}"

# 10) Перезапуск сервиса
echo "[12/12] Перезапуск bind9"
systemctl restart bind9

echo "Настройка DNS-сервера завершена успешно."
