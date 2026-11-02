---
name: flutter-handling-http-and-json
description: Ejecuta peticiones HTTP y maneja serialización JSON en French Gold ERP. Usar al integrar APIs REST o parsear datos estructurados externos.
---

# HTTP y JSON en Flutter (French Gold ERP)

## Contenido

- [Directrices generales](#directrices-generales)
- [Flujo de operaciones HTTP](#flujo-de-operaciones-http)
- [Serialización JSON](#serialización-json)
- [Integración con la arquitectura del proyecto](#integración-con-la-arquitectura-del-proyecto)

## Directrices generales

- **Usar HTTPS:** En producción siempre HTTPS. Para depuración con HTTP, configurar excepciones en la plataforma (p. ej. `network_security_config.xml` en Android).
- **Construir URIs de forma segura:** Usar `Uri.https(authority, path, [queryParameters])` para evitar errores de concatenación y codificación.
- **Validar códigos de estado:** Comprobar `response.statusCode`. Tratar 200 y 201 como éxito; para otros códigos lanzar una excepción clara (no retornar `null` silenciosamente).
- **Parsing pesado en segundo plano:** Si el parseo de JSON tarda más de ~16 ms, usar `compute()` para ejecutarlo en un isolate y no bloquear la UI.
- **Manejo de errores:** En la capa de datos no usar `Get.snackbar`; lanzar excepciones o retornar `Optional`. El controller en presentación capturará el error y mostrará el mensaje al usuario.

## Flujo de operaciones HTTP

- [ ] Añadir el paquete `http` (o el que use el proyecto) en `pubspec.yaml`.
- [ ] Configurar permisos de red (Android: `AndroidManifest.xml`, etc.).
- [ ] Construir el `Uri` de destino.
- [ ] Ejecutar la petición (GET: `http.get(uri)`, POST: `http.post(uri, headers: {...}, body: jsonEncode(data))`, etc.). Header `Content-Type: application/json; charset=UTF-8` en POST/PUT.
- [ ] Validar `statusCode`; si es 200/201, parsear el body con `jsonDecode(response.body)` y mapear al modelo de dominio. Si no, lanzar excepción.

El acceso HTTP debe estar encapsulado en un **servicio** (capa de datos). El controller llama al **repositorio**, que a su vez puede usar un servicio HTTP además de los servicios de base de datos.

## Serialización JSON

- **Modelos del proyecto:** En French Gold ERP los modelos de dominio suelen tener `fromJson(Map<String, dynamic> json)` con claves en **snake_case** cuando el origen es PostgreSQL, y `toJson()` o `toMapSave()`/`toMapUpdate()` con claves en **camelCase** para envío. Para APIs externas, adaptar: si la API devuelve camelCase, usar camelCase en `fromJson`; si devuelve snake_case, usar snake_case.
- **Código generado:** Para modelos complejos o anidados se puede usar `json_serializable` con `@JsonSerializable()` y `part 'modelo.g.dart';`. Ejecutar `dart run build_runner build --delete-conflicting-outputs`.
- **Manual:** Definir `factory Modelo.fromJson(Map<String, dynamic> json)` y `Map<String, dynamic> toJson()` (o métodos equivalentes) con los nombres de clave que use la API o la base de datos.

## Integración con la arquitectura del proyecto

- **Capa de datos:** Crear un servicio (p. ej. `XxxApiService` o dentro del mismo módulo) que haga las peticiones HTTP y devuelva datos crudos o modelos de dominio. No mostrar UI ni usar GetX para mensajes.
- **Repositorio:** Si un flujo combina API y base de datos, el repositorio orquesta: puede leer primero de caché local (SQLite/PostgreSQL) y luego actualizar desde la API, o escribir primero en local y luego sincronizar. Ver **flutter-working-with-databases** y **flutter-caching-data**.
- **Controller:** Llama al repositorio; en `try/catch` actualiza `isLoading` y `error` y usa `Get.snackbar` para informar al usuario. Ver [.cursor/rules/dart-error-handling.mdc](.cursor/rules/dart-error-handling.mdc).

## Referencias

- [.cursor/rules/dart-architecture-patterns.mdc](.cursor/rules/dart-architecture-patterns.mdc)
- Skill **flutter-working-with-databases**
- Skill **flutter-postgresql-dart-mapping** (convenciones de mapeo)
