/// Acción propuesta por el asistente para ser confirmada por el usuario.
class AccionAsistente {
  final String tipo;
  final String? titulo;
  final String? prioridad;
  final int? tareaId;

  const AccionAsistente({
    required this.tipo,
    this.titulo,
    this.prioridad,
    this.tareaId,
  });

  factory AccionAsistente.fromJson(Map<String, dynamic> json) {
    return AccionAsistente(
      tipo: json['tipo'] as String? ?? 'general',
      titulo: json['titulo'] as String?,
      prioridad: json['prioridad'] as String?,
      tareaId: json['tarea_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        if (titulo != null) 'titulo': titulo,
        if (prioridad != null) 'prioridad': prioridad,
        if (tareaId != null) 'tarea_id': tareaId,
      };
}

/// Representa un mensaje individual dentro de la conversación con el asistente.
class MensajeChat {
  final String id;
  final String texto;
  final bool esUsuario;
  final DateTime fecha;
  final AccionAsistente? accion;

  MensajeChat({
    required this.id,
    required this.texto,
    required this.esUsuario,
    DateTime? fecha,
    this.accion,
  }) : fecha = fecha ?? DateTime.now();

  factory MensajeChat.fromJson(Map<String, dynamic> json) {
    return MensajeChat(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      texto: json['texto'] as String? ?? '',
      esUsuario: json['es_usuario'] as bool? ?? false,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'] as String) ?? DateTime.now()
          : DateTime.now(),
      accion: json['accion'] != null
          ? AccionAsistente.fromJson(Map<String, dynamic>.from(json['accion'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'texto': texto,
        'es_usuario': esUsuario,
        'fecha': fecha.toIso8601String(),
        if (accion != null) 'accion': accion!.toJson(),
      };
}
