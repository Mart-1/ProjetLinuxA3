#!/bin/bash

#######################################Création d'un compte#######################################

# Vérifier que le script est exécuté en tant que root
if [ $(id -u) -ne 0 ]; then
    echo "Les permissions ne suffisent pas !"
    exit 1
fi

# Créer le dossier partagé au niveau supérieur
mkdir -p /home/shared
chown root:root /home/shared
chmod 755 /home/shared

# Lire le fichier de données utilisateur
while IFS=',' read -r prenom nom mot_de_passe
do
    # Générer le nom d'utilisateur et le dossier home
    utilisateur=$(echo "$prenom$nom" | awk '{print tolower(substr($0,1,1)) substr($0,2)}')
    home="/home/$utilisateur"
    
    # Créer le compte utilisateur
    useradd -m -s /bin/bash -p $(openssl passwd -1 $mot_de_passe) -e 0 $utilisateur
    
    # Forcer l'utilisateur à changer son mot de passe à la première connexion
    chage -d 0 $utilisateur
    
    # Créer le dossier a_sauver dans le dossier home de l'utilisateur
    mkdir $home/a_sauver
    
    # Créer le dossier partagé pour l'utilisateur
    mkdir /home/shared/$utilisateur
    chown $utilisateur:$utilisateur /home/shared/$utilisateur
    chmod 755 /home/shared/$utilisateur
    

done < utilisateurs.csv




#Sauvegarde







#Eclipse








#Pare-feux








#Nextcloud







#Monitoring