#!/system/bin/sh
CFG_DIR="/data/adb/codmwebui"
CFG_FILE="$CFG_DIR/config.json"
LOG_FILE="$CFG_DIR/service.log"
STATE_FILE="$CFG_DIR/state.env"
PKG_LIST="com.activision.callofduty.shooter com.garena.game.codm com.tencent.tmgp.kr.codm"
MODULE_DIR="/data/adb/modules/codmwebui_real"

mkdir -p "$CFG_DIR"

timestamp() {
  date '+%F %T'
}

log() {
  echo "[$(timestamp)] $*" >> "$LOG_FILE"
}

json_get_string() {
  key="$1"
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$CFG_FILE" 2>/dev/null | head -n 1
}

json_get_bool() {
  key="$1"
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\(true\|false\).*/\1/p" "$CFG_FILE" 2>/dev/null | head -n 1
}

normalize_scale() {
  case "$1" in
    0.3x|0.30|0.30x) echo "0.3" ;;
    0.4x|0.40|0.40x) echo "0.4" ;;
    0.5x|0.50|0.50x) echo "0.5" ;;
    0.6x|0.60|0.60x) echo "0.6" ;;
    0.7x|0.70|0.70x) echo "0.7" ;;
    0.75x|0.75) echo "0.75" ;;
    0.8x|0.80|0.80x) echo "0.8" ;;
    0.85x|0.85) echo "0.85" ;;
    0.9x|0.90|0.90x) echo "0.9" ;;
    1.0x|1|1.0|off|Off|OFF|reset|Reset|RESET|"") echo "disable" ;;
    *) echo "disable" ;;
  esac
}

normalize_fps() {
  case "$1" in
    30|45|60|90|120|144) echo "$1" ;;
    *) echo "120" ;;
  esac
}

is_installed() {
  pm path "$1" >/dev/null 2>&1
}

selected_pkg() {
  pkg="$(json_get_string package)"
  if [ -n "$pkg" ] && is_installed "$pkg"; then
    echo "$pkg"
    return 0
  fi
  for pkg in $PKG_LIST; do
    if is_installed "$pkg"; then
      echo "$pkg"
      return 0
    fi
  done
  return 1
}

run_cmd() {
  out="$($@ 2>&1)"
  rc=$?
  log "cmd rc=$rc :: $*"
  [ -n "$out" ] && log "out :: $out"
  return $rc
}

apply_doze() {
  disable_doze="$1"
  if [ "$disable_doze" = "true" ]; then
    run_cmd dumpsys deviceidle disable
    run_cmd settings put global device_idle_constants inactive_to=86400000
  else
    run_cmd dumpsys deviceidle enable
    run_cmd settings delete global device_idle_constants
  fi
}

apply_refresh() {
  fps="$1"
  lock_fps="$2"
  if [ "$lock_fps" = "true" ]; then
    run_cmd settings put system peak_refresh_rate "$fps"
    run_cmd settings put system min_refresh_rate "$fps"
  else
    run_cmd settings delete system peak_refresh_rate
    run_cmd settings delete system min_refresh_rate
  fi
}

apply_package() {
  pkg="$1"
  scale="$2"
  fps="$3"
  if [ "$scale" = "disable" ]; then
    run_cmd cmd game downscale disable "$pkg"
    run_cmd cmd device_config delete game_overlay "$pkg"
    log "reset overlay for $pkg"
  else
    run_cmd cmd game mode performance "$pkg"
    run_cmd cmd game downscale "$scale" "$pkg"
    run_cmd cmd device_config put game_overlay "$pkg" "mode=2,downscaleFactor=$scale,fps=$fps"
    log "applied overlay for $pkg scale=$scale fps=$fps"
  fi
}

reset_package() {
  pkg="$1"
  run_cmd cmd game downscale disable "$pkg"
  run_cmd cmd device_config delete game_overlay "$pkg"
}

get_foreground_pkg() {
  dumpsys window 2>/dev/null | sed -n 's/.*mCurrentFocus.* \([^ ]*\)\/.*$/\1/p' | tail -n 1
}

save_state() {
  last_pkg="$1"
  mkdir -p "$CFG_DIR"
  cat > "$STATE_FILE" <<EOF
LAST_APPLIED_PKG='$last_pkg'
LAST_APPLIED_AT='$(timestamp)'
EOF
}

load_state() {
  LAST_APPLIED_PKG=""
  LAST_APPLIED_AT=""
  [ -f "$STATE_FILE" ] && . "$STATE_FILE"
}

is_codm_pkg() {
  case "$1" in
    com.activision.callofduty.shooter|com.garena.game.codm|com.tencent.tmgp.kr.codm) return 0 ;;
    *) return 1 ;;
  esac
}
