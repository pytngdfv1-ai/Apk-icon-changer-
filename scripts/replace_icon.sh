#!/usr/bin/env bash
# Uso: replace_icon.sh <icono.png> <carpeta_decodificada_del_apk>
set -e

ICON="$1"
DECODED="$2"

if [ -z "$ICON" ] || [ -z "$DECODED" ]; then
  echo "Uso: replace_icon.sh <icono.png> <carpeta_decoded>"
  exit 1
fi

declare -A SIZES=(
  [mipmap-mdpi]=48
  [mipmap-hdpi]=72
  [mipmap-xhdpi]=96
  [mipmap-xxhdpi]=144
  [mipmap-xxxhdpi]=192
)

declare -A FG_SIZES=(
  [mipmap-mdpi]=108
  [mipmap-hdpi]=162
  [mipmap-xhdpi]=216
  [mipmap-xxhdpi]=324
  [mipmap-xxxhdpi]=432
)

TMP=$(mktemp -d)

for density in "${!SIZES[@]}"; do
  size=${SIZES[$density]}
  fgsize=${FG_SIZES[$density]}
  dir="$DECODED/res/$density"
  mkdir -p "$dir"

  # --- Icono clasico (Android < 8, y fallback general) ---
  convert "$ICON" -resize "${size}x${size}" -background none -gravity center \
    -extent "${size}x${size}" "$dir/ic_launcher.png"
  convert "$ICON" -resize "${size}x${size}" -background none -gravity center \
    -extent "${size}x${size}" "$dir/ic_launcher_round.png"
  echo "Escrito: $dir/ic_launcher.png / ic_launcher_round.png"

  # --- Capa "foreground" del icono adaptativo (Android 8+) ---
  # Se reduce al ~66% del lienzo (zona segura) para que no se recorte con la mascara del launcher.
  fg_inner=$(( fgsize * 66 / 100 ))
  convert "$ICON" -resize "${fg_inner}x${fg_inner}" -background none -gravity center \
    -extent "${fgsize}x${fgsize}" "$dir/ic_launcher_foreground.png"
  echo "Escrito (foreground adaptive): $dir/ic_launcher_foreground.png"
done

# --- Reescribe la definicion del icono adaptativo para que apunte a nuestro PNG ---
# en vez del vector original (drawable/ic_launcher_foreground.xml), que es lo que
# realmente decide que se ve en Android 8+.
ADAPTIVE_XML='<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/white"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'

FOUND_ADAPTIVE=0
while IFS= read -r xmlfile; do
  FOUND_ADAPTIVE=1
  echo "$ADAPTIVE_XML" > "$xmlfile"
  echo "Reescrito icono adaptativo: $xmlfile"
done < <(find "$DECODED/res" -type f \( -iname "ic_launcher.xml" -o -iname "ic_launcher_round.xml" \) -path "*anydpi*")

if [ "$FOUND_ADAPTIVE" -eq 0 ]; then
  echo "No se encontro definicion de icono adaptativo (mipmap-anydpi*/ic_launcher.xml); la app probablemente solo usa los PNG clasicos, ya reemplazados arriba."
fi

rm -rf "$TMP"
echo "Reemplazo de icono completado."
