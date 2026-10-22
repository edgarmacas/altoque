/// Representa el ciclo de vida de carga de datos en pantallas y controladores.
///
/// Siguiendo la rúbrica del curso, cada pantalla con datos debe cubrir de forma
/// explícita los estados de carga, vacío y error.
enum EstadoCarga {
  cargando,
  exito,
  vacio,
  error,
}
