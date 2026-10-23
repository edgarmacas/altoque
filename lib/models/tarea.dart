/// Modelo de datos que representa una Tarea del usuario en AlToque.
class Tarea {
  final int id;
  final int usuarioId;
  final String titulo;
  final String? descripcion;
  final String prioridad; // 'alta', 'media', 'baja'
  final String estado; // 'pendiente', 'en_progreso', 'completada'
  final DateTime? fechaLimite;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;

  const Tarea({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    this.descripcion,
    this.prioridad = 'media',
    this.estado = 'pendiente',
    this.fechaLimite,
    this.creadoEn,
    this.actualizadoEn,
  });

  bool get esPendiente => estado == 'pendiente';
  bool get esEnProgreso => estado == 'en_progreso';
  bool get esCompletada => estado == 'completada';
  bool get esPrioridadAlta => prioridad == 'alta';

  String get etiquetaEstado {
    switch (estado) {
      case 'en_progreso':
        return 'En progreso';
      case 'completada':
        return 'Completada';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }

  String get etiquetaPrioridad {
    switch (prioridad) {
      case 'alta':
        return 'Alta';
      case 'baja':
        return 'Baja';
      case 'media':
      default:
        return 'Media';
    }
  }

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] as int,
      usuarioId: json['usuario_id'] as int? ?? 0,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      prioridad: json['prioridad'] as String? ?? 'media',
      estado: json['estado'] as String? ?? 'pendiente',
      fechaLimite: json['fecha_limite'] != null
          ? DateTime.tryParse(json['fecha_limite'] as String)
          : null,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'] as String)
          : null,
      actualizadoEn: json['actualizado_en'] != null
          ? DateTime.tryParse(json['actualizado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario_id': usuarioId,
        'titulo': titulo,
        if (descripcion != null) 'descripcion': descripcion,
        'prioridad': prioridad,
        'estado': estado,
        if (fechaLimite != null) 'fecha_limite': fechaLimite!.toIso8601String(),
        if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
        if (actualizadoEn != null) 'actualizado_en': actualizadoEn!.toIso8601String(),
      };

  Tarea copyWith({
    int? id,
    int? usuarioId,
    String? titulo,
    String? descripcion,
    String? prioridad,
    String? estado,
    DateTime? fechaLimite,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) {
    return Tarea(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fechaLimite: fechaLimite ?? this.fechaLimite,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }
}
