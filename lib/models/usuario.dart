/// Modelo de datos que representa a un Usuario del sistema.
class Usuario {
  final int id;
  final String email;
  final DateTime? creadoEn;

  const Usuario({
    required this.id,
    required this.email,
    this.creadoEn,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      email: json['email'] as String,
      creadoEn: json['creado_en'] != null
          ? DateTime.tryParse(json['creado_en'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (creadoEn != null) 'creado_en': creadoEn!.toIso8601String(),
      };
}
