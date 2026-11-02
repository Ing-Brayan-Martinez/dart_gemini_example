---
name: flutter-testing-apps
description: Implementa tests unitarios, de widget e integración en French Gold ERP. Usar para asegurar calidad y evitar regresiones mediante pruebas automatizadas.
---

# Pruebas en aplicaciones Flutter (French Gold ERP)

## Contenido

- [Estrategias de prueba](#estrategias-de-prueba)
- [Pruebas por capa](#pruebas-por-capa)
- [Flujo de implementación](#flujo-de-implementación)
- [Alineación con el proyecto](#alineación-con-el-proyecto)

## Estrategias de prueba

Repartir la suite de pruebas en tres categorías:

### Tests unitarios

- Verifican la lógica de una función, método o clase en distintas condiciones.
- Hacer mock de dependencias externas (repositorios, servicios). No usar I/O de disco ni renderizado real ni acciones de usuario fuera del proceso de test.
- Ejecutar con el paquete `test` o `flutter_test`.

### Tests de widget

- Comprueban que un widget se vea y reaccione como se espera.
- Usar `WidgetTester`, `Finder` y matchers (`findsOneWidget`, etc.). Proporcionar el contexto de ciclo de vida adecuado.
- Probar vistas e interacciones sin levantar la app completa. Inyectar controllers y repositorios falsos cuando la pantalla dependa de GetX.

### Tests de integración

- Validan flujos completos y la interacción entre piezas de la app. Útiles para rutas, inyección de dependencias y flujos críticos.
- Usar el paquete `integration_test`. Ejecutar en dispositivo físico, emulador o Firebase Test Lab.

## Pruebas por capa

- **Controllers (equivalente a ViewModels):** Tests unitarios para cada controller. Inyectar repositorios o use cases falsos (`FakeXxxRepository`). Comprobar que ante éxito se actualicen listas/estado y que ante error se actualice `error` y no se pierda la excepción.
- **Repositorios y servicios:** Tests unitarios con mocks de la fuente de datos (HTTP, base de datos). Verificar que las transformaciones a modelos de dominio sean correctas.
- **Vistas (pantallas):** Tests de widget. Inyectar en el árbol un controller falso o mockeado (o usar `Get.put(controllerFalso)` antes de bombear el widget). Aislar la UI de la lógica real.
- **Fakes frente a mocks:** Preferir implementaciones `Fake` de repositorios (p. ej. `FakeCurrencyRepository`) cuando sea posible, para tener entradas y salidas bien definidas.

## Flujo de implementación

- [ ] Crear implementaciones `Fake` para los repositorios/servicios que use la funcionalidad.
- [ ] Escribir tests unitarios del repositorio (mockeando el servicio o la BD).
- [ ] Escribir tests unitarios del controller (inyectando el Fake del repositorio).
- [ ] Escribir tests de widget de la pantalla (inyectando controller o repositorio falso).
- [ ] Escribir al menos un test de integración para el flujo crítico de la funcionalidad.
- [ ] Ejecutar `flutter test` y revisar cobertura; añadir casos límite si hace falta.

## Alineación con el proyecto

- **GetX:** En tests de widget, registrar el controller con `Get.put(MiController(repositoryFalso))` antes de `pumpWidget`, o pasar el controller al widget si la pantalla lo admite. Limpiar con `Get.reset()` entre tests si es necesario.
- **Nomenclatura:** Controllers terminan en `Controller`, repositorios en `Repository`/`RepositoryImpl`. Los fakes pueden llamarse `FakeXxxRepository`.
- **Rutas:** En integración, usar las rutas reales del router del proyecto si se prueba navegación; en unit/widget tests evitar navegación real y mockear o usar rutas de test.

## Referencias

- [.cursor/rules/dart-architecture-patterns.mdc](.cursor/rules/dart-architecture-patterns.mdc)
- Skill **flutter-getx-screen-binding** (estructura de controller y binding)
- Skill **flutter-architecting-apps** (capas y dependencias)
