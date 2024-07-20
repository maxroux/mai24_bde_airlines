#!/bin/bash

# Fonction pour annuler l'opération et revenir à l'état initial
revert_operation() {
  echo "Erreur détectée. Annulation de l'opération et retour à l'état initial."
  if [ -f $COMPOSE_FILE.bak ]; then
    mv $COMPOSE_FILE.bak $COMPOSE_FILE
    echo "Fichier docker-compose.yml restauré."
  fi
  docker-compose up -d
  echo "Services Docker Compose redémarrés."
  exit 1
}

# Vérifier si le nom du volume partiel et le répertoire cible sont fournis
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <nom_partiel_du_volume> <repertoire_cible>"
  exit 1
fi

PARTIAL_VOLUME_NAME=$1
TARGET_DIR=$2
BACKUP_DIR=$(pwd)/backup

# Trouver le nom complet du volume Docker
VOLUME_NAME=$(docker volume ls --format "{{.Name}}" | grep "$PARTIAL_VOLUME_NAME")

# Vérifier si le volume Docker a été trouvé
if [ -z "$VOLUME_NAME" ]; then
  echo "Erreur: Le volume contenant '$PARTIAL_VOLUME_NAME' n'a pas été trouvé"
  exit 1
fi

echo "Volume trouvé: $VOLUME_NAME"

# Arrêter les services Docker Compose avant de sauvegarder les données
echo "Arrêt des services Docker Compose"
docker-compose down || revert_operation

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p $BACKUP_DIR || revert_operation

# Vérifier le contenu du volume avant de copier
echo "Vérification du contenu du volume $VOLUME_NAME"
docker run --rm -v ${VOLUME_NAME}:/volume alpine ls -la /volume || revert_operation

# Sauvegarder les données du volume Docker avec des messages de débogage
echo "Sauvegarde des données du volume $VOLUME_NAME vers $BACKUP_DIR"
docker run --rm -v ${VOLUME_NAME}:/volume -v ${BACKUP_DIR}:/backup alpine \
sh -c "cd /volume && tar -cf - . | tar -xf - -C /backup" || revert_operation

# Vérifier si la sauvegarde a réussi
if [ "$(ls -A $BACKUP_DIR)" ]; then
  echo "Sauvegarde réussie"
else
  revert_operation
fi

# Créer le répertoire cible s'il n'existe pas
mkdir -p $TARGET_DIR || revert_operation
chmod -R 755 $TARGET_DIR || revert_operation

# Restaurer les données dans le répertoire cible
echo "Restauration des données vers le répertoire cible $TARGET_DIR"
cp -r ${BACKUP_DIR}/* $TARGET_DIR/ || revert_operation

# Mettre à jour le fichier docker-compose.yml pour utiliser le bind mount
echo "Mise à jour du fichier docker-compose.yml pour utiliser le bind mount"
COMPOSE_FILE="docker-compose.yml"
SERVICE=""
VOLUME_PATH=""

# Créer une sauvegarde du fichier docker-compose.yml
cp $COMPOSE_FILE $COMPOSE_FILE.bak || revert_operation

# Trouver le service et le chemin associé au volume
while IFS= read -r line; do
  if [[ $line =~ ^[[:alnum:]_-]+: ]]; then
    SERVICE=$(echo $line | cut -d: -f1)
  elif [[ $line =~ -\ $PARTIAL_VOLUME_NAME: ]]; then
    VOLUME_PATH=$(echo $line | cut -d: -f2 | tr -d ' ')
    break
  fi
done < $COMPOSE_FILE

# Si le service et le chemin sont trouvés, mettre à jour le docker-compose.yml
if [[ -n $SERVICE && -n $VOLUME_PATH ]]; then
  echo "Remplacement de la ligne contenant $PARTIAL_VOLUME_NAME par $TARGET_DIR:$VOLUME_PATH"
  sed -i.bak "/$PARTIAL_VOLUME_NAME:/c\      - $TARGET_DIR:$VOLUME_PATH" $COMPOSE_FILE || revert_operation
  echo "Mise à jour de $COMPOSE_FILE pour le service $SERVICE avec le bind mount $TARGET_DIR:$VOLUME_PATH"
else
  revert_operation
fi

# Redémarrer les services Docker Compose
echo "Redémarrage des services Docker Compose"
docker-compose up -d || revert_operation

echo "Transition vers bind mount terminée avec succès"
