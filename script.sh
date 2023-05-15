#!/bin/bash
#Création du dossier shared
if [ ! -d /home/shared ]; then
    mkdir -p /home/shared
fi
chmod 755 /home/shared
while IFS=";" read -r name surname mail passwd; do
	#Login + Suppression des espaces et des \n
	login="${name:0:1}$surname"
	login=$(echo "$login" | sed 's/[[:space:]]//g')
	login=$(echo "$login" | sed 's/\r//g')
	
	password=$(echo "$passwd" | sed -e 's/\r//g')

	echo -e "$login - $password"
done < <(tail -n +2 accounts.csv)