---
name: flutter-handling-concurrency
description: Ejecuta tareas largas en isolates en segundo plano para mantener la UI fluida en French Gold ERP. Usar en cómputos pesados o parseo de grandes conjuntos de datos.
---

# Concurrencia y isolates en Dart

## Contenido

- [Conceptos](#conceptos)
- [Cuándo usar async frente a isolates](#cuándo-usar-async-frente-a-isolates)
- [Flujos de trabajo](#flujos-de-trabajo)

## Conceptos

Dart usa un modelo de un solo hilo con Event Loop. Por defecto todo el código de la app Flutter corre en el Main Isolate.

- **Operaciones asíncronas (`async`/`await`):** Para I/O no bloqueante (red, archivos, base de datos). El Event Loop sigue procesando mientras se espera el `Future`.
- **Isolates:** “Hilos” ligeros con memoria aislada; se comunican solo por paso de mensajes.
- **Main Isolate:** Donde se pinta la UI y se manejan eventos. Bloquearlo provoca jank.
- **Worker Isolate:** Isolate creado para descargar tareas que consumen CPU (p. ej. decodificar JSON muy grande) y no bloquear el Main Isolate.

## Cuándo usar async frente a isolates

- **Tarea ligada a I/O** (HTTP, lectura de BD): usar **`async`/`await`** en el Main Isolate.
- **Tarea ligada a CPU pero rápida (< ~16 ms):** **`async`/`await`** en el Main Isolate.
- **Tarea ligada a CPU, costosa y puntual** (p. ej. parsear un JSON enorme): usar **`Isolate.run()`**.
- **Tarea continua o repetida en segundo plano con varios mensajes:** usar **`Isolate.spawn()`** con `ReceivePort` y `SendPort`.

En French Gold ERP las llamadas a repositorios (PostgreSQL, SQLite3, HTTP) son async; el controller usa `try/catch/finally` y no debe bloquear el Main Isolate. Si un parseo de JSON es muy pesado, moverlo a `compute()` (que usa un isolate) o `Isolate.run()`.

## Flujos de trabajo

### UI asíncrona estándar

- Marcar la función de obtención de datos con `async` y retornar `Future<T>`.
- Usar `await` en las operaciones.
- En la UI: usar `FutureBuilder`/`StreamBuilder` o, en el proyecto, **GetX**: el controller expone `isLoading` y `error`; la pantalla usa `Obx` y muestra indicador de carga o error. No es necesario `FutureBuilder` si el controller ya gestiona los estados.

### Cómputo pesado puntual

- Crear una función de nivel superior o estática que reciba los datos (p. ej. el body de la respuesta) y devuelva el objeto parseado.
- Llamar a esa función con `compute(función, argumento)` para ejecutarla en un isolate. Ejemplo: `compute(parsePhotos, response.body)`.

### Isolate de larga duración

- Usar `Isolate.spawn()` pasando una función de entrada y un `SendPort` para enviar mensajes al Main Isolate.
- En el Main Isolate crear un `ReceivePort`, pasar su `sendPort` al isolate y escuchar mensajes.

## Referencias

- [Documentación Dart: Concurrency](https://dart.dev/language/concurrency)
- Skill **flutter-handling-http-and-json** (parseo en segundo plano con `compute`)
- [.cursor/rules/dart-error-handling.mdc](.cursor/rules/dart-error-handling.mdc)
