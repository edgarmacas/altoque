"""Esquemas para el Asistente de IA."""

from typing import Optional
from pydantic import BaseModel, Field


class ConsultaAsistente(BaseModel):
    mensaje: str = Field(..., min_length=1, max_length=1000)


class AccionPropuesta(BaseModel):
    tipo: str
    titulo: Optional[str] = None
    prioridad: Optional[str] = None
    tarea_id: Optional[int] = None


class RespuestaAsistente(BaseModel):
    respuesta: str
    accion: Optional[AccionPropuesta] = None
