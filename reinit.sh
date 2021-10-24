#!/bin/env bash

set -eo pipefail

# VARS
HOSTNAME=$(hostname)
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
SKYPIE_IP="$PREFIX.2.4"

###
# EniesLobby
###
if [[ $HOSTNAME = "EniesLobby" ]]; then
        apt update
        apt install -y bind9

	echo '
zone "franky.ti6.com" {
	type master;
  	also-notify { ' $WATER7_IP '; };
  	allow-transfer { ' $WATER7_IP '; };
	file "/etc/bind/kaizoku/franky.ti6.com";
};

zone "' $PTR_RECORD '" {
	type master;
	file "/etc/bind/kaizoku/' $PTR_RECORD '";
};
' >/etc/bind/named.conf.local

	mkdir -p /etc/bind/jarkom
	echo "\
\$TTL    604800
@       IN      SOA     franky.ti6.com. root.franky.ti6.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      franky.ti6.com.
@       IN      A       $SKYPIE_IP
www     IN      CNAME   franky.ti6.com. 
ns1     IN      A       $SKYPIE_IP
super   IN      NS      ns1     
www     IN      NS      super.franky.ti6.com.     
" >/etc/bind/kaizoku/franky.ti6.com

	echo "\
\$TTL    604800
@       IN      SOA     franky.ti6.com. root.franky.ti6.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
$PTR_RECORD.       IN      NS      franky.ti6.com.
4                  IN      PTR     franky.ti6.com. ; byte ke 4 dari $SKYPIE_IP
" >/etc/bind/kaizoku/$PTR_RECORD
# 2                  IN      PTR     franky.ti6.com. ; byte ke 4 dari $ENIESLOBBY_IP

	echo "
options {
        directory \"/var/cache/bind\";

        // forwarders {
        //      $DNS; //ns foosha
        // };

        // dnssec-validation auto;
        allow-query{any;};

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
" >/etc/bind/named.conf.options

	service bind9 restart

###
# Water7
###
elif [[ $HOSTNAME = "Water7" ]]; then
	apt update
	apt install bind9 -y

	echo '
zone "franky.ti6.com" {
 type slave;
 masters { ' $ENNIESLOBBY_IP ' }
 file "/var/lib/bind/franky.ti6.com";
};
' >/etc/bind/named.conf.local

service bind9 restart

###
# Loguetown
###
elif [[ $HOSTNAME = "Loguetown" ]]; then
	apt update
	apt install dnsutils

	echo '
# nameserver 192.168.122.1
nameserver '$ENIESLOBBY_IP' # IP EniesLobby
nameserver '$WATER7_IP' # IP Water7
' >/etc/resolv.conf

###
# Alabasta
###
elif [[ $HOSTNAME = "Alabasta" ]]; then
	apt update
	apt install dnsutils
	# sed -ie 's/^#*/#/g' /etc/resolv.conf
	echo '
# nameserver 192.168.122.1
nameserver '$ENIESLOBBY_IP' # IP EniesLobby
nameserver '$WATER7_IP' # IP Water7
' >/etc/resolv.conf

fi
