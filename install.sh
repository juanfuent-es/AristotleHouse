#!/bin/bash

#===================================================#
# 				RoR on Ubuntu 22                    #
#		 	  Script de instalación		    	  	#
#---------------------------------------------------#
#		Escrito por Juan Fuentes el 19/07/2020    	#
#	    	Actualizado el 08/01/2024  	        	#
#===================================================#

#===================================================#
#        	NO EDITAR FUERA DE LINUX	      		#
#---------------------------------------------------#
# En caso de edición fuera de linux, es probable no #
# pueda ejecutarse el script por el formato, en 	#
# este caso deberemos de volver a encodear con el 	#
# paquete dos2unix y posteriormente convertirlo:	#
#													#
# sudo apt-get install dos2unix   					#
# dos2unix install.sh			  					#
# sudo chmod +x install.sh			  				#
#===================================================#

#!/bin/bash

# Dependencias de sistema
sudo apt update

# Dependencias de Ruby on Rails
sudo apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl software-properties-common libffi-dev git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev libsqlite3-dev sqlite3 -y

sudo apt-get install ruby3.0 -y
sudo apt-get install ruby3.0-dev -y
sudo apt install git curl libssl-dev libreadline-dev zlib1g-dev autoconf bison build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev libgdbm-dev -y
gem install bundler

#---------------------------------------------------#
# INSTALACIÓN DE APACHE								#
# @docs: https://help.ubuntu.com/lts/serverguide/httpd.html
sudo apt-get install apache2 -y
sudo apt install apache2

#---------------------------------------------------
# INSTALACIÓN DE PASSENGER							
# @docs: https://www.phusionpassenger.com/library/	
# @see: https://www.phusionpassenger.com/docs/advanced_guides/install_and_upgrade/apache/install/oss/focal.html
# @ubuntu 22: https://www.phusionpassenger.com/docs/advanced_guides/install_and_upgrade/apache/install/oss/jammy.html
#---------------------------------------------------
# Instalamos el paquete
# Install our PGP key and add HTTPS support for APT
sudo apt-get install -y dirmngr gnupg apt-transport-https ca-certificates curl

curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null

# Add our APT repository
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger jammy main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update

# Install Passenger + Apache module
sudo apt-get install -y libapache2-mod-passenger

# Actualizamos sistema
sudo apt-get update
# Activamos el módulo ´mod-passenger´
sudo a2enmod passenger
# Reiniciamos apache para poder ocupar passenger
sudo apache2ctl restart
#---------------------------------------------------#
# INSTALACIÓN DE IMAGEMAGICK						
# @docs: http://www.imagemagick.org/				
# @return: Procesamiento de imágenes				
#---------------------------------------------------#
sudo apt-get install imagemagick -y
sudo apt-get install libmagickwand-dev -y
sudo apt-get install libjpeg-dev libpng-dev libtiff-dev libwebp-dev -y
#
#---------------------------------------------------#
# INSTALACIÓN DE POSTGRESQL
#---------------------------------------------------#
sudo apt update
sudo apt install postgresql postgresql-contrib libpq-dev -y
sudo systemctl status postgresql

# login & set 'postgres' password
sudo su postgres
sudo -u postgres
psql
ALTER USER postgres WITH PASSWORD 'password'; #Asignación de contraseña a usuario default
CREATE USER postgres WITH PASSWORD 'password'; # Creación de usuario postgres con contraseña
ALTER USER postgres WITH SUPERUSER;
\q #exit
sudo service postgresql restart;

# Editar archivo de configuración 'pg_hba.conf'
sudo nano /etc/postgresql/{version}/main/pg_hba.conf

from:   local   all             postgres                                peer
to:     local   all             postgres                                md5

sudo service postgresql restart

# node
sudo apt update
curl -sL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh
sudo bash /tmp/nodesource_setup.sh
sudo apt install nodejs
sudo npm i -g yarn

sudo a2enmod headers
sudo a2enmod mod_headers
sudo a2enmod expires
sudo a2enmod rewrite
sudo service apache2 restart

#SSL
sudo apt install certbot python3-certbot-apache -y

# download your repo or upload to html/* folder
cd /var/www/html
gem install bundler
bundle install

# update
sudo apt-get update && sudo apt-get upgrade -y

rake secret
sudo EDITOR=nano rails credentials:edit

git config --global color.ui true
git config --global user.name "JuanFuent.es"
git config --global user.email "input@juanfuent.es"
ssh-keygen
cat ~/.ssh/id_rsa.pub