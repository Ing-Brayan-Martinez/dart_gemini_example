# dart_gemini_example

[![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-blue.svg)](https://dart.dev)
[![Signals](https://img.shields.io/badge/Signals-State%20Management-purple.svg)](https://pub.dev/packages/signals_flutter)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Data%20Access-teal.svg)](https://pub.dev/packages/postgres)
[![Supabase](https://img.shields.io/badge/Supabase-Auth-green.svg)](https://supabase.com)

Aplicación y panel de administración multiplataforma (Desktop, Mobile, Web) desarrollada con **Flutter 3.38.9** y **Dart ^3.10** para **French's Gold ERP**, implementando una **Arquitectura Reactiva en Capas** con gestión de estado mediante **Signals**, inyección de dependencias con **GetX** y persistencia sobre **PostgreSQL**.

---

## 🚀 Características Principales

- **Gestión de Estado Reactiva:** Implementación estricta y reactiva mediante **Signals** (`signals_flutter`).
- **Navegación & Deep Linking:** Enrutamiento declarativo multiplataforma utilizando **GoRouter**.
- **Inyección de Dependencias:** Gestión limpia de dependencias con **GetX** usado exclusivamente vía `Bindings`.
- **Acceso Asíncrono a PostgreSQL:** Persistencia directa y no bloqueante mediante el paquete `postgres`, protegida concurrentemente con `Mutex`.
- **Autenticación e Inicialización:** Integración fluida con **Supabase** (`supabase_flutter`).
- **Logging Unificado:** Monitoreo y trazabilidad de eventos estructurado con **Signale** (`signale`).
- **Soporte Multiplataforma:** Soporte optimizado para Desktop (Windows, macOS, Linux vía `window_manager`), Web y Mobile.
- **Integración con IA / Agentes:** Sistema modular de *Skills* en `.agents/skills/` e instrucciones centralizadas en `AGENTS.md`.

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología | Versión / Detalle |
| :--- | :--- | :--- |
| **Lenguaje & Runtime** | Dart | `^3.10` |
| **Framework Base** | Flutter | `3.38.9` |
| **Gestión de Estado** | Signals | `signals_flutter` (Estándar obligatorio) |
| **Navegación** | GoRouter | Routing declarativo y deep links |
| **Inyección de Dependencias** | GetX | `Bindings` (Uso exclusivo para DI) |
| **Autenticación** | Supabase | `supabase_flutter` |
| **Base de Datos** | PostgreSQL direct | `postgres` (Con `Mutex` por servicio) |
| **Logging** | Signale | `signale` (`Log.i`, `Log.e`, `Log.d`) |
| **Configuración** | Flutter Dotenv | `flutter_dotenv` (`.env` asset) |
| **Gestión de Ventanas** | Window Manager | `window_manager` (Desktop: Win/macOS/Linux) |
| **Manejo de Nulos** | Optional | `optional` (Null-handling seguro en capa de datos) |

---

## 📂 Arquitectura del Proyecto

El proyecto sigue una arquitectura reactiva en capas con separación estricta de responsabilidades:

```text
dart_gemini_example/
├── .agents/skills/            # Skills y guías de conocimiento modular para agentes de IA
├── .github/workflows/         # Pipelines de CI/CD para despliegue automatizado
├── lib/
│   ├── data/                  # Repositorios e implementación PostgreSQL
│   │   ├── postgresql/
│   │   │   ├── configuration/ # Configuración de conexión a PostgreSQL
│   │   │   └── service/       # Servicios de consultas SQL (con Mutex)
│   │   └── repository/        # Implementación concreta de repositorios
│   ├── domain/                # Capa pura Dart (Sin dependencias de Flutter/GetX)
│   │   ├── config/            # Helpers de Mutex, Log, Context, PostgreSQL
│   │   ├── controllers/       # Lógica de negocio reactiva (Signals)
│   │   └── model/             # Entidades de dominio
│   └── presentation/          # Capa de Interfaz de Usuario y Rutas
│       ├── routes/            # Configuración de GoRouter (app_routes.dart)
│       ├── screens/           # Pantallas (StatefulWidget + Watch / SignalBuilder)
│       ├── theme/             # Estilos y tema visual (Dark mode por defecto)
│       └── widgets/           # Componentes de UI reutilizables
├── .env                       # Variables de entorno (Supabase URL / Key)
├── AGENTS.md                  # Instrucciones y directrices para agentes IA y desarrolladores
├── analysis_options.yaml      # Reglas del analizador estático de Dart
└── pubspec.yaml               # Configuración de dependencias y assets Flutter
```

---

## 📡 Módulos y Flujos del Sistema

La aplicación expone y gestiona diferentes flujos reactivos mediante controladores en el dominio:

### 👤 Módulo de Usuarios & Autenticación
- **Inicio de Sesión:** Manejado a través de Supabase y `SplashScreen`.
- **Carga de Usuarios:** Gestión reactiva con `GetUserDataModel` y Signals.

### 📱 Módulo de Dispositivos & Entidades
- **Transacciones de Datos:** Operaciones protegidas mediante `TransactionHelper` (`beginTransaction`, `commit`, `rollback`).
- **Consultas PostgreSQL:** Métodos asíncronos aislados concurrentemente mediante `Mutex`.

---

## ⚙️ Guía de Inicio Rápido

### Requisitos Previos
- **Flutter SDK 3.38.9** (Dart ^3.10)
- Archivo `.env` configurado en la raíz con las credenciales necesarias:
  ```env
  SUPABASE_URL=https://tu-proyecto.supabase.co
  SUPABASE_KEY=tu-clave-supabase
  ```

### 1. Obtener Dependencias
```bash
flutter pub get
```

### 2. Validar Calidad del Código (Analizador Estático)
```bash
flutter analyze
```

### 3. Aplicar Formato Estándar de Código
```bash
dart format lib/
```

### 4. Ejecutar la Aplicación
```bash
# Ejecutar en el dispositivo predeterminado
flutter run

# Ejecutar en plataformas específicas
flutter run -d macos
flutter run -d windows
flutter run -d chrome
```

---

## 📖 Guías para Desarrolladores y Agentes

Para más detalles sobre reglas críticas, arquitectura de capas, patrones de diseño e integración de *Skills*, consulta el archivo de instrucciones centralizado:

- [AGENTS.md](AGENTS.md) — Guía completa de arquitectura, reglas críticas y desarrollo.
