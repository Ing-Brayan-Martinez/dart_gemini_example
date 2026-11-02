# Guía de Agentes y Desarrolladores — flutter_dijkstra_example

Este documento define el stack tecnológico, la arquitectura, los patrones de diseño y las reglas críticas que **TODOS** los agentes de inteligencia artificial y desarrolladores deben seguir obligatoriamente al trabajar en este proyecto.

---

## 1. Stack Tecnológico

El proyecto está diseñado para ser un panel de administración multiplataforma (Desktop, Mobile, Web) con **Flutter 3.38.9** y **Dart ^3.10**, implementando una arquitectura limpia con gestión de estado reactiva y acceso a datos no bloqueante con PostgreSQL.

---

## Project Skills & Knowledge Base

Este proyecto utiliza un sistema modular de "Skills" ubicado en [.agents/skills/](.agents/skills/). Estos documentos contienen guías especializadas y patrones para tareas específicas del proyecto.

**El agente DEBE seguir este protocolo:**

1. **Discovery**: Consultar `.agents/skills/` para identificar documentación relevante.
2. **Activation**: Leer el archivo `SKILL.md` de las skills relevantes:
   - [UI/UX Patterns](.agents/skills/french-gold-implementing-reactive-forms/SKILL.md) (`french-gold-implementing-reactive-forms`)
   - [Managing State (Signals)](.agents/skills/flutter-managing-state/SKILL.md) (`flutter-managing-state`)
   - [PostgreSQL Mapping](.agents/skills/french-gold-postgresql-dart-mapping/SKILL.md) (`french-gold-postgresql-dart-mapping`)
   - [CRUD Entity Flow](.agents/skills/french-gold-implementing-crud-entity/SKILL.md) (`french-gold-implementing-crud-entity`)
   - [MultiProvider DI](.agents/skills/french-gold-implementing-provider/SKILL.md) (`french-gold-implementing-provider`)
   - [Domain Controllers](.agents/skills/french-gold-implementing-controller/SKILL.md) (`french-gold-implementing-controller`)
3. **Compliance**: Aplicar los patrones definidos en la skill correspondiente. Si una skill entra en conflicto con las reglas críticas, las **Reglas Críticas** tienen prioridad.

| Categoría | Tecnología / Librería | Versión / Detalle |
| :--- | :--- | :--- |
| **Framework Base** | Flutter | `3.38.9` (Dart `^3.10`) |
| **Gestión de Estado** | Signals (`signals_flutter`) | Estándar reactivo obligatorio |
| **Navegación** | GoRouter | Enrutamiento declarativo y deep linking |
| **Inyección de Dependencias** | GetX | Usado **exclusivamente** para DI vía `Bindings` |
| **Autenticación** | Supabase (`supabase_flutter`) | Autenticación e inicialización |
| **Acceso a Datos** | PostgreSQL (`postgres`) | Consultas directas con `Mutex` por servicio |
| **Logging** | Signale (`signale`) | Logger unificado (`Log.i`, `Log.e`, etc.) |
| **Configuración** | Flutter Dotenv (`flutter_dotenv`) | Archivo `.env` en raíz (asset en `pubspec.yaml`) |
| **Gestión de Ventanas** | Window Manager (`window_manager`) | Ventanas Desktop (Linux, macOS, Windows) |
| **Manejo de Nulos** | Optional (`optional`) | Manejo seguro de nulos en capas de datos |
| **Despliegue & CI/CD** | GitHub Actions | Deployment a Play Store, App Store, Microsoft Store, Snap Store |

---

## 2. Reglas Críticas e Inviolables (MANDATORY)

1. **Mutex para PostgreSQL (Cero Colisiones):**
   - **TODOS** los métodos de servicios PostgreSQL DEBEN usar un `Mutex` para proteger las consultas y evitar colisiones de conexión (`final _mutex = Mutex(); _mutex.protect(() async { ... })`).

2. **Signals sobre GetX para Estado:**
   - **NUNCA** usar `Rx`, `Obx` o `GetxController`.
   - **NUNCA** usar `Get.find()` para gestión de estado en la UI.
   - Usar `signal()`, `computed()` y `SignalBuilder` (o `Watch`) para reactividad.

3. **Pureza del Dominio:**
   - `lib/domain/controllers/` DEBE contener **clases puras de Dart**.
   - **SIN** importaciones de `package:flutter` ni `package:get` en controladores de dominio.
   - Usar `package:signals/signals.dart` para la lógica y el estado en esta capa.

