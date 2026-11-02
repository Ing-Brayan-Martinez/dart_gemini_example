---
name: flutter-setting-up-on-windows
description: Configura el entorno Windows para desarrollo Flutter. Usar al preparar una máquina Windows para ejecutar, compilar o desplegar apps Flutter para Windows desktop o Android.
---

# Configuración de Flutter en Windows

## Contenido

- [Requisitos](#requisitos)
- [Instalación del SDK](#instalación-del-sdk)
- [Herramientas e IDE](#herramientas-e-ide)
- [Plataformas destino](#plataformas-destino)
- [Validación](#validación)

## Requisitos

Distinguir entre **Visual Studio** (necesario para compilar C++ en Windows desktop) y **VS Code** (editor recomendado para Dart/Flutter). Ambos pueden estar instalados.

## Instalación del SDK

- [ ] Descargar el Flutter SDK estable para Windows.
- [ ] Extraer a una ruta con permisos de usuario normal (p. ej. `C:\src\flutter`). No instalar en `C:\Program Files\`.
- [ ] Añadir la ruta del directorio `bin` del SDK al `PATH` del sistema o del usuario (Variables de entorno).
- [ ] Abrir una nueva terminal y ejecutar `flutter doctor -v`. Corregir dependencias o rutas que indique.

## Herramientas e IDE

- [ ] Instalar **Visual Studio** (no solo VS Code). Durante la instalación, seleccionar la carga de trabajo **Desktop development with C++** (obligatoria para Windows desktop).
- [ ] Instalar un editor (VS Code, Android Studio o IntelliJ) y las extensiones/plugins oficiales de Flutter y Dart.

## Plataformas destino

- **Windows desktop:** Tener la carga de trabajo C++ de Visual Studio actualizada. Reiniciar el IDE para que detecte el dispositivo Windows.
- **Android:** Instalar Android Studio y el SDK de Android; aceptar licencias. Configurar variables de entorno si se indica (ANDROID_HOME, etc.).

Si hace falta habilitar escritorio Windows: `flutter config --enable-windows-desktop`.

## Validación

- [ ] `flutter doctor -v`: revisar que no queden cruces rojas en las secciones que se vayan a usar (Flutter, Windows, Android, etc.).
- [ ] `flutter devices`: debe aparecer el dispositivo Windows (y Android si está configurado).

## Referencias

- [Documentación Flutter: Windows setup](https://docs.flutter.dev/get-started/install/windows)
