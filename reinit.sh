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
        apt install bind9 -y

	echo '
zone "franky.ti6.com" {
	type master;
  	also-notify { ' $WATER7_IP '; };
  	allow-transfer { ' $WATER7_IP '; };
	file "/etc/bind/kaizoku/franky.ti6.com";
};

zone "super.franky.ti6.com" {
	type master;
  	also-notify { ' $WATER7_IP '; };
  	allow-transfer { ' $WATER7_IP '; };
	file "/etc/bind/kaizoku/super.franky.ti6.com";
};

zone "'$PTR_RECORD'" {
	type master;
	file "/etc/bind/kaizoku/'$PTR_RECORD'";
};
' >/etc/bind/named.conf.local

	mkdir -p /etc/bind/kaizoku
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
@       IN      A       $ENIESLOBBY_IP
www     IN      CNAME   franky.ti6.com. 
super   IN      A       $SKYPIE_IP     
ns1     IN      A       $WATER7_IP     
mecha   IN      NS      ns1
" >/etc/bind/kaizoku/franky.ti6.com

	echo "\
\$TTL    604800
@       IN      SOA     super.franky.ti6.com. root.super.franky.ti6.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      super.franky.ti6.com.
@       IN      A       $SKYPIE_IP
www     IN      CNAME   super.franky.ti6.com. 
" >/etc/bind/kaizoku/super.franky.ti6.com

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
2                  IN      PTR     franky.ti6.com. ; byte ke 4 dari $ENIESLOBBY_IP
" >/etc/bind/kaizoku/$PTR_RECORD

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

	echo '
zone "franky.ti6.com" {
 type slave;
 masters { ' $ENIESLOBBY_IP '; };
 file "/var/lib/bind/franky.ti6.com";
};

zone "mecha.franky.ti6.com" {
	type master;
	file "/etc/bind/sunnygo/mecha.franky.ti6.com";
};

zone "general.mecha.franky.ti6.com" {
	type master;
	file "/etc/bind/sunnygo/general.mecha.franky.ti6.com";
};

' >/etc/bind/named.conf.local

mkdir -p /etc/bind/sunnygo

	echo "\
\$TTL    604800
@       IN      SOA     mecha.franky.ti6.com. root.mecha.franky.ti6.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      mecha.franky.ti6.com.
@       IN      A       $SKYPIE_IP
www     IN      CNAME   mecha.franky.ti6.com. 
general IN      A       $SKYPIE_IP     
" >/etc/bind/sunnygo/mecha.franky.ti6.com

	echo "\
\$TTL    604800
@       IN      SOA     general.mecha.franky.ti6.com. root.general.mecha.franky.ti6.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      general.mecha.franky.ti6.com.
@       IN      A       $SKYPIE_IP
www     IN      CNAME   general.mecha.franky.ti6.com. 
" >/etc/bind/sunnygo/general.mecha.franky.ti6.com


service bind9 restart

###
# Skypie
###

elif [[ $HOSTNAME = "Skypie" ]]; then
	apt update
	apt install unzip \
	apache2-utils \
	apache2 \
	php \
	libapache2-mod-php7.0 -y

	[[ -d /var/www/franky.ti6.com ]] && rm -rf /var/www/franky.ti6.com
	[[ -d /var/www/super.franky.ti6.com ]] && rm -rf /var/www/super.franky.ti6.com
	[[ -d /var/www/general.mecha.franky.ti6.com ]] && rm -rf /var/www/general.mecha.franky.ti6.com

	curl -Lk https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/franky.zip -o franky.zip
	unzip franky.zip
	mv franky /var/www/franky.ti6.com

	curl -Lk https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/super.franky.zip -o super.franky.zip
	unzip super.franky.zip
	mv super.franky /var/www/super.franky.ti6.com

	curl -Lk https://github.com/FeinardSlim/Praktikum-Modul-2-Jarkom/raw/main/general.mecha.franky.zip -o general.mecha.franky.zip
	unzip general.mecha.franky.zip
	mv general.mecha.franky /var/www/general.mecha.franky.ti6.com

	echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName franky.ti6.com
        ServerAlias www.franky.ti6.com
        DocumentRoot /var/www/franky.ti6.com

	<Directory /var/www/franky.ti6.com>
        	Options +FollowSymLinks -Multiviews
		AllowOverride All
	</Directory>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
' > /etc/apache2/sites-available/franky.ti6.com.conf

echo '
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName super.franky.ti6.com
        ServerAlias www.super.franky.ti6.com
        DocumentRoot /var/www/super.franky.ti6.com

         <Directory /var/www/super.franky.ti6.com>
             Options +FollowSymLinks -Multiviews
             AllowOverride All
         </Directory>

         <Directory /var/www/super.franky.ti6.com/public>
             Options Indexes
             AllowOverride All
         </Directory>

         <Directory /var/www/super.franky.ti6.com/error>
             Options -Indexes
             AllowOverride All
         </Directory>



        # Alias "/" "/var/www/super.franky.ti6.com/public"
        Alias "/js" "/var/www/super.franky.ti6.com/public/js"
        ErrorDocument 404 /error/404.html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>


# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
' > /etc/apache2/sites-available/super.franky.ti6.com.conf

	echo '
<VirtualHost *:15000 *:15500>
        ServerAdmin webmaster@localhost
        ServerName general.franky.ti6.com
        ServerAlias www.general.mecha.franky.ti6.com
        DocumentRoot /var/www/general.mecha.franky.ti6.com

	<Directory /var/www/general.mecha.franky.ti6.com>
             AllowOverride All
         </Directory>

	<Location />
		Deny from all
		AuthUserFile /var/www/general.mecha.franky.ti6
		AuthName "Restricted Area"
		AuthType Basic
		Satisfy Any
		require valid-user
	</Location>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
' > /etc/apache2/sites-available/general.mecha.franky.ti6.com.conf


	echo '
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule (.*) /index.php/$1

RewriteCond %{HTTP_HOST} ^192\.214\.2.4$
RewriteRule ^(.*)$ http://www.franky.ti6.com/$1 [L,R=301]
</IfModule>
' > /var/www/franky.ti6.com/.htaccess

	echo '
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond %{REQUEST_URI} .*franky.*\.(jpg|png)
RewriteCond %{REQUEST_URI} !/public/images/franky.png
RewriteRule ^(.*)/ /public/images/franky.png [L,R=301]
</IfModule>

' > /var/www/super.franky.ti6.com/.htaccess

	echo '
Listen 80
Listen 15000
Listen 15500

<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
' > /etc/apache2/ports.conf

	a2ensite franky.ti6.com super.franky.ti6.com general.mecha.franky.ti6.com
	[[ -f /etc/apache2/sites-enabled/000-default.conf ]] && a2dissite 000-default
	a2enmod rewrite
	htpasswd -bc /var/www/general.mecha.franky.ti6 luffy onepiece

	service apache2 restart

###
# Loguetown
###
elif [[ $HOSTNAME = "Loguetown" ]]; then
	apt update
	apt install lynx -y
	apt install dnsutils -y

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
	apt install lynx -y
	apt install dnsutils -y
	# sed -ie 's/^#*/#/g' /etc/resolv.conf
	echo '
# nameserver 192.168.122.1
nameserver '$ENIESLOBBY_IP' # IP EniesLobby
nameserver '$WATER7_IP' # IP Water7
' >/etc/resolv.conf

fi
