#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# brew-parity.sh — count, export, or install your Homebrew formulae & casks
#
# Updated version of my brewscripts for maintaining package parity, all in one!
#
# -----------------------------------------------------------------------------

# Default paths (override by passing custom files as arguments)
FORMULAS_FILE="${2:-$HOME/dotfiles/brew/brew_packages.txt}"
CASKS_FILE   "${3:-$HOME/dotfiles/brew/brew_casks.txt}"

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [formulas-file] [casks-file]

Commands:
  count     Display how many formulae and casks you have installed.
  export    Dump current lists of:
              • formulae → \$FORMULAS_FILE
              • casks    → \$CASKS_FILE
  install   Reinstall from those lists:
              • brew install      → formulae
              • brew install --cask → casks

Examples:
  $(basename "$0") count
  $(basename "$0") export
  $(basename "$0") install ~/my-formulas.txt ~/my-casks.txt
EOF
  exit 1
}

# must have at least one arg
if [ $# -lt 1 ]; then
  usage
fi

case "$1" in

  count)
    # count formulae
    fmt_count=$(brew list --formula | wc -l | xargs)
    # count casks
    cask_count=$(brew list --cask   | wc -l | xargs)
    echo "Brew has found: ${fmt_count} formulae and ${cask_count} casks."
    ;;

  export)
    echo "Exporting formulae → $FORMULAS_FILE"
    brew list --formula > "$FORMULAS_FILE"
    echo "Exporting casks    → $CASKS_FILE"
    brew list --cask   > "$CASKS_FILE"
    echo "Done."
    ;;

  install)
    echo "Installing formulae from $FORMULAS_FILE"
    xargs brew install       < "$FORMULAS_FILE"
    echo "Installing casks    from $CASKS_FILE"
    xargs brew install --cask < "$CASKS_FILE"
    echo "Done."
    ;;

  *)
    usage
    ;;
esac
