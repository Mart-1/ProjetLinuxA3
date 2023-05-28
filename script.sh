#!/bin/bash
#Création du dossier shared
if [ ! -d /home/shared ]; then
    mkdir -p /home/shared
	echo "Fichier Shared crée"
fi

chmod 755 /home/shared
chown root /home/shared

service cron start

# Création du dossier de sauvegarde 
sudo -u isen ssh mlobel25@10.30.48.100 "mkdir /home/saves"
sudo -u isen ssh mlobel25@10.30.48.100 "chmod 006 /home/saves"

echo "Entrez votre mail : "
read mymail

echo "Mot de passe :"
read user_password

echo "Port de connexion :"
read port

echo "Serveur SMTP : "
read smtp

echo "################################################################################"

while IFS=';' read -r name surname mail passwd; do
    # Suppression des espaces dans les champs
    name=$(echo "$name" | sed 's/ //g')
    surname=$(echo "$surname" | sed 's/ //g')
    mail=$(echo "$mail" | sed 's/ //g')
    passwd=$(echo "$passwd" | sed 's/ //g')

    #Login
    login=${name:0:1}$surname

    password=$(echo "$passwd" | sed -e 's/\r//g')
    #echo -e "$login - $password"

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

	#Sauvegarde
	#Envoie de la save sur le serveur
	save_dir="save_$login.tgz"
	crontab -l | { cat; echo "0 23 * * 1-5 tar -czvf $save_dir /home/$login/a_sauver && scp -i /home/isen/.ssh/id_rsa $save_dir mlobel25@10.30.48.100:/home/saves && rm $save_dir"; } | crontab -b -
	
	#ssh -n -i ~/.ssh/id_rsa mlobel25@10.30.48.100 "mail --subject \"Vos identifiants de session\" --exec \"set sendmail=smtp://${mymail/@/%40}:${user_password/@/%40}@$smtp:$port\" --append \"From:$mymail\" $mail <<< \"Votre compte à été créer avec succès ! Voici vos identifiants, Mail : $mail |         | Password : $password \""

done < <(tail -n +2 accounts.csv)