#!/bin/bash

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
  echo "Veuillez exécuter ce script avec sudo ou en tant que root."
  exit 1
fi

echo "Installation de Docker et Docker Compose..."

# Étape 1 : Mise à jour du système
echo "Mise à jour des paquets..."
apt update && apt upgrade -y

# Étape 2 : Installation des prérequis pour Docker
echo "Installation des prérequis pour Docker..."
apt install -y apt-transport-https ca-certificates curl software-properties-common

# Étape 3 : Ajout du dépôt officiel Docker
echo "Ajout du dépôt officiel Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Étape 4 : Installation de Docker
echo "Installation de Docker..."
apt update && apt install -y docker-ce docker-ce-cli containerd.io

# Vérification de l'installation de Docker
if docker --version; then
  echo "Docker a été installé avec succès !"
else
  echo "Échec de l'installation de Docker."
  exit 1
fi

# Étape 5 : Ajout de l'utilisateur au groupe Docker
echo "Ajout de l'utilisateur actuel au groupe Docker..."
usermod -aG docker $USER
echo "Veuillez vous déconnecter et vous reconnecter pour que les modifications prennent effet."

# Étape 6 : Installation de Docker Compose
echo "Installation de Docker Compose..."

# Détection de l'architecture système
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  BIN_URL="https://github.com/docker/compose/releases/download/v2.32.0/docker-compose-linux-x86_64"
elif [[ "$ARCH" == "aarch64" ]]; then
  BIN_URL="https://github.com/docker/compose/releases/download/v2.32.0/docker-compose-linux-aarch64"
elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
  BIN_URL="https://github.com/docker/compose/releases/download/v2.32.0/docker-compose-linux-i386"
else
  echo "Architecture non prise en charge : $ARCH"
  exit 1
fi

# Téléchargement de Docker Compose
curl -fSL "$BIN_URL" -o /usr/local/bin/docker-compose
if [ $? -ne 0 ]; then
  echo "Échec du téléchargement de Docker Compose. Vérifiez votre connexion ou l'URL."
  exit 1
fi

# Attribution des permissions d'exécution
chmod +x /usr/local/bin/docker-compose

# Vérification de l'installation de Docker Compose
if docker-compose --version; then
  echo "Docker Compose a été installé avec succès !"
else
  echo "Échec de l'installation de Docker Compose."
  exit 1
fi

echo "Installation terminée. Vous devez vous déconnecter puis vous reconnecter pour utiliser Docker sans sudo."
