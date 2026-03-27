#!/system/bin/sh
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=false
LATESTARTSERVICE=true

print_modname() {
  ui_print "************************************"
  ui_print "  ███████╗██╗   ██╗ ██████╗██╗  ██╗ "
  ui_print "  ██╔════╝██║   ██║██╔════╝██║ ██╔╝ "
  ui_print "  █████╗  ██║   ██║██║     █████╔╝  "
  ui_print "  ██╔══╝  ██║   ██║██║     ██╔═██╗  "
  ui_print "  ██║     ╚██████╔╝╚██████╗██║  ██╗ "
  ui_print "  ╚═╝      ╚═════╝  ╚═════╝╚═╝  ╚═╝ "
  ui_print ""
  ui_print "  ██╗   ██╗ ██████╗ ██╗   ██╗      "
  ui_print "  ╚██╗ ██╔╝██╔═══██╗██║   ██║      "
  ui_print "   ╚████╔╝ ██║   ██║██║   ██║      "
  ui_print "    ╚██╔╝  ██║   ██║██║   ██║      "
  ui_print "     ██║   ╚██████╔╝╚██████╔╝      "
  ui_print "     ╚═╝    ╚═════╝  ╚═════╝       "
  ui_print "************************************"
  ui_print "CODM Downscaling Beta"
  ui_print "by zynn"
  ui_print "ASCII loaded: FUCK YOU"
}

on_install() {
  ui_print "Installing CODM Downscale WebUI..."
  mkdir -p "$MODPATH/webroot/assets"
  mkdir -p /data/adb/codmwebui
  ui_print "Installed. Open the module WebUI in your root manager."
}

set_permissions() {
  set_perm_recursive "$MODPATH" 0 0 0755 0644
  set_perm "$MODPATH/customize.sh" 0 0 0755
  set_perm "$MODPATH/service.sh" 0 0 0755
  set_perm "$MODPATH/apply.sh" 0 0 0755
  set_perm "$MODPATH/reset.sh" 0 0 0755
  set_perm "$MODPATH/common.sh" 0 0 0755
}
