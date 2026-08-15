# Load ble.sh before prompt and history integrations, then attach it in init.bash.
BLESH_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/ble.sh"
if [[ ! -f "$BLESH_PATH" && -f /usr/share/blesh/ble.sh ]]; then
  BLESH_PATH=/usr/share/blesh/ble.sh
fi
if [[ $- == *i* && -f "$BLESH_PATH" ]]; then
  source -- "$BLESH_PATH" --attach=none
fi
unset BLESH_PATH
