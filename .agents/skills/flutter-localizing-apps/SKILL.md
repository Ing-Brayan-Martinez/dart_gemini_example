---
name: flutter-localizing-apps
description: Configura una app Flutter para soportar varios idiomas y regiones. Usar al preparar la aplicación para mercados internacionales o distintos locales (p. ej. español en French Gold ERP).
---

# Localización de aplicaciones Flutter

## Contenido

- [Configuración base](#configuración-base)
- [Recursos ARB](#recursos-arb)
- [Integración en la app](#integración-en-la-app)
- [Formato avanzado](#formato-avanzado)
- [Flujos de trabajo](#flujos-de-trabajo)
- [Problemas frecuentes](#problemas-frecuentes)

## Configuración base

1. Añadir en `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

2. Crear `l10n.yaml` en la raíz:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

## Recursos ARB

Guardar cadenas localizadas en archivos `.arb` dentro de `arb-dir`.

**Plantilla (ej. `lib/l10n/app_en.arb`):**
```json
{
  "helloWorld": "Hello World!",
  "@helloWorld": { "description": "Saludo inicial" }
}
```

**Traducción (ej. `lib/l10n/app_es.arb`):**
```json
{
  "helloWorld": "¡Hola Mundo!"
}
```

## Integración en la app

Configurar el widget raíz (`MaterialApp` o `GetMaterialApp` en French Gold ERP):

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

return GetMaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('es'),
  ],
  // ...
);
```

Uso en la UI: `Text(AppLocalizations.of(context)!.helloWorld)`.

## Formato avanzado

- **Placeholders:** `"hello": "Hola {userName}"` con metadata `placeholders` en la clave `@hello`.
- **Plurales:** `"{count, plural, =0{ninguno} =1{uno} other{{count}}}".
- **Selects (género/enums):** `"{gender, select, male{él} female{ella} other{ellos}}".
- **Fechas y números:** Usar `format` en los placeholders (p. ej. `"type": "DateTime", "format": "yMd"`).

## Flujos de trabajo

### Añadir un nuevo idioma

- [ ] Crear el archivo `.arb` (ej. `app_fr.arb`) y traducir todas las claves de la plantilla.
- [ ] Añadir el `Locale` a `supportedLocales`.
- [ ] Ejecutar `flutter gen-l10n` y corregir errores de sintaxis.
- [ ] En iOS: configurar Localizations en Xcode (Info → Localizations).

## Problemas frecuentes

- **No MaterialLocalizations found:** Asegurar que el widget sea descendiente de `MaterialApp`/`GetMaterialApp`. En tests o árboles aislados, envolver en `Localizations` con los delegates adecuados.
- **Idiomas con varios scripts:** Usar `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN')` para evitar variantes inesperadas.

## Referencias

- [Documentación Flutter: Internationalizing Flutter apps](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
