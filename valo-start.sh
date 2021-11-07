#!/bin/env bash

# Written by m42nk

set -eo pipefail
# Variables
GRP="TI6"
PREFIX="192.214"
DNS="192.168.122.1"

ENIESLOBBY_IP="$PREFIX.2.2"
WATER7_IP="$PREFIX.2.3"
JIPANGU_IP="$PREFIX.2.4"

LOGUETOWN_IP="$PREFIX.1.2"
ALABASTA_IP="$PREFIX.1.3"

SKYPIE_IP="$PREFIX.3.2"
TOTTOLAND_IP="$PREFIX.3.3"

FOOSHA_e1_IP="$PREFIX.1.1"
FOOSHA_e2_IP="$PREFIX.2.1"
FOOSHA_e3_IP="$PREFIX.3.1"

# Router
function Foosha {
	apt update
	apt install isc-dhcp-relay -y

	cat >/etc/default/isc-dhcp-relay <<eof
SERVERS="192.214.2.4"
INTERFACES="eth3 eth1 eth2"
OPTIONS=""
eof

	service isc-dhcp-relay restart
}

function Jipangu {
	apt update
	apt install isc-dhcp-server -y

	cat >/etc/default/isc-dhcp-server <<eof
INTERFACES="eth0"
eof

	cat >/etc/dhcp/dhcpd.conf <<eof
ddns-update-style none;

option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;


log-facility local7;

subnet 192.214.1.0 netmask 255.255.255.0 {
    range 192.214.1.20 192.214.1.99;
    range 192.214.1.150 192.214.1.169;
    option routers 192.214.1.1;
    option broadcast-address 192.214.1.255;
    option domain-name-servers 192.214.2.2;
    default-lease-time 360;
    max-lease-time 7200;
}

subnet 192.214.3.0 netmask 255.255.255.0 {
    range 192.214.3.30 192.214.3.50;
    option routers 192.214.3.1;
    option broadcast-address 192.214.1.255;
    option domain-name-servers 192.214.2.2;
    default-lease-time 720;
    max-lease-time 7200;
}

subnet 192.214.2.0 netmask 255.255.255.0 {}

host Skypie {
    hardware ethernet aa:6e:ae:6a:df:e7;
    fixed-address 192.214.3.69;
}
eof

	service isc-dhcp-server restart
}

# Server
function EniesLobby {
	apt update
	apt install bind9 -y

	cat >/etc/bind/named.conf.options <<eof
options {
        directory "/var/cache/bind";

        forwarders {
                192.168.122.1;
        };

        allow-query { any; };

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
eof

mkdir -p /etc/bind/jarkom/

    cat >/etc/bind/named.conf.local <<eof
zone "jualbelikapal.ti6.com" {
  type master;
  file "/etc/bind/jarkom/jualbelikapal.ti6.com";
};
eof
    
        cat >/etc/bind/jarkom/jualbelikapal.ti6.com <<eof
\$TTL    604800
@       IN      SOA     jualbelikapal.ti6.com. root.jualbelikapal.ti6.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      jualbelikapal.ti6.com.
@       IN      A       192.214.2.3
eof
        
  service bind9 restart
}

function Skypie {
	echo "halo"
}

function Water7 {
  apt update
  apt install \
      squid \
      apache2-utils \
      -y

  touch /etc/squid/passwd
  htpasswd -mb /etc/squid/passwd luffybelikapalti6 luffy_ti6
  htpasswd -mb /etc/squid/passwd zorobelikapalti6 zoro_ti6

	cat >/etc/squid/squid.conf <<eof
include /etc/squid/acl.conf

http_port 5000
visible_hostname Water7

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Proxy
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive on
acl USERS proxy_auth REQUIRED

http_access allow acltime1
http_access allow acltime2
http_access allow acltime3

http_access deny all
http_access allow USERS
eof

	cat >/etc/squid/acl.conf <<eof
acl acltime1 time MTWH 07:00-11:00
acl acltime2 time TWHF 17:00-23:59
acl acltime3 time WHFA 00:00-03:00
eof

	service squid restart
}

# Client
function Loguetown {
	apt update
	# apt install lynx -y
}

function Alabasta {
	apt update
	# apt install lynx -y
}

function host-is { [[ $HOSTNAME = "$1" ]] && return 0 || return 1; }

if host-is Foosha; then
	Foosha

elif host-is TottoLand; then
	TottoLand
elif host-is Skypie; then
	Skypie

elif host-is EniesLobby; then
	EniesLobby
elif host-is Water7; then
	Water7
elif host-is Jipangu; then
	Jipangu

elif host-is Loguetown; then
	Loguetown
elif host-is Alabasta; then
	Alabasta
fi
