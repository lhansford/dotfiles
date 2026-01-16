#!/usr/bin/env zsh

if [ -e ~/.env ]
then
  export $(cat .env | xargs)
fi

MEALIE_URL="http://localhost:9925"
BACKUP_DRIVE="/mnt/backup"
MEALIE_BACKUP_DIR="$BACKUP_DRIVE/mealie"
MUSIC_DIR="/mnt/exthd/Music"
IMMICH_LIBRARY_DIR="/mnt/exthd/Images/library"
PLEX_CONFIG_DIR="/home/luke/plex/config"

function backup_mealie() {
  backup_response=$(curl -s -X POST "$MEALIE_URL/api/admin/backups" -H "Authorization: Bearer $MEALIE_API_TOKEN" -H "Content-Type: application/json")

  error=$(echo $backup_response | grep -o '"error":[^,}]*' | cut -d':' -f2)

  if [ "$error" = "true" ]; then
    echo $backup_response
    echo "Failed to create Mealie backup"
  else
    # Get list of backups and download the most recent one
    backups=$(curl -s -X GET "$MEALIE_URL/api/admin/backups" -H "Authorization: Bearer $MEALIE_API_TOKEN")
    backup_filename=$(echo $backups | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$backup_filename" ]; then
      curl -s -X GET "$MEALIE_URL/api/admin/backups/$backup_filename" \
        -H "Authorization: Bearer $MEALIE_API_TOKEN" \
        -o "$MEALIE_BACKUP_DIR/$backup_filename"

      echo "Downloaded backup to $MEALIE_BACKUP_DIR/$backup_filename"
    else
      echo "Failed to retrieve backup filename"
    fi
  fi
}

function backup_immich() {
  restic -r "$BACKUP_DRIVE/images" --verbose backup --ignore-inode $IMMICH_LIBRARY_DIR
  echo "Backing up Immich database..."
  sudo docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres | gzip > "/mnt/backup/immich/dump.sql.gz"
}

function backup_plex() {
  restic -r "$BACKUP_DRIVE/plex" --verbose backup --ignore-inode $PLEX_CONFIG_DIR
}

function backup_media() {
  restic -r "$BACKUP_DRIVE/music" --verbose backup --ignore-inode $MUSIC_DIR
}

function restic_backups() {
  password=$(gum input --password)
  export RESTIC_PASSWORD=$password
  backup_media
  backup_plex
  backup_immich
  export RESTIC_PASSWORD=""
}

if ! command -v restic >/dev/null 2>&1; then
  echo "restic is not installed. Visit https://restic.readthedocs.io/en/stable/020_installation.html for installation instructions."
  return 1
fi

if [ -z "$MEALIE_API_TOKEN" ]; then
  echo "MEALIE_API_TOKEN not set. See obsidian://open?vault=Personal&file=P01%2F70-79%20Projects%2F71%20Home%20server%2Fbackups for details."
  return 1
fi

restic_backups
backup_mealie
