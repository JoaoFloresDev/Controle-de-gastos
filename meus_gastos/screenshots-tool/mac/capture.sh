#!/bin/zsh
# Captures the app window across the 5 tabs, with no mouse or keyboard
# injection: MG_SHOT_MODE makes the app walk the tabs by itself, and we shoot
# the window often enough to land on every one of them.
#
#   ./capture.sh <locale: pt|en> <out dir> <path to My expenses.app>
set -e
HERE="${0:A:h}"
LOC="$1"; OUT="$2"; APP="$3"
INTERVAL="${MG_SHOT_INTERVAL:-4}"
SWIFT="/Applications/Xcode 2.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"
rm -rf "$OUT"; mkdir -p "$OUT"

if [ "$LOC" = "en" ]; then
  MG_SHOT_MODE=1 MG_SHOT_INTERVAL=$INTERVAL "$APP/Contents/MacOS/My expenses" \
    -AppleLanguages '(en-US)' > "$OUT/run.log" 2>&1 &
else
  MG_SHOT_MODE=1 MG_SHOT_INTERVAL=$INTERVAL "$APP/Contents/MacOS/My expenses" \
    > "$OUT/run.log" 2>&1 &
fi

WIN=""
for i in $(seq 1 40); do
  WIN=$("$SWIFT" "$HERE/winid.swift" 2>/dev/null | awk 'tolower($0) ~ /despesas|my expenses/ {print $1; exit}')
  [ -n "$WIN" ] && break
  /bin/sleep 1
done
[ -z "$WIN" ] && { echo "sem janela"; exit 1; }
echo "window=$WIN"

# Flutter only renders while the window is visible, so shoot densely and pick
# the distinct frames afterwards instead of trusting the clock.
/bin/sleep 3
for i in $(seq 0 44); do
  screencapture -x -o -l "$WIN" "$OUT/raw_$(printf %02d $i).png" 2>/dev/null
  /bin/sleep 0.6
done
pkill -f "My expenses.app/Contents/MacOS" 2>/dev/null || true
echo "capturados: $(ls "$OUT"/raw_*.png | wc -l | tr -d ' ')"
