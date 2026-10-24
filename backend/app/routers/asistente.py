"""Router para el Asistente de IA (Servidor sin secretos)."""

import json
import logging
from typing import List
import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.config import settings
from app.database import get_db
from app.models.tarea import Tarea
from app.models.usuario import Usuario
from app.routers.deps import get_current_user
from app.schemas.asistente import ConsultaAsistente, RespuestaAsistente, AccionPropuesta

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/asistente", tags=["asistente"])


def _construir_contexto_tareas(tareas: List[Tarea]) -> str:
    """Construye un resumen textual de las tareas para el prompt o motor de reglas."""
    if not tareas:
        return "El usuario no tiene ninguna tarea registrada actualmente."

    lineas = []
    for t in tareas:
        limite = f", fecha límite: {t.fecha_limite.strftime('%Y-%m-%d')}" if t.fecha_limite else ""
        lineas.append(f"- [{t.estado.value.upper()}] (Prioridad: {t.prioridad.value.upper()}) #{t.id}: {t.titulo}{limite}")
    return "\n".join(lineas)


def _respuesta_inteligente_fallback(mensaje: str, tareas: List[Tarea]) -> RespuestaAsistente:
    """Genera una respuesta contextual basada en las tareas del usuario cuando no hay API key externa."""
    msg = mensaje.lower()
    pendientes = [t for t in tareas if t.estado.value == "pendiente"]
    en_progreso = [t for t in tareas if t.estado.value == "en_progreso"]
    completadas = [t for t in tareas if t.estado.value == "completada"]
    altas = [t for t in tareas if t.prioridad.value == "alta" and t.estado.value != "completada"]

    if any(p in msg for p in ["prioriz", "importante", "urgente", "que hago primero", "por donde empiezo"]):
        if altas:
            titulos = "\n".join([f"• {t.titulo} (ID: {t.id})" for t in altas[:3]])
            texto = (
                f"Te recomiendo enfocarte en tus tareas de prioridad alta:\n\n"
                f"{titulos}\n\n"
                f"Comienza por la primera y avánzala a 'En progreso' para mantener el foco."
            )
            return RespuestaAsistente(
                respuesta=texto,
                accion=AccionPropuesta(
                    tipo="iniciar_tarea",
                    tarea_id=altas[0].id,
                    titulo=altas[0].titulo,
                ),
            )
        elif pendientes:
            primera = pendientes[0]
            return RespuestaAsistente(
                respuesta=(
                    f"No tienes tareas de prioridad alta pendientes. Puedes continuar con:\n\n"
                    f"• {primera.titulo} (Prioridad: {primera.prioridad.value})\n\n"
                    f"Mantén un flujo continuo de trabajo completando una tarea a la vez."
                ),
                accion=AccionPropuesta(
                    tipo="iniciar_tarea",
                    tarea_id=primera.id,
                    titulo=primera.titulo,
                ),
            )
        else:
            return RespuestaAsistente(
                respuesta="Todas tus tareas actuales están completadas o en progreso. Buen momento para planificar nuevas metas.",
            )

    if any(p in msg for p in ["resum", "estado", "como voy", "cuantas", "resumen"]):
        texto = (
            f"Resumen de tu tablero de actividades:\n\n"
            f"• Tareas pendientes: {len(pendientes)}\n"
            f"• Tareas en progreso: {len(en_progreso)}\n"
            f"• Tareas completadas: {len(completadas)}\n"
            f"• Tareas de prioridad alta por resolver: {len(altas)}\n\n"
            f"Recuerda limitar el trabajo en progreso para evitar sobrecarga."
        )
        return RespuestaAsistente(respuesta=texto)

    # Respuesta general de asistencia
    return RespuestaAsistente(
        respuesta=(
            f"Hola. He revisado tus {len(tareas)} tareas registradas. "
            f"Actualmente tienes {len(pendientes)} pendientes y {len(en_progreso)} en progreso. "
            f"Puedes consultarme sobre priorización, pedirme un resumen de tu carga de trabajo o solicitar sugerencias de organización."
        )
    )


@router.post("/consultar", response_model=RespuestaAsistente)
async def consultar_asistente(
    consulta: ConsultaAsistente,
    current_user: Usuario = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Procesa una consulta del usuario mediante IA o motor contextual seguro sin exponer credenciales."""
    # Obtener las tareas del usuario autenticado
    tareas = db.query(Tarea).filter(Tarea.usuario_id == current_user.id).order_by(Tarea.id.desc()).all()
    contexto_tareas = _construir_contexto_tareas(tareas)

    # Si existe API key de Gemini configurada en el servidor, intentamos llamar a Gemini
    if settings.GEMINI_API_KEY:
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={settings.GEMINI_API_KEY}"
            prompt_sistema = (
                "Eres el Asistente inteligente de la aplicación AlToque (gestión de tareas personales). "
                "Responde en español neutro, conciso, educado y profesional. NUNCA uses emoticonos ni emojis. "
                "Basa tus respuestas estrictamente en el estado y tareas reales del usuario:\n\n"
                f"TAREAS ACTUALES DEL USUARIO:\n{contexto_tareas}\n\n"
                "Instrucciones de formato:\n"
                "Devuelve tu respuesta en texto claro. Si sugieres enfáticamente una acción concreta como iniciar una tarea o crear una tarea, "
                "menciónalo al final."
            )
            payload = {
                "contents": [
                    {
                        "role": "user",
                        "parts": [
                            {"text": f"{prompt_sistema}\n\nPregunta del usuario: {consulta.mensaje}"}
                        ]
                    }
                ],
                "generationConfig": {
                    "temperature": 0.4,
                    "maxOutputTokens": 600,
                }
            }
            async with httpx.AsyncClient(timeout=15.0) as client:
                res = await client.post(url, json=payload)
                if res.status_code == 200:
                    data = res.json()
                    candidato = data.get("candidates", [{}])[0]
                    partes = candidato.get("content", {}).get("parts", [{}])
                    texto_generado = partes[0].get("text", "").strip()
                    if texto_generado:
                        return RespuestaAsistente(respuesta=texto_generado)
        except Exception as e:
            logger.warning("Fallo al contactar servicio externo de IA, recurriendo a motor local: %s", e)

    # Fallback inteligente local basado en tareas reales del usuario
    return _respuesta_inteligente_fallback(consulta.mensaje, tareas)
