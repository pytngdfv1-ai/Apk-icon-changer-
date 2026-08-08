@echo off
setlocal enabledelayedexpansion
title Convertir a icon.png (1024x1024, fondo transparente)

:: ============================================================
:: Uso: arrastra una o varias imagenes sobre este archivo .bat
:: Genera "icon.png" (1024x1024, fondo transparente) en la
:: misma carpeta de cada imagen de origen.
:: ============================================================

if "%~1"=="" (
    echo Arrastra una o mas imagenes sobre este archivo .bat y sueltalas aqui.
    echo.
    pause
    exit /b 1
)

:: --- Verifica si ImageMagick esta disponible ---
where magick >nul 2>nul
if errorlevel 1 (
    echo ImageMagick no esta instalado. Instalando automaticamente, espera...
    where winget >nul 2>nul
    if errorlevel 1 (
        echo.
        echo No se encontro "winget" en este equipo, no se puede instalar automaticamente.
        echo Instala ImageMagick manualmente desde https://imagemagick.org/script/download.php#windows
        echo y vuelve a ejecutar este script.
        pause
        exit /b 1
    )

    winget install --id ImageMagick.ImageMagick -e --silent --accept-source-agreements --accept-package-agreements
    if errorlevel 1 (
        echo.
        echo La instalacion automatica fallo. Instala ImageMagick manualmente desde:
        echo https://imagemagick.org/script/download.php#windows
        pause
        exit /b 1
    )

    :: Refresca el PATH de esta sesion con los valores actuales del sistema/usuario
    for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set "SYS_PATH=%%B"
    for /f "skip=2 tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USER_PATH=%%B"
    set "PATH=%SYS_PATH%;%USER_PATH%;%PATH%"

    where magick >nul 2>nul
    if errorlevel 1 (
        echo.
        echo ImageMagick se instalo pero no se detecta en esta ventana.
        echo Cierra esta ventana, abre una nueva y vuelve a arrastrar las imagenes.
        pause
        exit /b 1
    )
)

:: --- Procesa cada imagen soltada sobre el script ---
:procesar
if "%~1"=="" goto fin

set "ORIGEN=%~1"
set "CARPETA=%~dp1"
set "SALIDA=%CARPETA%icon.png"

echo Convirtiendo: %~nx1
magick "%ORIGEN%" -resize 1024x1024 -background none -gravity center -extent 1024x1024 "%SALIDA%"

if errorlevel 1 (
    echo   Error al convertir "%~nx1"
) else (
    echo   OK -^> "%SALIDA%"
)

shift
goto procesar

:fin
echo.
echo Listo. Esta ventana se cerrara en 3 segundos...
timeout /t 3 >nul
exit /b 0
