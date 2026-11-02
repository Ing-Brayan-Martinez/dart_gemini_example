---
name: flutter-setting-up-on-macos
description: Configura el entorno macOS para desarrollo Flutter. Usar al preparar una máquina macOS para ejecutar, compilar o desplegar apps Flutter para iOS o macOS.
---

# Configuración del entorno macOS para Flutter

## Contenido

- [Requisitos previos](#requisitos-previos)
- [Herramientas](#herramientas)
- [Configuración](#configuración)
- [Validación](#validación)
- [Problemas frecuentes](#problemas-frecuentes)

## Requisitos previos

- macOS.
- Flutter SDK instalado y añadido al `PATH`.
- Conexión a internet para descargar toolchains y dependencias.

## Herramientas

- **Xcode:** Necesario para compilar apps macOS (e iOS).
- **CocoaPods:** Necesario para dependencias nativas de los plugins Flutter.

## Configuración

- [ ] Instalar Xcode desde la Mac App Store o el portal de Apple Developer.
- [ ] Vincular las command-line tools al Xcode instalado:
  ```bash
  sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
  ```
  Si Xcode está en otra ruta, sustituir `/Applications/Xcode.app`.
- [ ] Aceptar la licencia: `sudo xcodebuild -license`.
- [ ] Instalar CocoaPods: `sudo gem install cocoapods` (o actualizar con `sudo gem update cocoapods`).

## Validación

- [ ] Ejecutar `flutter doctor -v` y revisar la sección Xcode.
- [ ] Corregir cualquier error indicado y repetir hasta que Xcode aparezca correcto.
- [ ] Comprobar dispositivos: `flutter devices`. Debe aparecer al menos un dispositivo con plataforma `macos` (o `ios` si se va a desarrollar para iPhone/iPad).
- [ ] Si no aparece macOS: `flutter config --enable-macos-desktop`.

## Problemas frecuentes

- **Command-Line Tools no encontradas:** Verificar que `xcode-select` apunte al directorio correcto del `.app`.
- **CocoaPods no detectado:** Comprobar que el `gem` de Ruby esté en el `PATH`.
