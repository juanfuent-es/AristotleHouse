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
#
#!/bin/bash
#     ____                  ________ 
#    / __ \____  ____ ___  / ____/ / 
#   / / / / __ \/ __ `__ \/ / __/ /  
#  / /_/ / /_/ / / / / / / /_/ / /___
# /_____/\____/_/ /_/ /_/\____/_____/
#
# Coded by @JuanFuent.es
#====================================

git pull
rake assets:clean RAILS_ENV=production
rake assets:precompile RAILS_ENV=production
sudo service apache2 reload