---
name: french-gold-implementing-reactive-forms
description: Guía de diseño de UI/UX y construcción de formularios reactivos con Signals en French Gold ERP. Incluye temas Material 3, widgets reutilizables, patrones de carga, manejo de errores y validación en tiempo real. Usar al diseñar o modificar pantallas, formularios o componentes visuales en lib/presentation/.
---

# UI y UX en French Gold ERP

## Contenido

- [Principios de diseño e interfaz](#principios-de-diseño-e-interfaz)
- [Formularios reactivos con Signals](#formularios-reactivos-con-signals)
- [Manejo de estado de carga y feedback](#manejo-de-estado-de-carga-y-feedback)
- [Componentes y widgets reutilizables](#componentes-y-widgets-reutilizables)
- [Estructura de pantalla y Layout](#estructura-de-pantalla-y-layout)
- [Flujo de implementación de formularios](#flujo-de-implementación-de-formularios)
- [Reglas críticas y de arquitectura](#reglas-críticas-y-de-arquitectura)
- [Referencias](#referencias)

---

## Principios de diseño e interfaz

- **Tema dinámico con `Theme.of(context)`:** Acceder siempre a los colores e itinerarios tipográficos mediante `Theme.of(context).colorScheme` y `Theme.of(context).textTheme`. Queda prohibido el uso de colores hardcodeados (p. ej. `Colors.blue`) o `Get.theme`.
- **Material 3:** La aplicación sigue las pautas visuales de Material 3 (elevaciones bajas, bordes redondeados estándar de `12dp` o `16dp` e integración de temas oscuros/claros).
- **Consistencia de Color:**
  - Acciones primarias: `colorScheme.primary`
  - Errores/Alertas: `colorScheme.error`
  - Fondo de contenedores: `colorScheme.surface`, `colorScheme.surfaceContainerHigh`

---

## Formularios reactivos con Signals

La construcción de formularios reactivos en la capa de presentación se realiza creando señales efímeras dentro del `State` del `StatefulWidget` y utilizando `SignalBuilder` para actualizaciones visuales oportunas.

### Patrón de declaración de Signals para formularios

```dart
class _CreateWarehouseScreenState extends State<CreateWarehouseScreen> {
  // Signals para los datos de los campos de texto
  final _name = signal('');
  final _address = signal('');

  // Signals para la validación de cada campo
  final _isNameValid = signal(false);
  final _isAddressValid = signal(false);

  // Signal para controlar el estado de procesamiento/carga
  final isLoading = signal(false);
  ...
}
```

### Integración en widgets de entrada (`CustomTextField`)

Actualizar las señales dentro del evento `onChanged` para ofrecer validación reactiva e inmediata:

```dart
CustomTextField(
  labelText: 'Nombre del almacén',
  hintText: 'Almacén Principal',
  prefixIcon: Icons.warehouse,
  keyboardType: TextInputType.name,
  onChanged: (String? val) {
    final value = val ?? '';
    if (value.trim().isEmpty) {
      _isNameValid.value = true;
    } else {
      _isNameValid.value = false;
    }
    _name.value = value;
  },
),
const SizedBox(height: 8),
SignalBuilder(
  builder: (context) {
    if (_isNameValid.value) {
      return _buildErrorMessage('Por favor, ingresa el nombre del almacén.');
    }
    return const SizedBox.shrink();
  },
),
```

---

## Manejo de estado de carga y feedback

### Botón de acción reactivo

Alternar entre un botón interactivo y un indicador de progreso según la señal `isLoading`:

```dart
SignalBuilder(
  builder: (context) {
    if (isLoading.value) {
      return const CustomProgressIndicatorButton();
    }
    return CustomButton(
      name: 'Siguiente',
      onPressed: _onSubmitForm,
    );
  },
)
```

### Lógica de envío y retroalimentación (`_onSubmitForm`)

```dart
void _onSubmitForm() {
  isLoading.value = true;

  final data = CreateWarehouseInput(
    _name.value.trim(),
    _address.value.trim(),
  );

  if (data.isNotValid) {
    isLoading.value = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor completa todos los campos correctamente'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final controller = context.read<WarehouseController>();
  controller
      .createWarehouse(data)
      .then((value) {
        if (!mounted) return;
        isLoading.value = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Almacén ${value.name} creado correctamente'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.go(WarehouseScreen.routeName);
      })
      .catchError((e) {
        if (!mounted) return;
        isLoading.value = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
}
```

---

## Componentes y widgets reutilizables

Consultar siempre `lib/presentation/widgets/` antes de crear nuevos componentes visuales:

- **Entrada de texto:** `CustomTextField`, `CustomPasswordField`.
- **Botones:** `CustomButton`, `CustomProgressIndicatorButton`.
- **Mensajes de error visuales:** Helper contenedor con icono (`Icons.info_outline`) y bordes estilizados.

```dart
Widget _buildErrorMessage(String message) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}
```

---

## Estructura de pantalla y Layout

- **Scaffold + SafeArea:** Obligatorio para garantizar adaptabilidad con los bordes y barras del sistema.
- **SingleChildScrollView + LayoutBuilder:** Evita el desbordamiento de pantalla (*overflow*) cuando el teclado virtual está visible en dispositivos de resolución reducida.
- **Padding estándar:** Usar `EdgeInsets.all(24.0)` o `EdgeInsets.symmetric(horizontal: 24.0)`.

---

## Flujo de implementación de formularios

- [ ] **1. Definir Signals en el State:** Crear señales para campos de texto, estados de validación y carga en el `State` del `StatefulWidget`.
- [ ] **2. Usar CustomTextField:** Configurar `onChanged` actualizando el valor del campo y evaluando la validación.
- [ ] **3. Renderizar mensajes de error con SignalBuilder:** Envolver la vista del mensaje de error en `SignalBuilder` para actualización reactiva.
- [ ] **4. Configurar botón de envío:** Envolver el botón en `SignalBuilder` utilizando `CustomProgressIndicatorButton` cuando `isLoading.value` sea `true`.
- [ ] **5. Implementar envío y retroalimentación:** Ejecutar el llamado al controlador de dominio, gestionar `isLoading`, notificar con `ScaffoldMessenger` y redirigir con `GoRouter`.

---

## Reglas críticas y de arquitectura

1. **Estado con Signals:** Usar únicamente `signals_flutter` (`signal()`, `SignalBuilder`, `Watch`). Prohibido `Rx` o `Obx`.
2. **Acceso al Tema:** Usar `Theme.of(context)` para colores y fuentes. Prohibido utilizar `Get.theme` o colores fijos sin justificación.
3. **Manejo de Errores e Indicadores:** Todos los formularios con acciones asíncronas deben incluir indicación de carga (`CustomProgressIndicatorButton`) e informaciones flotantes de éxito/error (`SnackBar`).
4. **Verificación Obligatoria:** Ejecutar `dart format lib/` y `flutter analyze` asegurando 0 errores y advertencias.

---

## Referencias

- Pantalla de referencia: [lib/presentation/screens/warehouse/create_warehouse_screen/create_warehouse_screen.dart](lib/presentation/screens/warehouse/create_warehouse_screen/create_warehouse_screen.dart)
- Reglas generales: [AGENTS.md](AGENTS.md)
- Skill Gestión de Estado: [flutter-managing-state](.agents/skills/flutter-managing-state/SKILL.md)
- Skill Entidades CRUD: [french-gold-crud-entity](.agents/skills/french-gold-crud-entity/SKILL.md)
- Skill Navegación: [french-gold-implementing-navigation-and-routing](.agents/skills/french-gold-implementing-navigation-and-routing/SKILL.md)
