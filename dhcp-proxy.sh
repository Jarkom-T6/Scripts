#!/bin/env bash

# Written by m42nk

set -eo pipefail
# Variables
GRP="TI6"
PREFIX="192.214"
DNS="192.168.122.1"
ENIESLOBBY_IP="$PREFIX.2.2"
WATER7_IP="$PREFIX.2.3"
LOGUETOWN_IP="$PREFIX.1.2"
ALABASTA_IP="$PREFIX.1.3"
JIPANGU_IP="$PREFIX.1.4"

FOOSHA_e1_IP="$PREFIX.1.1"
FOOSHA_e2_IP="$PREFIX.2.1"
ENIESLOBBY_IP_REV="$(echo $ENIESLOBBY_IP | sed -r 's/([^\.]*)\.([^\.]*)\.([^\.]*)\.([^\.]*)/\3\.\2\.\1/')"
PTR_RECORD="$ENIESLOBBY_IP_REV.in-addr.arpa"

# Router
function Foosha {
	apt update
	apt install isc-dhcp-server -y

	cat >/etc/default/isc-dhcp-server <<eof
INTERFACES="eth1"
eof

	cat >/etc/dhcp/dhcpd.conf <<eof
ddns-update-style none;
option domain-name "example.org";
option domain-name-servers ns1.example.org, ns2.example.org;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;

subnet 192.214.1.0 netmask 255.255.255.0 {
range 192.214.1.5 192.214.1.10;
option routers 192.214.1.1;
option broadcast-address 192.214.1.254;
option domain-name-servers 202.46.129.2;
default-lease-time 600;
max-lease-time 7200;
}

host Jipangu {
    hardware ethernet 2a:6c:0f:b2:e9:4c;
    fixed-address 192.214.1.13;
}
eof

	service isc-dhcp-server restart

}

# Server
function EniesLobby {
	apt update
	apt install bind9 -y
}

function Water7 {
	apt update
	apt install squid -y

	mv /etc/squid/squid.conf /etc/squid/squid.conf.bak

	cat >/etc/squid/squid.conf <<eof
http_port 8080
visible_hostname Water7
eof

	service squid restart
}

# Client
function Loguetown {
	apt update
	apt install lynx -y
}

function Alabasta {
	apt update
	apt install lynx -y
}

function Jipangu {
	apt update
	apt install lynx -y
}

function host-is { [[ $HOSTNAME = "$1" ]] && return 0 || return 1; }
function update {
	local last_update = $(stat -c '%y' /var/cache/apt)
}

if host-is Foosha; then
	Foosha
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
