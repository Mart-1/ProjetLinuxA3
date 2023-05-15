#!/bin/bash
#Création du dossier shared
if [ ! -d /home/shared ]; then
    mkdir -p /home/shared
	echo "Fichier Shared crée"
fi
chmod 755 /home/shared

while IFS=';' read -r name surname mail passwd; do
    # Suppression des espaces dans les champs
    name=$(echo "$name" | sed 's/ //g')
    surname=$(echo "$surname" | sed 's/ //g')
    mail=$(echo "$mail" | sed 's/ //g')
    passwd=$(echo "$passwd" | sed 's/ //g')

    #Login
    login=${name:0:1}$surname

    password=$(echo "$passwd" | sed -e 's/\r//g')
    echo -e "$login - $password"
	
	#Création des fichier dans le home et de leurs fichiers a_sauver
	rm -R /home/$login
	
	mkdir /home/$login	
	mkdir /home/$login/a_sauver

	#Adduser (apres suppression des anciens)
	echo "----------------------Suppression des anciennes instances----------------------"
	deluser --remove-home $login
	useradd -m -p $(openssl passwd -1 $password) $login
	chage -d 0 "$login"
	
	
	
	
	
	#Création des fichier dans le shared 
	rmdir /home/shared/$login
	mkdir /home/shared/$login
	sudo chown $login /home/shared/$login
	
	
done < <(tail -n +2 accounts.csv)

