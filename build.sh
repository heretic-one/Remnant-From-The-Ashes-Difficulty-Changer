#!/usr/bin/env bash
# Builds build/DifficultyChanger.zip. Extract it in the game directory (UE4SS must be installed).
set -euo pipefail
R="$(cd "$(dirname "$0")" && pwd)"
OUT="$R/build"
M="$OUT/stage/Remnant/Binaries/Win64/ue4ss/Mods/DifficultyChanger"

rm -rf "$OUT"
mkdir -p "$M"
cp -r "$R/enabled.txt" "$R/Scripts" "$M/"
(cd "$OUT/stage" && python3 -I -m zipfile -c "$OUT/DifficultyChanger.zip" Remnant)
rm -rf "$OUT/stage"
echo "Built: $OUT/DifficultyChanger.zip"
