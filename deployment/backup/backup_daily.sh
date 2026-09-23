#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

IMMICH_LIBRARY_DIR=/data/immich/library
DB_BACKUP_DIR=$IMMICH_LIBRARY_DIR/backups
REMOTE_DB_LOCATION=drive-burn3:backup/immich/db
REMOTE_LIBRARY_LOCATION=drive-burn3:backup/immich/library

### DB dumps (Immich's own built-in daily pg_dump job writes these) ###
# Copy first, per Immich's documented backup ordering (DB before filesystem).
rclone copy "$DB_BACKUP_DIR" "$REMOTE_DB_LOCATION"

# Keep only a rolling 7 days on the Drive side, independent of Immich's local retention.
rclone delete --min-age 7d "$REMOTE_DB_LOCATION"

### Asset library ###
# Only the directories that hold real user data; thumbs/encoded-video are regenerable caches,
# backups/ is handled above. rclone copy never deletes from the remote, so this backup survives
# local deletions (accidental or after Immich's trash retention expires).
rclone copy "$IMMICH_LIBRARY_DIR/upload" "$REMOTE_LIBRARY_LOCATION/upload"
rclone copy "$IMMICH_LIBRARY_DIR/library" "$REMOTE_LIBRARY_LOCATION/library"
rclone copy "$IMMICH_LIBRARY_DIR/profile" "$REMOTE_LIBRARY_LOCATION/profile"
