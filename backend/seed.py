"""Script de inicialización y datos de prueba (Seed) para AlToque.

Inserta un usuario demo y 20 tareas con diferentes prioridades y estados,
cumpliendo con el requisito del Proyecto Final (15-20 registros iniciales).
"""

from datetime import datetime, timedelta, timezone
from app.database import Base, SessionLocal, engine
from app.models.usuario import Usuario
from app.models.tarea import Tarea
from app.schemas.tarea import PrioridadEnum, EstadoEnum
from app.services.auth_service import hash_password

TAREAS_INICIALES = [
    # Trabajo / Universidad
    {
        "titulo": "Preparar presentación del Proyecto Final AlToque",
        "descripcion": "Revisar diapositivas, rúbrica de evaluación y verificar la compilación del APK.",
        "prioridad": PrioridadEnum.alta,
        "estado": EstadoEnum.en_progreso,
        "dias_limite": 2,
    },
    {
        "titulo": "Auditar variables de entorno y secretos",
        "descripcion": "Verificar que ningún token ni .env quede versionado en Git antes de la entrega.",
        "prioridad": PrioridadEnum.alta,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 3,
    },
    {
        "titulo": "Redactar informe técnico del curso",
        "descripcion": "Documentar la arquitectura en capas (GetX, Dio, Hive) y el flujo con el backend FastAPI.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.en_progreso,
        "dias_limite": 4,
    },
    {
        "titulo": "Revisar pull request de compañeros",
        "descripcion": "Dar feedback sobre pruebas unitarias y cobertura de código.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.completada,
        "dias_limite": -1,
    },
    {
        "titulo": "Actualizar dependencias de Flutter a última versión estable",
        "descripcion": "Ejecutar flutter pub upgrade y verificar compatibilidad de plugins.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.completada,
        "dias_limite": -3,
    },
    # Trámites y Finanzas Ecuador
    {
        "titulo": "Renovar cédula en Registro Civil",
        "descripcion": "Sacar turno en línea para agencia Quitumbe y llevar comprobante de pago.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 5,
    },
    {
        "titulo": "Declaración mensual de impuestos en SRI",
        "descripcion": "Ingresar comprobantes electrónicos del mes y conciliar retenciones.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.completada,
        "dias_limite": -2,
    },
    {
        "titulo": "Pagar matrícula y revisión vehicular en AMT",
        "descripcion": "Verificar multas pendientes y agendar turno en el centro de revisión.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 7,
    },
    {
        "titulo": "Revisar estado de cuenta en Banco Pichincha",
        "descripcion": "Conciliar transferencias recibidas y gastos del mes.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.completada,
        "dias_limite": -4,
    },
    # Hogar y Personal
    {
        "titulo": "Comprar víveres de la semana en el Supermaxi",
        "descripcion": "Frutas, verduras, café de Loja y artículos de limpieza.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 1,
    },
    {
        "titulo": "Mantenimiento preventivo de la laptop",
        "descripcion": "Limpieza de ventiladores, cambio de pasta térmica y respaldo en disco externo.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 10,
    },
    {
        "titulo": "Organizar estantería de libros y oficina",
        "descripcion": "Clasificar manuales de programación y cuadernos de apuntes antiguos.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.completada,
        "dias_limite": -5,
    },
    {
        "titulo": "Instalar repisa en el estudio",
        "descripcion": "Taladrar pared, colocar tacos fisher y nivelar.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 8,
    },
    # Salud y Bienestar
    {
        "titulo": "Chequeo médico anual y exámenes de laboratorio",
        "descripcion": "Agendar cita con el médico de cabecera en el IESS o clínica particular.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 6,
    },
    {
        "titulo": "Completar rutina de ejercicios 30 min",
        "descripcion": "Cardio y estiramientos en casa antes de empezar la jornada de desarrollo.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.completada,
        "dias_limite": 0,
    },
    {
        "titulo": "Comprar vitaminas en la farmacia Fybeca",
        "descripcion": "Complejo B y Vitamina C recomendadas por el doctor.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 3,
    },
    # Aprendizaje y Desarrollo Personal
    {
        "titulo": "Practicar patrones de arquitectura con GetX y Dio",
        "descripcion": "Probar manejo de tokens con interceptores y refresco automático.",
        "prioridad": PrioridadEnum.media,
        "estado": EstadoEnum.completada,
        "dias_limite": -6,
    },
    {
        "titulo": "Leer documentación sobre Model Context Protocol (MCP)",
        "descripcion": "Estudiar la especificación de tools, resources y transports stdio/http.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.completada,
        "dias_limite": -8,
    },
    {
        "titulo": "Explorar nuevas funciones de Flutter 3",
        "descripcion": "Revisar novedades de Impeller y soporte web WASM.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 12,
    },
    {
        "titulo": "Planificar viaje de fin de semana a Baños de Agua Santa",
        "descripcion": "Cotizar hospedaje y listar actividades al aire libre con la familia.",
        "prioridad": PrioridadEnum.baja,
        "estado": EstadoEnum.pendiente,
        "dias_limite": 14,
    },
]


def seed_database():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # 1. Crear usuario de prueba si no existe
        email_demo = "edgar@ejemplo.com"
        usuario = db.query(Usuario).filter(Usuario.email == email_demo).first()
        if not usuario:
            usuario = Usuario(
                email=email_demo,
                password_hash=hash_password("clave1234"),
            )
            db.add(usuario)
            db.commit()
            db.refresh(usuario)
            print(f"✅ Usuario creado: {usuario.email} (ID: {usuario.id})")
        else:
            print(f"ℹ️ Usuario existente: {usuario.email} (ID: {usuario.id})")

        # 2. Insertar las 20 tareas
        tareas_existentes = db.query(Tarea).filter(Tarea.usuario_id == usuario.id).count()
        if tareas_existentes >= 20:
            print(f"ℹ️ Ya existen {tareas_existentes} tareas para el usuario. No se duplicaron.")
            return

        now = datetime.now(timezone.utc)
        insertadas = 0
        for item in TAREAS_INICIALES:
            fecha_lim = now + timedelta(days=item["dias_limite"]) if item["dias_limite"] is not None else None
            t = Tarea(
                usuario_id=usuario.id,
                titulo=item["titulo"],
                descripcion=item["descripcion"],
                prioridad=item["prioridad"],
                estado=item["estado"],
                fecha_limite=fecha_lim,
            )
            db.add(t)
            insertadas += 1

        db.commit()
        print(f"🎉 Éxito: {insertadas} tareas sembradas en la base de datos.")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()
