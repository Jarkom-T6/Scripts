#!/bin/bash
PREFIX="192.214"
DNS="192.168.122.1"
FOOSHA_e1_IP="$PREFIX.1.1"
FOOSHA_e2_IP="$PREFIX.2.1"
LOGUETOWN_IP="$PREFIX.1.2"
ALABASTA_IP="$PREFIX.1.3"
ENIESLOBBY_IP="$PREFIX.2.2"
WATER7_IP="$PREFIX.2.3"
SKYPIE_IP="$PREFIX.2.4"
ENIESLOBBY_IP_REV="$(echo $ENIESLOBBY_IP | sed -r 's/([^\.]*)\.([^\.]*)\.([^\.]*)\.([^\.]*)/\3\.\2\.\1/')"
PTR_RECORD="$ENIESLOBBY_IP_REV.in-addr.arpa"

CASE=0
FAILED=0
SUCCESS=0

check_ip() {
        CASE=$((CASE + 1))
        RESULT="$(host -t A $1)"
        EXIT="$?"
        IP="$(echo $RESULT | head -1 | sed 's/.* address \(.*\)/\1/')"

        if [[ $EXIT != 0 ]]; then
                FAILED=$((FAILED + 1))
                echo "Check for $1 failed: $RESULT"
                return
        fi

        if [[ "$IP" != "$2" ]]; then
                FAILED=$((FAILED + 1))
                echo "IP NOT matched, expected $2 got $IP"
                return
        fi

        SUCCESS=$((SUCCESS + 1))
        echo "Check ip for $1 successful!"
}

check_port() {
        CASE=$((CASE + 1))
        if $(echo "telnet quit" | telnet $1 $2 2>/dev/null | grep -q "Connection Refused"); then
                FAILED=$((FAILED + 1))
                echo "Check port for $1 failed"
                return
        fi

        SUCCESS=$((SUCCESS + 1))
        echo "Check port for $1 successful!"
}

check_auth() {
        CASE=$((CASE + 1))
        if $(curl -v --stderr --user $2 $1 - | grep -qv "Index of /"); then
                FAILED=$((FAILED + 1))
                echo "Check auth for $1 failed"
                return
        fi

        SUCCESS=$((SUCCESS + 1))
        echo "Check auth for $1 successful!"
}

check_ptr() {
        echo "halo"
}

check_ip franky.ti6.com $ENIESLOBBY_IP
check_ip www.franky.ti6.com $ENIESLOBBY_IP

check_ip super.franky.ti6.com $SKYPIE_IP
check_ip www.super.franky.ti6.com $SKYPIE_IP

check_ip mecha.franky.ti6.com $SKYPIE_IP
check_ip www.mecha.franky.ti6.com $SKYPIE_IP

check_port general.mecha.franky.ti6.com 15500
check_port general.mecha.franky.ti6.com 15000
check_port www.general.mecha.franky.ti6.com 15500
check_port www.general.mecha.franky.ti6.com 15000

check_auth general.mecha.franky.ti6.com:15000 luffy:onepiece
check_auth general.mecha.franky.ti6.com:15500 luffy:onepiece
check_auth www.general.mecha.franky.ti6.com:15000 luffy:onepiece
check_auth www.general.mecha.franky.ti6.com:15500 luffy:onepiece

echo "
Test finished with:
$CASE case
$SUCCESS success test
$FAILED failed test
"
