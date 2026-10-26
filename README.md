# AlToque — Sistema de Gestión de Tareas y Productividad

Aplicación móvil (Android) y web para la gestión de tareas personales con control de trabajo en curso (WIP limits), persistencia local y remota, autenticación segura y asistente de productividad integrado.

Este proyecto corresponde a la entrega final del curso de Desarrollo Móvil con Flutter, cubriendo el 100% de la rúbrica de evaluación técnica y metodológica.

---

## Tabla de contenidos

1. [Características principales](#características-principales)
2. [Arquitectura del sistema](#arquitectura-del-sistema)
3. [Cumplimiento de la rúbrica de evaluación](#cumplimiento-de-la-rúbrica-de-evaluación)
4. [Instalación y ejecución paso a paso](#instalación-y-ejecución-paso-a-paso)
5. [Credenciales de prueba y datos iniciales](#credenciales-de-prueba-y-datos-iniciales)
6. [Estructura del proyecto](#estructura-del-proyecto)
7. [Pruebas y aseguramiento de calidad](#pruebas-y-aseguramiento-de-calidad)
8. [Integración y entrega continua (CI/CD)](#integración-y-entrega-continua-cicd)
9. [Seguridad y auditoría de secretos](#seguridad-y-auditoría-de-secretos)

---

## Características principales

- **Gestión completa de tareas (CRUD):** Creación, edición, avance de estado (pendiente, en progreso, completada) y eliminación de tareas.
- **Filtros reactivos en tiempo real:** Filtrado dinámico por estado de tarea y por prioridad (alta, media, baja) sin recargar la pantalla.
- **Autenticación robusta con JWT:** Flujo de registro, inicio de sesión y persistencia segura de credenciales en almacenamiento cifrado del dispositivo.
- **Persistencia local con Hive:**
  - Marcado de tareas destacadas en la caja local `tareas_destacadas` que sobreviven al reinicio de la aplicación.
  - Modo sin conexión (offline) con respaldo automático en `tareas_cache` y banner visual informativo.
- **Asistente de productividad inteligente:**
  - Conectado a través del backend propio (`/asistente/consultar`).
  - **Cero secretos en el cliente:** el cliente móvil nunca almacena claves de IA.
  - Análisis contextual de las tareas del usuario para recomendar prioridades del día y proponer acciones directas.
- **Experiencia de usuario (UX) consistente:** Cobertura estricta de los tres estados de interfaz (cargando, vacío con acción recomendada y error con reintento) en cada pantalla, sin emoticonos ni emojis, usando una paleta corporativa basada en Material 3 (`#1DCED8` cian/turquesa y `#FF467A` acento coral).

---

## Arquitectura del sistema

El proyecto sigue una arquitectura limpia en capas desacopladas:

```text
[ Vistas (Screens & Widgets) ]
             |  (Reactividad con Obx)
[ Controladores GetX (State Management) ]
             |
[ Repositorios (Orquestación Remoto/Local) ]
        /         \
       /           \
[ ApiClient (Dio) ]  [ Hive Boxes ]
       |                    |
[ Backend FastAPI ]     [ Almacenamiento Local ]
```

- **Capa de Presentación (`lib/screens/`, `lib/widgets/`):** Vistas declarativas que observan el estado reactivo mediante `Obx`. No realizan llamadas de red directas ni consultas de base de datos.
- **Capa de Controladores (`lib/controllers/`):** Administran el ciclo de vida, los flujos de usuario y los estados observables (`RxList`, `RxString`, `RxBool`).
- **Capa de Repositorios (`lib/repositories/`):** Implementan la lógica de obtención de datos, coordinando la sincronización entre el servidor remoto y la caché local de Hive.
- **Capa de Servicios de Red (`lib/services/`):** Encapsulan el cliente HTTP `Dio` con interceptores para inyección automática de cabeceras `Authorization: Bearer <token>` y traducción de errores a `ApiException`.
- **Backend Propio (`backend/`):** API REST construida en FastAPI con validaciones Pydantic, base de datos SQLite mediante SQLAlchemy, autenticación JWT con Passlib y soporte para MCP (Model Context Protocol).

---

## Cumplimiento de la rúbrica de evaluación

| Criterio de la Rúbrica | Ponderación | Implementación en AlToque |
|---|---|---|
| **1. Persistencia remota** | 20% | API REST completa en FastAPI con endpoints GET, POST, PUT, DELETE para tareas, paginación y filtros por estado y prioridad. |
| **2. Autenticación** | 15% | Flujo completo de registro y login con JWT; persistencia en `FlutterSecureStorage` e interceptor de autenticación en `ApiClient`. |
| **3. Datos reales** | 15% | Script `backend/seed.py` que precarga 20 tareas realistas y detalladas asociadas al usuario demo. |
| **4. Persistencia local** | 10% | Cajas Hive `tareas_destacadas` y `tareas_cache` con patrón «Hive guarda, Rx notifica»; soporte offline con fallback transparente. |
| **5. Gestión de estado (GetX)** | 10% | Controladores centralizados (`AuthController`, `TareasController`, `AsistenteController`, `HomeController`), reactividad granular y sin `setState`. |
| **6. IA sin secretos** | 10% | Asistente conectado mediante endpoint seguro `/asistente/consultar`; sin claves en el cliente; fallback inteligente contextual. |
| **7. Manejo de errores** | 10% | Excepciones diferenciadas para 400, 401, 403, 404, 422 y 5xx; widgets de los 3 estados (Loading, Empty, Error); sanitización de logs en `ReporteErrores`. |
| **8. Arquitectura y calidad** | 5% | Separación estricta de responsabilidades, código limpio analizado con `flutter analyze` y suite de pruebas automatizadas. |
| **9. Documentación y CI/CD** | 5% | Workflows de GitHub Actions (`ci.yml` y `release-apk.yml`), archivo `AGENTS.md`, auditoría de secretos y este manual. |

---

## Instalación y ejecución paso a paso

### Requisitos previos

- Flutter SDK (versión 3.22 o superior).
- Python 3.12 o superior.
- Gestor de paquetes `uv` para Python (o pip tradicional).
- Google Chrome (para ejecución Web) o emulador Android / dispositivo físico.

---

### Paso 1: Configurar y levantar el backend FastAPI

1. Ingresa a la carpeta del backend:
   ```bash
   cd backend
   ```

2. Crea y activa el entorno virtual (usando `uv`):
   ```bash
   uv sync
   ```

3. Crea el archivo de entorno a partir de la plantilla:
   ```bash
   cp .env.example .env
   ```

4. Inicializa la base de datos y carga los 20 registros iniciales:
   ```bash
   uv run python seed.py
   ```

5. Inicia el servidor backend en el puerto 8000:
   ```bash
   uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

El backend quedará accesible en `http://127.0.0.1:8000` y la documentación interactiva Swagger en `http://127.0.0.1:8000/docs`.

---

### Paso 2: Ejecutar la aplicación Flutter

Abre una nueva terminal en la raíz del proyecto (`altoque`):

1. Instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```

2. Verifica que no existan errores de análisis:
   ```bash
   flutter analyze
   ```

3. Ejecuta la aplicación en la plataforma deseada:

   - **En Google Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```

   - **En Emulador Android:**
     *(Nota: En Android, el emulador accede al localhost de tu computadora a través de `10.0.2.2`, lo cual ya está configurado automáticamente en `ApiClient`).*
     ```bash
     flutter run -d android
     ```

---

## Credenciales de prueba y datos iniciales

Para facilitar la evaluación inmediata sin necesidad de registrar un usuario manual, la pantalla de inicio de sesión incluye el botón de acceso rápido **«Llenar datos de prueba»**:

- **Correo electrónico:** `edgar@ejemplo.com`
- **Contraseña:** `clave1234`

Al iniciar sesión, se cargan automáticamente las **20 tareas reales** precargadas por `seed.py`, con distintas fechas límite, niveles de prioridad (alta, media, baja) y estados (pendiente, en progreso, completada).

---

## Estructura del proyecto

```text
altoque/
├── .github/
│   └── workflows/
│       ├── ci.yml               # Flujo de CI (análisis y pruebas de Flutter + FastAPI)
│       └── release-apk.yml      # Flujo de CD para compilación automatizada de APK
├── AGENTS.md                    # Reglas de contexto y estándares para agentes de código
├── README.md                    # Documentación general del proyecto y rúbrica
├── .env.example                 # Plantilla de variables de entorno segura
├── .gitignore                   # Exclusión estricta de credenciales y bases de datos
├── pubspec.yaml                 # Dependencias y configuración de la app Flutter
├── lib/
│   ├── main.dart                # Punto de entrada, Hive.initFlutter() y dependencias GetX
│   ├── controllers/             # Gestión de estado con GetX
│   │   ├── auth_controller.dart
│   │   ├── tareas_controller.dart
│   │   ├── asistente_controller.dart
│   │   └── home_controller.dart
│   ├── models/                  # Modelos de datos inmutables y serializadores
│   │   ├── usuario.dart
│   │   ├── tarea.dart
│   │   └── mensaje_chat.dart
│   ├── repositories/            # Capa de datos y fallback a caché de Hive
│   │   └── tareas_repository.dart
│   ├── screens/                 # Pantallas de la aplicación
│   │   ├── login_screen.dart
│   │   ├── registro_screen.dart
│   │   ├── home_screen.dart
│   │   ├── tareas_screen.dart
│   │   ├── destacadas_screen.dart
│   │   ├── asistente_screen.dart
│   │   ├── perfil_screen.dart
│   │   └── tarea_form_screen.dart
│   ├── services/                # Clientes de red y comunicación con la API
│   │   ├── api_client.dart
│   │   ├── api_exception.dart
│   │   ├── auth_api_service.dart
│   │   ├── tareas_api_service.dart
│   │   └── asistente_api_service.dart
│   ├── utils/                   # Utilidades y reporte global de errores
│   │   ├── estado_carga.dart
│   │   └── reporte_errores.dart
│   └── widgets/                 # Componentes visuales reutilizables
│       ├── tarea_card.dart
│       ├── loading_view.dart
│       ├── empty_view.dart
│       ├── error_view.dart
│       └── error_pantalla_view.dart
├── backend/                     # API REST FastAPI
│   ├── app/
│   │   ├── main.py              # Aplicación FastAPI y CORS
│   │   ├── config.py            # Configuración Pydantic Settings
│   │   ├── database.py          # Conexión SQLAlchemy a SQLite
│   │   ├── models/              # Modelos ORM (Usuario, Tarea)
│   │   ├── schemas/             # Esquemas de validación Pydantic
│   │   ├── routers/             # Endpoints (usuarios, tareas, asistente)
│   │   └── services/            # Lógica de negocio y reglas WIP
│   ├── seed.py                  # Script de semilla con datos reales
│   └── tests/                   # Suite de pruebas Pytest del backend (92 pruebas)
└── test/                        # Suite de pruebas automatizadas Flutter (24 pruebas)
    ├── auth_test.dart
    ├── tareas_test.dart
    ├── destacadas_hive_test.dart
    ├── asistente_test.dart
    ├── widgets_ux_test.dart
    └── widget_test.dart
```

---

## Pruebas y aseguramiento de calidad

El proyecto cuenta con cobertura integral de pruebas tanto en el frontend como en el backend:

### 1. Pruebas de la aplicación Flutter (24 pruebas automatizadas)
Ejecuta en la raíz del proyecto:
```bash
flutter test
```
- Pruebas de modelos (`Usuario`, `Tarea`, `MensajeChat`).
- Pruebas de controladores GetX y reactividad.
- Pruebas de persistencia local con Hive (marcado de destacadas y rescate offline).
- Pruebas de widgets y estados visuales (Loading, Empty, Error).
- Pruebas del asistente de productividad y ejecución de acciones sugeridas.

### 2. Análisis estático de código
```bash
flutter analyze
```
- Verificado con **0 errores y 0 advertencias**.

### 3. Pruebas del backend FastAPI (92 pruebas automatizadas)
Ejecuta dentro del directorio `backend/`:
```bash
cd backend && uv run pytest
```
- Pruebas unitarias de servicios, esquemas y límites WIP.
- Pruebas de integración de repositorios con SQLite en memoria.
- Pruebas de autenticación JWT y hashing de contraseñas con bcrypt.

---

## Integración y entrega continua (CI/CD)

El repositorio incluye dos flujos automatizados de GitHub Actions ubicados en `.github/workflows/`:

1. **`ci.yml` (Integración continua):**
   - Se dispara en cada `push` a cualquier rama y en cada `pull request`.
   - Ejecuta `flutter analyze`, `flutter test` y `uv run pytest`.
   - Actúa como puerta de calidad obligatoria para evitar regresiones.

2. **`release-apk.yml` (Entrega continua):**
   - Se dispara al crear una etiqueta de versión (`v*`, por ejemplo `v1.0.0`).
   - Compila el instalador optimizado para Android (`app-release.apk`).
   - Publica automáticamente el Release en GitHub con el binario adjunto.

---

## Seguridad y auditoría de secretos

- **Protección de variables de entorno:** El archivo `.gitignore` excluye `.env`, `*.env`, bases de datos SQLite (`tareas.db`) y entornos virtuales (`.venv/`).
- **Plantillas seguras:** Se proporcionan `.env.example` y `backend/.env.example` que contienen únicamente nombres de variables y valores de muestra sin claves reales.
- **Sanitización de registros:** La utilidad `ReporteErrores` en Flutter intercepta errores no controlados y oculta automáticamente tokens de autorización (`Bearer ***`) para evitar su fuga en registros de depuración o consola.
- **Cliente sin llaves externas:** El cliente móvil no contiene secretos de APIs de terceros; toda interacción inteligente se delega al backend propio.
