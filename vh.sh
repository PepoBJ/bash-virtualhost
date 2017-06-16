#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
BLUE='\033[0;34m'

printf "\n\t\t${BLUE}[CREANDO VIRTUAL HOST]${NC}\n\n"

if [ $# -lt 2 ]; then
    printf "${RED}[ERROR]\t${NC}Parametros Incompletos\n"
    printf "${BLUE}[USO]\t${NC}sudo vh web.site \$USER\n"
    exit 1
fi

if ! [ $(id -u) = 0 ]; then 
	printf "${RED}[ERROR]\tPermisos denegados${NC}\n"
	printf "${BLUE}[USO]\t${NC}sudo vh web.site \$USER\n"
	exit 1 
fi

printf "\n${BLUE}>> Creando carpetas para [$1] ${NC}\n"
mkdir -p /var/www/$1/public_html
printf "\n${BLUE}>> Estableciendo permisos para usuario [$2] en sitio [$1] ${NC}\n"
chown -R $2:$2 /var/www/$1/
chmod -R 755 /var/www

printf "\n${BLUE}>> Creando archivos de configuracion para sitio [$1] ${NC}\n"
touch /etc/apache2/sites-available/$1.conf
echo "<VirtualHost *:80>
		ServerAdmin admin@$1
		ServerName $1
		ServerAlias www.$1
		DocumentRoot /var/www/$1/public_html
		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>" > /etc/apache2/sites-available/$1.conf

printf "\n${BLUE}>> Habilitando sitio [$1] ${NC}\n\n"
a2ensite $1.conf
printf "\n${BLUE}>> Reiniciando apache2 ${NC}\n"
/etc/init.d/apache2 restart
printf "\n${BLUE}>> Añadiendo sitio [$1] a host[local]${NC}\n"
echo "127.0.0.1  $1" >> /etc/hosts
printf "\n${BLUE}>> VIRTUALHOST PARA SITIO [http://$1] HABILITADO${NC}\n"