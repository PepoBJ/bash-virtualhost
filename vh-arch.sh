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
mkdir -p /srv/http/$1/public
printf "\n${BLUE}>> Estableciendo permisos para usuario [$2] en sitio [$1] ${NC}\n"
chown -R $2:$2 /srv/http/$1/
chmod -R 755 /srv/http

printf "\n${BLUE}>> Creando archivos de configuracion para sitio [$1] ${NC}\n"

echo "#[VH] $1
<VirtualHost *:80>
		ServerAdmin admin@$1
		ServerName $1
		ServerAlias www.$1
		DocumentRoot /srv/http/$1/public
		ErrorLog ${APACHE_LOG_DIR}/$1-error.log
		CustomLog ${APACHE_LOG_DIR}/$1-access.log combined
	</VirtualHost>" >> /etc/httpd/conf/extra/httpd-vhosts.conf

printf "\n${BLUE}>> Habilitando sitio [$1] ${NC}\n\n"
apachectl configtest
printf "\n${BLUE}>> Reiniciando apache2 ${NC}\n"
systemctl restart httpd
printf "\n${BLUE}>> Añadiendo sitio [$1] a host[local]${NC}\n"
echo "127.0.0.1  $1" >> /etc/hosts
printf "\n${BLUE}>> VIRTUALHOST PARA SITIO [http://$1] HABILITADO${NC}\n"
