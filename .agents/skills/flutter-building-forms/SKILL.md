---
name: flutter-building-forms
description: Construye formularios Flutter con validación y manejo de entrada de usuario en French Gold ERP. Usar al crear pantallas de login, formularios de alta/edición o cualquier entrada multi-campo.
---

# Formularios con validación (French Gold ERP)

## Contenido

- [Arquitectura del formulario](#arquitectura-del-formulario)
- [Validación de campos](#validación-de-campos)
- [Flujo de implementación](#flujo-de-implementación)
- [Integración con el proyecto](#integración-con-el-proyecto)

## Arquitectura del formulario

Usar el widget `Form` para agrupar y validar varios campos.

- **StatefulWidget:** Alojar el `Form` dentro de un `StatefulWidget`.
- **GlobalKey persistente:** Crear `final _formKey = GlobalKey<FormState>();` una sola vez en la clase `State`. No generar la key dentro de `build` (resulta costoso y pierde el estado del formulario en cada rebuild).
- **Asignar la key:** Pasar `_formKey` a la propiedad `key` del `Form`.

## Validación de campos

Usar `TextFormField` (o los widgets reutilizables del proyecto) con soporte de validación.

- **Validator:** Proporcionar un callback `validator` a cada campo.
- **Mensaje de error:** Si el valor es inválido, retornar un `String` con el mensaje (en español). El `Form` mostrará el texto bajo el campo.
- **Válido:** Retornar `null` cuando el valor sea correcto.

En French Gold ERP se usan widgets como `CustomTextField`, `CustomPasswordField`, `CustomDropdown` en `lib/presentation/widgets/`. Reutilizarlos y aplicar el mismo criterio de validación.

## Flujo de implementación

- [ ] 1. Crear un `StatefulWidget` y su clase `State`.
- [ ] 2. Declarar `final _formKey = GlobalKey<FormState>();` en el `State`.
- [ ] 3. Retornar un `Form` en `build` con `key: _formKey`.
- [ ] 4. Añadir campos (`TextFormField` o widgets custom) como hijos del `Form`.
- [ ] 5. Implementar `validator` en cada campo (retornar `String` en error, `null` en éxito). Mensajes claros en español.
- [ ] 6. Añadir botón de envío (p. ej. `CustomButton` o `ElevatedButton`).
- [ ] 7. En el callback del botón: si `_formKey.currentState!.validate()` es `true`, enviar datos (llamar al controller); si no, los errores se muestran automáticamente.

Deshabilitar el botón de envío mientras se procesa (`controller.isLoading`) para evitar doble envío.

## Integración con el proyecto

- **Controller:** El formulario debe obtener el controller con `Get.find<XxxController>()` (inyectado por el binding). El controller actualiza `isLoading` y `error`; la pantalla reacciona con `Obx`.
- **Estados de carga y error:** Mostrar indicador de carga o mensaje de error según las reglas de **french-gold-ui-ux** y [.cursor/rules/dart-error-handling.mdc](.cursor/rules/dart-error-handling.mdc).
- **Tema:** Usar `Theme.of(context)` o `Get.theme` (ColorScheme, TextTheme) en lugar de colores fijos. Ver **flutter-theming-apps** y `lib/presentation/theme/`.

## Referencias

- Widgets reutilizables: [lib/presentation/widgets/](lib/presentation/widgets/)
- UI/UX y estados: skill **french-gold-ui-ux**
- Pantallas y controllers: skill **flutter-getx-screen-binding**