4. **Inyección de Dependencias por Constructor:**
   - Repositorios, Servicios y Controladores DEBEN inyectarse a través del constructor.

5. **Logging con Signale:**
   - Usar `Log.i()`, `Log.e()`, `Log.d()`, etc. en lugar de `print()` o `debugPrint()`.

6. **Inviolabilidad de Arquitectura en Capas:**
   - **Presentación (`presentation`)** $\rightarrow$ **Dominio (`domain`)** + **Datos (`data`)** (vía DI).
   - **Datos (`data`)** $\rightarrow$ **Dominio (`domain`)**.
   - **Dominio (`domain`)** $\rightarrow$ **Nada** (Dart puro).

7. **Verificación Obligatoria de Calidad:**
   - Antes de dar por completada cualquier tarea, se deben ejecutar los comandos de formateo y análisis de código.

---

## 3. Estructura del Proyecto

```text
lib/
├── data/           # Repositorios e implementación PostgreSQL
│   ├── postgresql/
│   │   ├── configuration/   # Configuración de conexiones PostgreSQL
│   │   └── service/         # Implementaciones SQL (ej. UserPostgreSqlServiceImpl)
│   └── repository/          # Implementaciones de repositorios
├── domain/         # Capa pura Dart: Modelos, Interfaces, Helpers, Enums, Controladores
│   ├── config/             # Mutex, Log, ContextHelper, PostgreSqlHelper
│   ├── controllers/        # Lógica de negocio reactiva (Pure Dart + Signals)
│   └── model/              # Entidades del dominio
└── presentation/   # Capa de Interfaz de Usuario, Temas, Rutas y Componentes
    ├── routes/             # Configuración de GoRouter (app_routes.dart)
    ├── screens/            # Pantallas (StatefulWidget + Watch) y Estado de vista
    ├── theme/              # Estilos y temas visuales
    └── widgets/            # Componentes de UI reutilizables
```

## Variables de entorno

- `.env` required at root with `SUPABASE_URL` and `SUPABASE_KEY`
- `.env` is an asset — **never commit secrets**
- App starts at `SplashScreen`; dark theme default (`ThemeMode.dark`)

---

## 4. Patrones de Implementación (Código de Referencia)

### A. Domain Controller (Dart Puro)
La lógica de negocio reside en la capa de dominio. Usar señales para exponer el estado.

```dart
import 'package:signals/signals.dart';
import '../../domain/config/log.dart';

class GetUserDataModel {
  final LoadState state;
  final List<User>? userList;
  final Object? error;

  const GetUserDataModel(this.state, {this.userList, this.error});
}

Future<GetUserDataModel> loadUsers() async {
  final contextHelper = ContextHelperImpl();
  final transactionHelper = TransactionHelperImpl();
  final userRepository = UserRepositoryImpl();
  try {
    Log.i('loadUsers()');

    /**
     * Limpia para realizar una nueva transacción.
     */
    await transactionHelper.dealLocated();

    /**
     * Iniciar una transacción para evitar inconsistencias en la
     * base de datos.
     */
    await transactionHelper.beginTransaction();

    final value = await deviceRepository.findAll();

    await transactionHelper.commit();

    Log.i('loadUsers() FINISH');
    return GetUserDataModel(LoadState.completed, userList: value);
  } catch (e, st) {
    Log.e(e);
    // Revertir la transacción en caso de error
    transactionHelper.rollback();
    Log.i('loadUsers() FINISH');
    rethrow;
  }
}
```

---

### B. Consumo en UI (Signals)
En la capa de presentación se utiliza `Watch` o `SignalBuilder`.

```dart
import 'package:signals_flutter/signals_flutter.dart';

class UserScreen extends StatefulWidget {
  static const String routeName = '/user';

  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  // Signals para el estado de la petición
  final isLoading = signal(false);

  // Signals para almacenar los valores del formulario
  final FlutterSignal<User?> _user = signal(null);
  final FlutterSignal<GetUserDataModel> _model = signal(
    GetUserDataModel(LoadState.loading),
  );

  @override
  void initState() {
    super.initState();

    getUser()
        .then((value) => _model.value = value)
        .catchError(
          (e) => _model.value = GetUserDataModel(LoadState.error, error: e),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final GetUserDataModel model = _model.value;

        return switch (model.state) {
          LoadState.loading => SizedBox(
              height: 123.0,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary,
                ),
              ),
            ),
          LoadState.error => SizedBox(
              height: 123.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        color: Theme.of(
                          context,
                        ).colorScheme.error,
                        size: 150,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.error,
                          fontSize: 12,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          LoadState.completed => ListView.builder(
              itemCount: model.userList!.length,
              itemBuilder: (context, index) => Text(model.userList![index].name),
            ),
        };
      },
    );
  }
}
```

