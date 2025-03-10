#!/bin/bash

# Farell Aditya


apt update -y


# Setup package
apt install socat -y
apt install git -y
apt install ufw -y
apt install iptables -y
apt install build-essential automake autoconf libtool libssl-dev -y
apt install libpthread-stubs0-dev -y
apt install automake autoconf m4 perl -y
apt install -y autoconf automake libtool libssl-dev make gcc g++ libc6-dev pkg-config
apt install automake -y
apt install --reinstall libc6-dev

# Setup Firewall
ufw allow ssh  # Untuk SSH (biasanya port 22)
ufw allow 22/tcp   # Pastikan SSH tetap bisa diakses
ufw allow 1099/tcp # Proxy direct port 1099
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw allow 3128/tcp # Squid Proxy (jika digunakan)
ufw allow 8080/tcp # Proxy alternatif
ufw allow 9000/tcp # Untuk service lain
ufw allow 53/udp   # DNS
ufw allow 1194/udp # OpenVPN UDP (jika diperlukan)
ufw allow 1080/tcp # SOCKS Proxy
ufw allow 777/tcp # Stunnel5
ufw allow 2222/tcp # Stunnel5
ufw allow 444/tcp # Stunnel5
ufw allow 60000:61000/udp  # WireGuard atau FTP passive mode

# Setup Direct Proxy
echo -e "[Unit]
Description=Direct Proxy Server on Port 1099
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:1099,reuseaddr,fork -
Restart=always
User=root

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/direct-proxy.service

# Enable Direct Proxy
systemctl daemon-reload
systemctl enable direct-proxy
systemctl start direct-proxy

# Setup Stunnel5
git clone https://github.com/mtrojnar/stunnel
cd /root/stunnel
chmod +x configure
./configure
make
make install
cd /root
rm -r -f stunnel
rm -f stunnel5.zip

# Setup Directory
mkdir -p /etc/stunnel5 
chmod 644 /etc/stunnel5

# Setup Comfig Stunnel
echo -e "cert = /etc/sslku/ssl.crt
key = /etc/sslku/ssl.key

client = no

socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[sslopenssh]
accept = 2222
connect = 127.0.0.1:22

[ssldirect]
accept = 444
connect = 127.0.0.1:1099

[ssldropbear]
accept = 777
connect = 127.0.0.1:109" > /etc/stunnel5/stunnel5.conf

# Enable STUNNEL5
systemctl daemon-reload
systemctl start stunnel5
systemctl enable stunnel5
systemctl restart stunnel5

clear

# Delete File
rm -f $0
