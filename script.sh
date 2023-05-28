#!/bin/bash
#Création du dossier shared
if [ ! -d /home/shared ]; then
    mkdir -p /home/shared
	echo "Fichier Shared crée"
fi

chmod 755 /home/shared
chown root /home/shared

# CRON Start
crontab -r
service cron start

#Suppression du fichier retablir_sauvegarde.sh
rm /home/retablir_sauvegarde.sh


# Création du dossier de sauvegarde 
sudo -u isen ssh mlobel25@10.30.48.100 "mkdir /home/saves"
sudo -u isen ssh mlobel25@10.30.48.100 "chmod 006 /home/saves" #6--> lecture ecriture


#Demande les informations pour envoyer le mail
echo "Entrez votre mail : "
read mymail

echo "Mot de passe :"
read user_password

echo "Port de connexion :"
read port

echo "Serveur SMTP : "
read smtp

echo "################################################################################"

##--------------------------FIRE-WALL--------------------------

# Installation de ufw 
apt install ufw -y
ufw enable
# filtre FTP
ufw deny ftp
#filtre UDP
ufw deny proto udp from any to any


#--------------------------Installation de Eclipse--------------------------
# Téléchargement 
wget https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/oomph/epp/2023-03/R/eclipse-inst-jre-linux64.tar.gz -O eclipse.tar.gz
tar -zxvf eclipse.tar.gz -C /opt/
mv "/opt/eclipse-installer" /opt/eclipse
# Configuration des droits (comme dans l'énnoncé)
chown -R root:root /opt/eclipse
chmod -R 755 /opt/eclipse
# Création d'un lien symbolique dans le home (accessibilité)
ln -s /opt/eclipse /home/eclipse

# Eclipse configuré :)

#Boucle de lecture
while IFS=';' read -r name surname mail passwd; do
    
	#--------------------------Lecture du fichier CSV--------------------------

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

	#--------------------------Sauvegarde--------------------------

	#On creer le fichier de restauration
	touch /home/retablir_sauvegarde.sh
	echo "#!/bin/bash" >> /home/retablir_sauvegarde.sh

    #Récupère le fichier de sauvegarde sur le serveur distant 
    echo "scp -i /home/isen/.ssh/id_rsa mlobel25@10.30.48.100:/home/saves/save_$1.tgz" >> /home/retablir_sauvegarde.sh
	#Puis on le décompresse
    echo "tar -xzvf save_$1.tgz" >> /home/retablir_sauvegarde.sh
    echo "rm -r save_$1.tgz" >> /home/retablir_sauvegarde.sh
    echo "rm -r /home/$1/a_sauver" >> /home/retablir_sauvegarde.sh
    echo "mv home/$1/a_sauver /home/$1" >> /home/retablir_sauvegarde.sh
    echo "rm -r home" >> /home/retablir_sauvegarde.sh
	#bug

	#Envoie de la save sur le serveur
	save_dir="save_$login.tgz"
	crontab -l | { cat; echo "0 23 * * 1-5 tar -czvf $save_dir /home/$login/a_sauver && scp -i /home/isen/.ssh/id_rsa $save_dir mlobel25@10.30.48.100:/home/saves && rm $save_dir"; } | crontab -b -
	
	
	
	#Envoie par mail des infos de connexion
	#ssh -n -i ~/.ssh/id_rsa mlobel25@10.30.48.100 "mail --subject \"Vos identifiants de session\" --exec \"set sendmail=smtp://${mymail/@/%40}:${user_password/@/%40}@$smtp:$port\" --append \"From:$mymail\" $mail <<< \"Bonjour, Votre compte à été créer avec succès ! Voici voter identifiant ainsi que votre mot de passe (qui devra être changé a la première connexion) , Identifiant : $login / Mot de passe : $password \""

done < <(tail -n +2 accounts.csv)