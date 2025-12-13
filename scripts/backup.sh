#!/usr/bin/env zsh

function backup_mealie() {
  backup_response=$(curl -s -X POST "$MEALIE_URL/api/admin/backups" -H "Authorization: Bearer $MEALIE_API_TOKEN" -H "Content-Type: application/json")
  backup_filename=$(echo $backup_response | grep -oP '"fileName":"\K[^"]+')

  if [ -z "$backup_filename" ]; then
    echo "Failed to create Mealie backup"
  else
    curl -X GET "$MEALIE_URL/api/admin/backups/$backup_filename" \
      -H "Authorization: Bearer $MEALIE_API_TOKEN" \
      -o "$MEALIE_BACKUP_DIR/$backup_filename"

    echo "Downloaded backup to /$MEALIE_BACKUP_DIR/$backup_filename"
  fi
}

if ! command -v restic >/dev/null 2>&1; then
  echo "restic is not installed. Visit https://restic.readthedocs.io/en/stable/020_installation.html for installation instructions."
  return 1
fi

if [ -z "$MEALIE_API_TOKEN" ]; then
  echo "MEALIE_API_TOKEN not set. See obsidian://open?vault=Personal&file=P01%2F70-79%20Projects%2F71%20Home%20server%2Fbackups for details."
  return 1
fi

MEALIE_URL="http://localhost:9000"
BACKUP_DRIVE="/mnt/backup"
MEALIE_BACKUP_DIR="$BACKUP_DRIVE/mealie"
MUSIC_DIR="/mnt/exthd/Music"

# password=$(gum input --password)
# export RESTIC_PASSWORD=$password
# # TODO:
# # restic -r "$BACKUP_DRIVE/music" --verbose backup --ignore-inode $MUSIC_DIR
# export RESTIC_PASSWORD=""
backup_mealie
# gum spin --spinner dot --title "Backing up Mealie..." -- backup_mealie
