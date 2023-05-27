#!/bin/bash
#Création du dossier shared
if [ ! -d /home/shared ]; then
    mkdir -p /home/shared
	echo "Fichier Shared crée"
fi

chmod 755 /home/shared
chown root /home/shared

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

	#Adduser (apres suppression des anciens)
	echo "----------------------Suppression des anciennes instances----------------------"
	deluser --remove-home $login
	useradd -m -p $(openssl passwd -1 $password) $login
	chage -d 0 "$login"

	#Création des fichier dans le home et de leurs fichiers a_sauver
	rm -R /home/$login
	mkdir -p /home/$login/a_sauver
	#Applique droits et propriété a l'user
	chown $login /home/$login
	chown $login /home/$login/a_sauver
	chmod 755 /home/$login	
	chmod 755 /home/$login/a_sauver


	#Création des fichier dans le shared
	rmdir /home/shared/$login
	mkdir /home/shared/$login
	chown $login /home/shared/$login

done < <(tail -n +2 accounts.csv)

