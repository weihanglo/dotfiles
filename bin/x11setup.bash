set_natural_scroll () {
  ids=$(xinput list | grep -iE 'touchpad|mouse' | cut -d'=' -f2 | cut -d'[' -f1)
  pattern="Natural Scrolling Enabled ("
  for id in $ids; do
    prop_id=$(xinput list-props $id | grep -i "$pattern" | cut -d'(' -f2 | cut -d')' -f1)
    echo "Set Natural Scrolling $prop_id on $id"
    xinput --set-prop $id $prop_id 1
  done
}

# Speedup keyboard repeatedly input
xset r rate 300 40
# Persistent keys bindings (mainly from ~/.xbindkeysrc)
xbindkeys
# Map CapsLock to ESC
setxkbmap -option caps:escape
# Set mouse/touchpad to natural scrolling
set_natural_scroll
