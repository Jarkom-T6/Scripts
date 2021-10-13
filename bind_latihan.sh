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

###
# EniesLobby
###
if [[ $HOSTNAME = "EniesLobby" ]]; then
# Install bind
apt update
apt install bind9 -y

echo '
zone "jarkom.com" {
	type master;
  // notify yes; // buat setting dns slave
  // also-notify { '$WATER7_IP'; }; // buat setting dns slave
  allow-transfer { '$WATER7_IP'; };
	file "/etc/bind/jarkom/jarkom.com";
};

zone "'$PTR_RECORD'" {
	type master;
	file "/etc/bind/jarkom/'$PTR_RECORD'";
};
' > /etc/bind/named.conf.local

mkdir -p /etc/bind/jarkom
echo "\
\$TTL    604800
@       IN      SOA     jarkom.com. root.jarkom.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      jarkom.com.
@       IN      A       127.0.0.1
WWW     IN      CNAME   jarkom.com. 
luffy   IN      A       $WATER7_IP
seru   IN      A       $WATER7_IP
ns1     IN      A       $WATER7_IP
its     IN      NS      ns1     
" > /etc/bind/jarkom/jarkom.com

echo "\
\$TTL    604800
@       IN      SOA     jarkom.com. root.jarkom.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
$PTR_RECORD.       IN      NS      jarkom.com.
2                  IN      PTR     jarkom.com. ; byte ke 4 dari $ENIESLOBBY_IP
" > /etc/bind/jarkom/$PTR_RECORD

# sed -ie '/dnssec-validation auto;/s|^/*|//|' /etc/bind/named.conf.options
# sed -ie '/allow-query{any;};/s///g' /etc/bind/named.conf.options
# sed -ie '/dnssec-validation auto;/s|$|\n\tallow-query{any;};|' /etc/bind/named.conf.options

echo "
options {
        directory \"/var/cache/bind\";

        // forwarders {
        //       $DNS; //ns foosha
        // };

        // dnssec-validation auto;
        allow-query{any;};

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
" > /etc/bind/named.conf.options

service bind9 restart

###
# Water7
###
elif [[ $HOSTNAME = "Water7" ]]; then
apt update
apt install bind9 -y

echo '
// setup slave
// zone "jarkom.com" {
//	type slave;
//  masters { '$ENIESLOBBY_IP'; };
//	file "/var/lib/bind/jarkom.com";
// };

zone "its.jarkom.com" {
 type master;
 file "/etc/bind/delegasi/its.jarkom.com";
};
' > /etc/bind/named.conf.local

# sed -ie '/dnssec-validation auto;/s|^/*|//|' /etc/bind/named.conf.options
# sed -ie '/dnssec-validation auto;/s|$|\n\tallow-query{any;};|' /etc/bind/named.conf.options
echo "
options {
        directory \"/var/cache/bind\";

        forwarders {
              $DNS; # ns foosha
        };

        // dnssec-validation auto;
        allow-query{any;};

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
" > /etc/bind/named.conf.options

mkdir -p /etc/bind/delegasi
echo "\
\$TTL    604800
@       IN      SOA     its.jarkom.com. root.its.jarkom.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@        IN      NS      its.jarkom.com.
@        IN      A       $WATER7_IP
integra  IN      A       $WATER7_IP
" > /etc/bind/delegasi/its.jarkom.com

service bind9 restart

###
# Loguetown
###
elif [[ $HOSTNAME = "Loguetown" ]]; then
apt update
apt install dnsutils
sed -ie 's/^#*/#/g' /etc/resolv.conf

echo '
# nameserver 192.168.122.1
nameserver '$ENIESLOBBY_IP' # IP EniesLobby
nameserver '$WATER7_IP' # IP Water7
' > /etc/resolv.conf

###
# Alabasta
###
elif [[ $HOSTNAME = "Alabasta" ]]; then
apt update
apt install dnsutils
sed -ie 's/^#*/#/g' /etc/resolv.conf
echo '
# nameserver 192.168.122.1
nameserver '$ENIESLOBBY_IP' # IP EniesLobby
nameserver '$WATER7_IP' # IP Water7
' > /etc/resolv.conf

fi