---

### C. Enrutamiento (GoRouter)

```dart
GoRoute(
  path: HomeScreen.routeName,
  builder: (context, state) {
    return HomeScreen();
  },
)
```

---

### D. Servicios PostgreSQL

- **Ubicación:** `lib/data/postgresql/service/<entity>_postgresql_service.dart`
- Interface + impl (`abstract interface class` + `final class ...Impl extends PostgreSqlBase`)
- **Mutex** para concurrencia (`final _mutex = Mutex(); _mutex.protect(() async { ... })`)
- Retornar `Optional<T>` (package:optional) para consultas de fila única.
- Raw SQL con parámetros nombrados (`Sql.named(query), parameters: {...}`)
- Helpers: `PostgreSqlHelper.createJson(result)`, `createJson2(result, row)`

---

### E. Repositorios

- Interfaz en dominio, impl en `lib/data/repository/`.
- Delegan al servicio de PostgreSQL sin incluir lógica de negocio.
- El constructor instanciará el servicio directamente (`UserRepositoryImpl() : _service = UserPostgreSqlServiceImpl()`).

---

### F. Importaciones Condicionales (Desktop vs Web)

```dart
// lib/window_manager_service.dart
import 'window_manager_stub.dart'
    if (dart.library.io) 'window_manager_io.dart'
    as window_manager;
```

- `window_manager_stub.dart` — implementación no-op para web.
- `window_manager_io.dart` — uso real del paquete `window_manager`.
- Inicialización en `main.dart` antes de `runApp()`: `await window_manager.initWindowManager()`.

---

### G. Manejo de Errores y Transacciones en Controladores

```dart
Future<List<Device>> loadData() async {
  final contextHelper = ContextHelperImpl();
  final transactionHelper = TransactionHelperImpl();
  final deviceRepository = DeviceRepositoryImpl();
  try {
    Log.i('loadData()');

    /**
     * Limpia para realizar una nueva transacción.
     */
    await transactionHelper.dealLocated();

    /**
     * Iniciar una transacción para evitar inconsistencias en la
     * base de datos.
     */
    await transactionHelper.beginTransaction();

    final value = await deviceRepository.findAll();

    await transactionHelper.commit();

    Log.i('loadData() FINISH');
    return value;
  } catch (e, st) {
    Log.e(e);
    // Revertir la transacción en caso de error
    transactionHelper.rollback();
    Log.i('loadData() FINISH');
    rethrow;
  }
}
```

---

## 5. Entorno y CI/CD

### Entorno (.env)
- Archivo `.env` requerido en la raíz con `SUPABASE_URL` y `SUPABASE_KEY`.
- `.env` es un asset — **nunca subir secretos al repositorio**.
- La aplicación inicia en `SplashScreen`; tema oscuro por defecto (`ThemeMode.dark`).

### CI/CD
- Workflow: `.github/workflows/`
- Triggers: push y pull request a la rama `release`.
- **Versión fija de Flutter: 3.38.9^** (no cambiar sin coordinación del equipo).
- Despliega versiones beta a Play Store, App Store, Microsoft Store y Snap Store.

---

## 6. Workflow de Verificación (Pre-completion Verification)

Antes de reportar cualquier tarea como completada, el agente **DEBE** ejecutar y validar:

1. **Formateo del Código:**
   ```bash
   dart format lib/
   ```
   *Garantiza un estilo de código consistente según el estándar de Dart.*

2. **Análisis de Código (Linter):**
   ```bash
   flutter analyze
   ```
   *Debe resultar en 0 errores y 0 advertencias.*

3. **Verificación de Pureza del Dominio:**
   *Verificar que `domain/controllers` sean clases puras de Dart sin importaciones de Flutter ni GetX.*

4. **Verificación de Reactividad:**
   *Verificar que TODO el estado esté manejado exclusivamente con `Signals`.*

5. **Verificación de Concurrencia:**
   *Verificar que se use `Mutex` en TODOS los servicios de PostgreSQL.*
