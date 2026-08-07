# APK Icon Changer

Cambia el ícono de una app Android (.apk) usando GitHub Actions: decompila, reemplaza el ícono en todas las densidades, recompila, alinea y firma el APK para que quede 100% funcional e instalable.

## Cómo usarlo cada vez

1. Sube tu APK a `input/app.apk` y tu ícono nuevo (PNG cuadrado, idealmente 1024x1024, fondo transparente si quieres adaptive icon) a `input/icon.png`.
2. Ve a la pestaña **Actions** del repo → workflow **"Cambiar ícono del APK"** → **Run workflow**.
3. Ajusta las rutas si usaste otros nombres, y ejecuta.
4. Al terminar, descarga el resultado desde **Artifacts** → `apk-con-nuevo-icono`.

## Importante — para que Android no lo marque como dañado

- El workflow firma el APK automáticamente (genera una keystore propia si no subes una). Un APK sin firmar o mal firmado es justo lo que Android rechaza como "dañado".
- **La firma nueva es distinta a la original.** Esto significa:
  - El APK modificado se instala perfecto como app nueva.
  - Pero **no podrás actualizar** una instalación existente de la app original con este APK (Android exige que las firmas coincidan para actualizar). Tendrías que desinstalar la versión original primero.
  - Si quieres conservar la firma original, puedes subir tu propia keystore a `keystore/release.jks` en el repo (con sus contraseñas) en vez de dejar que el workflow genere una nueva.
- Si el ícono adaptativo (Android 8+) usa una capa vectorial (`ic_launcher_foreground.xml`) en vez de PNG, el script te avisará: eso requiere edición manual del XML, no se sobreescribe automáticamente.
- Respeta los derechos de autor/licencia de la app que modifiques; esto es para tus propios APKs o apps donde tengas permiso para hacerlo.

## Estructura
```
.github/workflows/change-icon.yml   # el pipeline
scripts/replace_icon.sh             # genera los tamaños e inyecta el ícono
input/                              # aquí van tu APK y tu ícono
keystore/                           # opcional: tu propia keystore
tools/convertir_a_icon.bat          # herramienta opcional (ver abajo)
```

## Herramienta opcional: preparar el ícono en Windows (arrastrar y soltar)

`tools/convertir_a_icon.bat` convierte cualquier imagen a PNG **1024x1024 con fondo transparente**, listo para usar como `input/icon.png` en el workflow.

**Cómo usarlo:**
1. Descarga/copia el archivo `tools/convertir_a_icon.bat` a tu PC (Windows).
2. Arrastra tu imagen (jpg, png, etc.) y suéltala **encima del archivo `.bat`**.
3. Si no tienes **ImageMagick** instalado, el script lo detecta y lo instala solo (usando `winget`) y luego continúa automáticamente.
4. Se genera `icon.png` en la misma carpeta de la imagen original.
5. La ventana se cierra sola al terminar.

Puedes soltar varias imágenes a la vez; cada una generará su propio `icon.png` en su carpeta correspondiente (si hay más de una imagen en la misma carpeta, la última procesada sobreescribe el `icon.png`).

Requisitos: Windows 10/11 con `winget` disponible (viene incluido por defecto). Si tu equipo no tiene `winget`, el script te avisa y te da el link de descarga manual de ImageMagick.
