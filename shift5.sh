#!/bin/env bash

set -eo pipefail

# Router
function Foosha {
    apt update
    route add -net 192.214.7.0 netmask 255.255.255.128 gw 192.214.7.146
    route add -net 192.214.0.0 netmask 255.255.252.0 gw 192.214.7.146
    route add -net 192.214.7.128 netmask 255.255.255.248 gw 192.214.7.146
	route add -net 192.214.4.0 netmask 255.255.254.0 gw 192.214.7.150
	route add -net 192.214.6.0 netmask 255.255.255.0 gw 192.214.7.150
	route add -net 192.214.7.136 netmask 255.255.255.248 gw 192.214.7.150

	#iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 192.168.122.xxx -s 192.214.0.0/21
	apt install isc-dhcp-relay -y
}

function Water7 {
    apt update
    route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.214.7.145
	echo nameserver 192.168.122.1 > /etc/resolv.conf
	apt install isc-dhcp-relay -y

}

function Guanhao {
	apt update
    route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.214.7.149
	echo nameserver 192.168.122.1 > /etc/resolv.conf
	apt install isc-dhcp-relay -y
	
}

# Client Water 7
function Blueno {
	apt update
}

function Cipher {
	apt update
}

# Client Guanhao
function Fukurou {
	apt update
}

function Elena {
	apt update
}

#Server Switch 2
function Doriki { #DNS Server
	apt update
}

function Jipangu { #DHCP Server
	apt update

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

subnet 192.214.0.0 netmask 255.255.252.0 {
    range 192.214.0.2 192.214.3.254;
    option routers 192.214.0.1;
    option broadcast-address 192.214.3.255;
    option domain-name-servers 192.214.7.130;
    default-lease-time 360;
    max-lease-time 7200;
}

subnet 192.214.7.0 netmask 255.255.255.128 {
    range 192.214.7.2 192.214.7.126;
    option routers 192.214.7.1;
    option broadcast-address 192.214.7.127;
    option domain-name-servers 192.214.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}

subnet 192.214.4.0 netmask 255.255.254.0 {
    range 192.214.4.2 192.214.5.254;
    option routers 192.214.4.1;
    option broadcast-address 192.214.5.255;
    option domain-name-servers 192.214.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}

subnet 192.214.6.0 netmask 255.255.255.0 {
    range 192.214.6.2 192.214.6.254;
    option routers 192.214.6.1;
    option broadcast-address 192.214.6.255;
    option domain-name-servers 192.214.7.130;
    default-lease-time 720;
    max-lease-time 7200;
}

eof
	service isc-dhcp-server restart
}

#Server Switch 1
function Maingate { #Web Server
	apt update
}

function Jorge { #Web Server
	apt update
}

function host-is { [[ $HOSTNAME = "$1" ]] && return 0 || return 1; }

function update {
	local last_update = $(stat -c '%y' /var/cache/apt)
}

if host-is Foosha; then
	Foosha
elif host-is Water7; then
	Water7
elif host-is Guanhao; then
	Guanhao
elif host-is Blueno; then
	Blueno
elif host-is Cipher; then
	Cipher
elif host-is Jipangu; then
	Jipangu
elif host-is Doriki; then
	Doriki
elif host-is Elena; then
	Elena
elif host-is Fukurou; then
	Fukurou
elif host-is Maingate; then
	Maingate
elif host-is Jorge; then
	Jorge
fi