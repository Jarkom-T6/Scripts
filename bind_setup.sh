#!/bin/env bash

set -eo pipefail

# VARS
HOSTNAME=`hostname`
GRP="TI6"
PREFIX="192.214"
DNS="192.168.122.1"
FOOSHA_e1_IP="$PREFIX.1.1"
FOOSHA_e2_IP="$PREFIX.2.1"
LOGUETOWN_IP="$PREFIX.1.2"
ALABASTA_IP="$PREFIX.1.3"
ENIESLOBBY_IP="$PREFIX.2.2"
ENIESLOBBY_IP_REV="$(echo $ENIESLOBBY_IP | sed -r 's/([^\.]*)\.([^\.]*)\.([^\.]*)\.([^\.]*)/\3\.\2\.\1/')"
PTR_RECORD="$ENIESLOBBY_IP_REV.in-addr.arpa"
WATER7_IP="$PREFIX.2.3"

if [[ $HOSTNAME = "EniesLobby" ]]; then
# Install bind
apt update
apt install bind9 -y

echo '
zone "jarkom2021.com" {
	type master;
	file "/etc/bind/jarkom/jarkom2021.com";
};

zone "'$PTR_RECORD'" {
	type master;
	file "/etc/bind/jarkom/'$PTR_RECORD'";
};
' > /etc/bind/named.conf.local

mkdir -p /etc/bind/jarkom
echo "\
\$TTL    604800
@       IN      SOA     jarkom2021.com. root.jarkom2021.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      jarkom2021.com.
@       IN      A       127.0.0.1
" > /etc/bind/jarkom/jarkom2021.com

echo "\
\$TTL    604800
@       IN      SOA     jarkom2021.com. root.jarkom2021.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
$PTR_RECORD       IN      NS      jarkom2021.com.
2                 IN      PTR     jarkom2021.com. ; byte ke 4 dari $ENIESLOBBY_IP
" > /etc/bind/jarkom/$PTR_RECORD

service bind9 restart

elif [[ $HOSTNAME = "Loguetown" ]]; then
apt update
apt install dnsutils
sed -ie 's/^#*/#/g' /etc/resolv.conf
echo "nameserver $ENIESLOBBY_IP # IP EniesLobby" >> /etc/resolv.conf

elif [[ $HOSTNAME = "Alabasta" ]]; then
sed -ie 's/^#*/#/g' /etc/resolv.conf
echo "nameserver $ENIESLOBBY_IP # IP EniesLobby" >> /etc/resolv.conf

fi

