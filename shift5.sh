#!/bin/env bash

set -eo pipefail

# Router
function Foosha {
    apt update
    	# route add -net 192.214.7.0 netmask 255.255.255.128 gw 192.214.7.146
    	# route add -net 192.214.0.0 netmask 255.255.252.0 gw 192.214.7.146
    	# route add -net 192.214.7.128 netmask 255.255.255.248 gw 192.214.7.146
	# route add -net 192.214.4.0 netmask 255.255.254.0 gw 192.214.7.150
	# route add -net 192.214.6.0 netmask 255.255.255.0 gw 192.214.7.150
	# route add -net 192.214.7.136 netmask 255.255.255.248 gw 192.214.7.150
	#Ganti IP Masquarade, Jangan lupa ganti source nya dengan IP Eth 0
	IPETH0="$(ip -br a | grep eth0 | awk '{print $NF}' | cut -d'/' -f1)"
	iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source "$IPETH0" -s 192.214.0.0/21
	apt install isc-dhcp-relay -y

	cat >/etc/default/isc-dhcp-relay <<eof
SERVERS="192.214.7.131"
INTERFACES="eth2 eth1"
OPTIONS=""
eof

	service isc-dhcp-relay restart
	iptables -A FORWARD -d 192.214.7.128/29 -i eth0 -p tcp --dport 80 -j DROP

}

function Water7 {
	#echo nameserver 192.214.7.130 > /etc/resolv.conf
	#route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.214.7.145
    apt update
	apt install isc-dhcp-relay -y

	cat >/etc/default/isc-dhcp-relay <<eof
SERVERS="192.214.7.131"
INTERFACES="eth2 eth1 eth3 eth0"
OPTIONS=""
eof

	service isc-dhcp-relay restart

}

function Guanhao {
	# echo nameserver 192.214.7.130 > /etc/resolv.conf
	# route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.214.7.149
	apt update
	apt install isc-dhcp-relay -y

	cat >/etc/default/isc-dhcp-relay <<eof
SERVERS="192.214.7.131"
INTERFACES="eth0 eth3 eth1 eth2"
OPTIONS=""
eof

	service isc-dhcp-relay restart

	iptables -A PREROUTING -t nat -p tcp -d 192.214.7.130 -m statistic --mode nth --every 2 --packet 0 -j DNAT --to-destination 192.214.7.138:80
	iptables -A PREROUTING -t nat -p tcp -d 192.214.7.130 -j DNAT --to-destination 192.214.7.139:80
}

# Client Water 7
function Blueno {
	#echo nameserver 192.214.7.130 > /etc/resolv.conf
	apt update
}

function Cipher {
	#echo nameserver 192.214.7.130 > /etc/resolv.conf
	apt update
}

# Client Guanhao
function Fukurou {
	# echo nameserver 192.214.7.130 > /etc/resolv.conf
	apt update
}

function Elena {
	echo nameserver 192.214.7.130 > /etc/resolv.conf
	apt update
}

#Server Switch 2
function Doriki { #DNS Server
	#echo nameserver 192.168.122.1 > /etc/resolv.conf
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
	service bind9 restart
	#No. 3 Reject bila terdapat PING ICMP Lebih dari 3
	iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP
	#No. 4 Akses dari subnet Blueno dan Cipher
	#Blueno
	iptables -A INPUT -s 192.214.7.0/25 -m time --weekdays Fri,Sat,Sun -j REJECT
	iptables -A INPUT -s 192.214.7.0/25 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
	iptables -A INPUT -s 192.214.7.0/25 -m time --timestart 15:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
	#Cipher
	iptables -A INPUT -s 192.214.0.0/22 -m time --weekdays Fri,Sat,Sun -j REJECT
	iptables -A INPUT -s 192.214.0.0/22 -m time --timestart 00:00 --timestop 06:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
	iptables -A INPUT -s 192.214.0.0/22 -m time --timestart 15:01 --timestop 23:59 --weekdays Mon,Tue,Wed,Thu -j REJECT
	#No. 5 Akses dari subnet Elena dan Fukuro
	iptables -A INPUT -s 192.214.4.0/23 -m time --timestart 07:00 --timestop 15:00 -j REJECT #Elena
	iptables -A INPUT -s 192.214.6.0/24 -m time --timestart 07:00 --timestop 15:00 -j REJECT #Fukuro
}

function Jipangu { #DHCP Server
	#echo nameserver 192.214.7.130 > /etc/resolv.conf
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

subnet 192.214.7.128 netmask 255.255.255.248 {}
subnet 192.214.7.144 netmask 255.255.255.252 {}
subnet 192.214.7.148 netmask 255.255.255.252 {}
subnet 192.214.7.136 netmask 255.255.255.248 {}
eof
	service isc-dhcp-server restart
	iptables -A INPUT -p icmp -m connlimit --connlimit-above 3 --connlimit-mask 0 -j DROP
}

#Server Switch 1
function Maingate { #Web Server
	#echo nameserver 192.214.7.130 > /etc/resolv.conf
	apt update
	apt install apache2 -y
	service apache2 start
	echo "$HOSTNAME" > /var/www/html/index.html
}

function Jorge { #Web Server
	#echo nameserver 192.214.7.130 > /etc/resolv.conf
	apt update
	apt install apache2 -y
	service apache2 start
	echo "$HOSTNAME" > /var/www/html/index.html
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
