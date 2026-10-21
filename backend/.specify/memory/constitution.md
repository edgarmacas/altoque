<!-- Sync Impact Report
Version change: 0.0.0 → 1.0.0 (Initial Ratification)
List of modified principles:
- [PRINCIPLE_1_NAME] → I. Arquitectura en capas
- [PRINCIPLE_2_NAME] → II. SOLID aplicado (no teórico)
- [PRINCIPLE_3_NAME] → III. Persistencia
- [PRINCIPLE_4_NAME] → IV. Seguridad (no negociable)
- [PRINCIPLE_5_NAME] → V. Diseño de endpoints REST
Added sections / principles:
- VI. Protocolo MCP: tools y reutilización
- VII. Testing y Cobertura
Removed sections:
- [SECTION_2_NAME] (Template placeholder removed; integrated into Core Principles)
- [SECTION_3_NAME] (Template placeholder removed; integrated into Core Principles)
Follow-up TODOs:
- None
-->

# Sistema de Gestión de Tareas Personales con Límite de Capacidad - Constitución

## Core Principles

### I. Arquitectura en capas
- `routers/`: Reciben la solicitud HTTP, delegan al service correspondiente y traducen su resultado (o excepción) a una respuesta HTTP. Un router NUNCA valida reglas de negocio (ej. límites de capacidad o transiciones de estado) — esa lógica vive estrictamente en `services/`.
- `services/`: Contienen toda la lógica de negocio (límite WIP, límite de tareas de prioridad alta, transición válida de estados). Un service NUNCA importa SQLAlchemy, `Session`, ni detalles de base de datos directamente.
- `repositories/`: Son la única capa autorizada a interactuar con la base de datos. Un repository no contiene reglas de negocio, solo operaciones de persistencia (guardar, listar, buscar por id, contar por estado/prioridad, eliminar).
- `utils/`: Son funciones puras (mismo input -> mismo output, sin efectos secundarios), sin dependencias de dominio.
- `mcp/tools/`: NUNCA reimplementan reglas de negocio. Si una tool MCP y un router necesitan la misma operación, ambos llaman al mismo service.
*Razón de ser*: Garantiza separación estricta de responsabilidades, alta testabilidad y desacoplamiento entre protocolos de transporte (HTTP/MCP) y la persistencia.

### II. SOLID aplicado (no teórico)
- **SRP**: Cada función de `services/` hace una sola cosa. La validación de límites está separada de la orquestación de creación o cambio de estado.
- **OCP**: Las prioridades (`baja`, `media`, `alta`) y estados (`pendiente`, `en_progreso`, `completada`) se definen mediante Enums, facilitando extensiones sin modificar la lógica existente.
- **DIP**: Todo service que necesite un repository lo recibe como parámetro con un valor por defecto (ej. `def crear_tarea(..., repo=tareas_repository)`), NUNCA lo importa fijo dentro del cuerpo de la función. Esto es innegociable: permite testear sin `unittest.mock`.
- **Simplicidad**: No se fuerza complejidad artificial de jerarquías de clases si no son necesarias; se priorizan funciones modulares claras.
*Razón de ser*: Facilita pruebas modulares deterministas sin acoplamiento a frameworks de mocking y minimiza el impacto ante cambios de requerimientos.

### III. Persistencia
- **Agnosticismo de BD**: SQLAlchemy como ORM y SQLite en desarrollo; el código de `database.py` debe ser agnóstico para funcionar contra PostgreSQL sin tocar `services/` ni `routers/`.
- **Aislamiento por usuario**: Cada modelo con datos de usuario (`Tarea`) incluye `usuario_id` como clave foránea (`FK`). NINGUNA consulta de tareas puede omitir el filtro por `usuario_id`.
*Razón de ser*: Protege la integridad y privacidad de datos multi-inquilino (multi-tenant) y permite alternar entornos de desarrollo y producción con cero fricción.

### IV. Seguridad (no negociable)
- **Contraseñas**: Hash con `passlib[bcrypt]` fijando `bcrypt<4.1`. NUNCA se almacena ni se expone una contraseña en texto plano.
- **Autenticación**: OAuth2 password flow + JWT firmado con `HS256`. Tiempo de expiración configurable, NUNCA infinito.
- **Variables de Entorno**: `SECRET_KEY` y `DATABASE_URL` viven solo en `.env` (nunca versionado en Git). `.env.example` documenta las variables requeridas sin valores reales.
- **Autorización Estricta**: El `usuario_id` para crear, consultar, modificar estado o eliminar una tarea SIEMPRE proviene del token JWT decodificado (`get_current_user`), NUNCA de un parámetro enviado por el cliente (ni en URL, ni body, ni query). Toda operación sobre una tarea por id verifica primero que pertenezca al usuario autenticado.
- **Manejo de Errores Seguros**: Excepciones no controladas devuelven HTTP 500 con `{"detail": "Error interno del servidor"}` — nunca stack traces al cliente.
- **Validación Temprana**: Toda entrada de usuario se valida con esquemas Pydantic antes de llegar a `services/`.
*Razón de ser*: Defensa en profundidad contra vulnerabilidades comunes (IDOR, inyecciones, fuga de credenciales o trazas internas).

