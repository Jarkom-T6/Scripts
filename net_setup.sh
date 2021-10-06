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
WATER7_IP="$PREFIX.2.3"

NET_CONF_FILE="/etc/network/interfaces"

## Setup Topologi ##

# Foosha
NET_CONF_FOOSHA="
auto eth0\n
iface eth0 inet dhcp\n
\n
auto eth1\n
iface eth1 inet static\n
	address $FOOSHA_e1_IP\n
	netmask 255.255.255.0\n
\n
auto eth2\n
iface eth2 inet static\n
	address $FOOSHA_e2_IP\n
	netmask 255.255.255.0\n
"

# Loguetown
NET_CONF_LOGUETOWN="
auto eth0\n
iface eth0 inet static\n
	address $LOGUETOWN_IP\n
	netmask 255.255.255.0\n
	gateway $FOOSHA_e1_IP\n
"

# Alabasta
NET_CONF_ALABASTA="
auto eth0\n
iface eth0 inet static\n
	address $ALABASTA_IP\n
	netmask 255.255.255.0\n
	gateway $FOOSHA_e1_IP\n
"

# EniesLobby
NET_CONF_ENIESLOBBY="
auto eth0\n
iface eth0 inet static\n
	address $ENIESLOBBY_IP\n
	netmask 255.255.255.0\n
	gateway $FOOSHA_e2_IP\n
"

# Water7
NET_CONF_WATER7="
auto eth0\n
iface eth0 inet static\n
	address $WATER7_IP\n
	netmask 255.255.255.0\n
	gateway $FOOSHA_e2_IP\n
"

if [[ $HOSTNAME = "Foosha" ]]; then
  sed 's/^/#/' -i /etc/resolv.conf
  echo -e $NET_CONF_FOOSHA >> $NET_CONF_FILE
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s $PREFIX.0.0/16

elif [[ $HOSTNAME = "LogueTown" ]]; then
  sed 's/^/#/' -i /etc/resolv.conf
  echo -e $NET_CONF_LOGUETOWN >> $NET_CONF_FILE
  sed 's/^/#/' -i /etc/resolv.conf
  echo "nameserver $DNS" >> /etc/resolv.conf

elif [[ $HOSTNAME = "Alabasta" ]]; then
  sed 's/^/#/' -i /etc/resolv.conf
  echo -e $NET_CONF_ALABASTA >> $NET_CONF_FILE
  sed 's/^/#/' -i /etc/resolv.conf
  echo "nameserver $DNS" >> /etc/resolv.conf

elif [[ $HOSTNAME = "EniesLobby" ]]; then
  sed 's/^/#/' -i /etc/resolv.conf
  echo -e $NET_CONF_ENIESLOBBY >> $NET_CONF_FILE
  sed 's/^/#/' -i /etc/resolv.conf
  echo "nameserver $DNS" >> /etc/resolv.conf

elif [[ $HOSTNAME = "Water7" ]]; then
  sed 's/^/#/' -i /etc/resolv.conf
  echo -e $NET_CONF_WATER7 >> $NET_CONF_FILE
  sed 's/^/#/' -i /etc/resolv.conf
  echo "nameserver $DNS" >> /etc/resolv.conf

else
  touch not-found
fi
