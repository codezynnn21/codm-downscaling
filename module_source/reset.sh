#!/system/bin/sh
MODDIR="${0%/*}"
. "$MODDIR/common.sh"

for pkg in $PKG_LIST; do
  if is_installed "$pkg"; then
    reset_package "$pkg"
  fi
done
run_cmd settings delete system peak_refresh_rate
run_cmd settings delete system min_refresh_rate
run_cmd dumpsys deviceidle enable
run_cmd settings delete global device_idle_constants
save_state ""
log "manual reset finished"
exit 0
