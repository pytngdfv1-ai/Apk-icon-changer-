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

  # Genera versión cuadrada normal y redonda (mismo PNG, Android la recorta con la máscara del dispositivo)
  convert "$ICON" -resize "${size}x${size}" "$TMP/ic_launcher_${density}.png"

  if [ -d "$dir" ]; then
    for f in ic_launcher.png ic_launcher_round.png; do
      if [ -f "$dir/$f" ]; then
        cp "$TMP/ic_launcher_${density}.png" "$dir/$f"
        echo "Reemplazado: $dir/$f"
      fi
    done

    # Adaptive icon: capa de foreground (si existe)
    if [ -f "$dir/ic_launcher_foreground.png" ]; then
      convert "$ICON" -resize "${fgsize}x${fgsize}" -background none -gravity center \
        -extent "${fgsize}x${fgsize}" "$dir/ic_launcher_foreground.png"
      echo "Reemplazado (foreground adaptive): $dir/ic_launcher_foreground.png"
    fi
  fi
done

# Si el ícono adaptativo usa capas vectoriales XML (ic_launcher_foreground.xml),
# no se puede reemplazar con un PNG automáticamente: se avisa para revisión manual.
if find "$DECODED/res" -iname "ic_launcher_foreground.xml" | grep -q .; then
  echo "AVISO: se detectó un ic_launcher_foreground.xml (vector). Revisa manualmente esa capa; el reemplazo automático solo cubre PNG."
fi

rm -rf "$TMP"
echo "Reemplazo de ícono completado."