### V. Diseño de endpoints REST
- **Códigos de Estado Semánticos**:
  - `POST`: 201 Created (creación exitosa).
  - `GET`: 200 OK (consulta/listado exitoso).
  - `PATCH`: 200 OK (actualización de estado).
  - `DELETE`: 204 No Content (eliminación exitosa).
  - 401 Unauthorized: Fallo de autenticación o token inválido/expirado.
  - 403 Forbidden: Si el recurso pertenece a otro usuario.
  - 404 Not Found: Recurso no encontrado.
  - 422 Unprocessable Entity: Error de validación de schema Pydantic.
  - 400 Bad Request: Error de regla de negocio conocido (con formato `{"detail": "..."}`).
- **Paginación**: Listados paginados exponen `skip` y `limit` con valores por defecto (ej. `skip=0`, `limit=20`).
- **Separación de DTOs**: Schemas de entrada y salida separados (ej. `TareaCreate` vs `TareaOut`), NUNCA exponer el modelo ORM directamente.
*Razón de ser*: Contratos de API estandarizados, predecibles y consistentes con las convenciones HTTP modernas.

### VI. Protocolo MCP: tools y reutilización
- **Llamadas Directas a Servicios**: Cada tool de MCP llama directamente a una función de `services/tareas.py`.
- **Descripciones Claras**: Descripciones de tools específicas y accionables (ej. "Crea una tarea validando el límite de tareas de prioridad alta").
- **Errores Estructurados**: Errores de negocio estructurados devueltos como `{"error": "..."}`, nunca excepciones que rompan la sesión MCP.
- **Resolución de Identidad**: Identidad del usuario resuelta desde el token verificado de la sesión MCP (o fallback documentado si el transporte es stdio).
- **Acciones Destructivas**: Acciones destructivas (ej. eliminar tarea) gestionan confirmación del servidor.
*Razón de ser*: Permite que asistentes o agentes de IA interactúen con el sistema bajo las mismas reglas de negocio y restricciones que un usuario HTTP, sin duplicar lógica.

### VII. Testing y Cobertura
- **Pirámide de Pruebas Obligatoria**: Unitarias con repositorio falso (DIP) -> Integración contra base de datos real en memoria -> API endpoints con `dependency_overrides`.
- **Prohibición de `unittest.mock` en Services**: Está PROHIBIDO usar `unittest.mock` en los tests unitarios de `services/`, inyectando el repositorio falso por parámetro.
- **Cobertura Mínima Exigida**:
  - 100% de las reglas de negocio de `spec.md` cubiertas por pruebas unitarias identificables.
  - Cobertura de líneas en `services/` >= 90%.
  - Cobertura global combinada (`services` + `repositories` + `routers` + `utils`) >= 70%, medida con `pytest --cov=app --cov-report=term-missing`. Omitir `main.py`, `mcp/*` y `logging_config.py` del reporte.
- **Criterio de Aceptación**: Ninguna tarea se da por terminada sin su prueba en verde.
*Razón de ser*: Pruebas rápidas, robustas y refactorizables que validan la lógica de negocio sin fragilidad inducida por mocks artificiales.

## Governance

1. **Supremacía Constitucional**: Esta constitución tiene prioridad absoluta sobre cualquier decisión de implementación. Si el agente o desarrollador necesita desviarse de un artículo, debe señalarlo explícitamente y esperar aprobación antes de continuar.
2. **Procedimiento de Enmienda**: Cualquier cambio a los principios o artículos debe formularse mediante propuesta de enmienda documentada, evaluando su impacto en el diseño existente y actualizando este documento.
3. **Política de Versionado**:
   - **MAJOR**: Remoción o redefinición incompatible de artículos o directrices de gobernanza.
   - **MINOR**: Nuevos artículos/secciones agregados o expansión material de reglas existentes.
   - **PATCH**: Correcciones tipográficas, refinamientos de redacción o precisiones no semánticas.
4. **Auditoría y Verificación de Cumplimiento**: En cada ciclo de especificación, planificación e implementación se debe verificar el estricto cumplimiento de estos artículos (especialmente la inyección por DIP, la cobertura de pruebas y la no-importación de base de datos en servicios).

**Version**: 1.0.0 | **Ratified**: 2026-09-21 | **Last Amended**: 2026-09-21
