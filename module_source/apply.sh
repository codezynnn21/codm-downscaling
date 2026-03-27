#!/system/bin/sh
MODDIR="${0%/*}"
. "$MODDIR/common.sh"

[ -f "$CFG_FILE" ] || {
  log "apply requested with no config"
  exit 1
}

scale="$(normalize_scale "$(json_get_string resolution)")"
fps="$(normalize_fps "$(json_get_string fps)")"
disable_doze="$(json_get_bool disableDoze)"
lock_fps="$(json_get_bool lockFps)"
pkg="$(selected_pkg)"

[ -n "$disable_doze" ] || disable_doze="false"
[ -n "$lock_fps" ] || lock_fps="false"

if [ -z "$pkg" ]; then
  log "no CODM package installed or selected"
  exit 2
fi

apply_doze "$disable_doze"
apply_refresh "$fps" "$lock_fps"
apply_package "$pkg" "$scale" "$fps"
save_state "$pkg"
log "apply complete pkg=$pkg scale=$scale fps=$fps"
exit 0
