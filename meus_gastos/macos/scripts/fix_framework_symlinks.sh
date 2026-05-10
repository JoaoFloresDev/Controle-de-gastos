#!/bin/bash
# Apple's macOS validator (ITMS-90291) demands that frameworks have:
#   Versions/Current -> A   (literal target)
#   Resources -> Versions/Current/Resources   (literal target)
#
# Some packages (e.g. objective_c via Flutter native-assets) ship the
# Resources symlink pointing at "Versions/A/Resources" instead, which
# resolves to the same place but Apple's string match rejects it.
#
# This script walks every framework in the .app bundle, replaces any
# misaligned symlink with the canonical target, then re-signs the
# framework so the bundle signature stays valid.

set -e

FW_DIR="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
[ -d "$FW_DIR" ] || exit 0

SIGN_ID="${EXPANDED_CODE_SIGN_IDENTITY:-${CODE_SIGN_IDENTITY:--}}"
echo "fix_framework_symlinks: using signing identity: ${SIGN_ID:0:20}..."
if [ "$SIGN_ID" = "-" ]; then
  echo "warning: signing identity not resolved (would do ad-hoc) — re-sign may invalidate distribution validation"
fi

# Iterate using find so paths with spaces ("My expenses.app") work.
find "$FW_DIR" -maxdepth 1 -name "*.framework" -type d -print0 |
while IFS= read -r -d '' fw; do
  fwname="$(basename "$fw")"
  changed=0

  # Versions/Current must symlink to "A".
  if [ -d "$fw/Versions/A" ]; then
    cur_target=""
    [ -L "$fw/Versions/Current" ] && cur_target="$(readlink "$fw/Versions/Current")"
    if [ "$cur_target" != "A" ]; then
      rm -rf "$fw/Versions/Current"
      (cd "$fw/Versions" && ln -s A Current)
      echo "Fixed Versions/Current symlink in $fwname"
      changed=1
    fi
  fi

  # Top-level Resources must symlink to "Versions/Current/Resources".
  if [ -d "$fw/Versions/A/Resources" ]; then
    res_target=""
    [ -L "$fw/Resources" ] && res_target="$(readlink "$fw/Resources")"
    if [ "$res_target" != "Versions/Current/Resources" ]; then
      rm -rf "$fw/Resources"
      (cd "$fw" && ln -s "Versions/Current/Resources" Resources)
      echo "Fixed Resources symlink in $fwname"
      changed=1
    fi
  fi

  if [ "$changed" = "1" ]; then
    echo "Re-signing $fwname"
    codesign --force --sign "$SIGN_ID" "$fw" || \
      echo "warning: codesign failed for $fwname"
  fi
done

# Diagnostic: log objective_c.framework structure for future debugging.
if [ -d "$FW_DIR/objective_c.framework" ]; then
  echo "--- objective_c.framework after fix ---"
  ls -la "$FW_DIR/objective_c.framework" | head -20
fi
