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
done < <(tail -n +2 accounts.csv)

