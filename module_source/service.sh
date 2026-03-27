#!/system/bin/sh
MODDIR="${0%/*}"
. "$MODDIR/common.sh"

sleep 20
log "service loop start"
last_seen=""
while true; do
  [ -f "$CFG_FILE" ] || {
    sleep 10
    continue
  }

  auto_reapply="$(json_get_bool autoReapply)"
  [ -n "$auto_reapply" ] || auto_reapply="true"

  if [ "$auto_reapply" != "true" ]; then
    sleep 10
    continue
  fi

  fg="$(get_foreground_pkg)"
  if is_codm_pkg "$fg"; then
    if [ "$fg" != "$last_seen" ]; then
      log "detected CODM foreground: $fg"
      "$MODDIR/apply.sh"
      last_seen="$fg"
    fi
  else
    last_seen=""
  fi
  sleep 10
done
