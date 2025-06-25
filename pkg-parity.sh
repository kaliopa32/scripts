
#!/usr/bin/env bash
set -euo pipefail

# Default output files
EXPLICIT_FILE="${2:-$HOME/parity/arch/pkglist-explicit.txt}"
AUR_FILE="${3:-$HOME/parity/arch/aur-packages.txt}"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [explicit-file] [aur-file]

Commands:
  export    Dump lists of:
              • explicit packages → \$EXPLICIT_FILE
              • foreign (AUR)    → \$AUR_FILE
  install   Reinstall from those lists:
              • pacman for explicit
              • yay  for AUR

Examples:
  $(basename "$0") export
  $(basename "$0") install ~/parity/arch/my-explicit.txt ~/parity/arch/my-aur.txt
EOF
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

ensure_dir() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
}

case "$1" in
  export)
    ensure_dir "$EXPLICIT_FILE"
    ensure_dir "$AUR_FILE"

    echo "Exporting explicit → $EXPLICIT_FILE"
    pacman -Qqe > "$EXPLICIT_FILE"
    echo "Exporting AUR     → $AUR_FILE"
    pacman -Qqm > "$AUR_FILE"
    echo "Done."
    ;;

  install)
    echo "Reinstalling explicit packages from $EXPLICIT_FILE"
    sudo pacman -S --needed - < "$EXPLICIT_FILE"
    echo "Reinstalling AUR packages from    $AUR_FILE"
    yay -S --needed - < "$AUR_FILE"
    echo "Done."
    ;;

  *)
    usage
    ;;
esac



















































