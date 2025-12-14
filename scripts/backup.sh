#!/usr/bin/env zsh

if [ -e ~/.env ]
then
  export $(cat .env | xargs)
fi

MEALIE_URL="http://localhost:9925"
BACKUP_DRIVE="/mnt/backup"
MEALIE_BACKUP_DIR="$BACKUP_DRIVE/mealie"
MUSIC_DIR="/mnt/exthd/Music"
PLEX_CONFIG_DIR="~/plex/config"

function backup_mealie() {
  backup_response=$(gum spin --spinner pulse --title "Creating Mealie backup..." -- curl -s -X POST "$MEALIE_URL/api/admin/backups" -H "Authorization: Bearer $MEALIE_API_TOKEN" -H "Content-Type: application/json")

  error=$(echo $backup_response | grep -o '"error":[^,}]*' | cut -d':' -f2)

  if [ "$error" = "true" ]; then
    echo $backup_response
    echo "Failed to create Mealie backup"
  else
    # Get list of backups and download the most recent one
    backups=$(gum spin --spinner pulse --title "Fetching Mealie backups..." -- curl -s -X GET "$MEALIE_URL/api/admin/backups" -H "Authorization: Bearer $MEALIE_API_TOKEN")
    backup_filename=$(echo $backups | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$backup_filename" ]; then
      gum spin --spinner pulse --title "Downloading Mealie backup..." -- curl -s -X GET "$MEALIE_URL/api/admin/backups/$backup_filename" \
        -H "Authorization: Bearer $MEALIE_API_TOKEN" \
        -o "$MEALIE_BACKUP_DIR/$backup_filename"

      echo "Downloaded backup to $MEALIE_BACKUP_DIR/$backup_filename"
    else
      echo "Failed to retrieve backup filename"
    fi
  fi
}

function backup_immich() {
  echo "Immich backup not implemented yet."
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
backup_immich
backup_mealie
