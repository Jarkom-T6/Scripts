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
}

# Server
function EniesLobby {
  apt update
  apt install bind9 -y
}

function Water7 {
  apt update
  apt install squid -y
}

# Client

function Loguetown {
  apt update
}

function Alabasta {
  apt update
}

function Jipangu {
  apt update
}

function host-is() { [[ $HOSTNAME = "$1" ]] && return 0 || return 1 }

if host-is Foosha; then Foosha
elif host-is EniesLobby; then EniesLobby
elif host-is Water7; then Jipangu
elif host-is Jipangu; then Jipangu
elif host-is Loguetown; then Loguetown
elif host-is Alabasta; then Alabasta
fi
