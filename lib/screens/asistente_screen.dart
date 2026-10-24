import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/asistente_controller.dart';
import '../models/mensaje_chat.dart';

/// Pantalla conversacional del Asistente de IA (Paso 6 - Rúbrica Criterio 6).
///
/// Conectado al backend propio sin exponer claves ni credenciales en el cliente.
class AsistenteScreen extends StatelessWidget {
  const AsistenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put<AsistenteController>(AsistenteController());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asistente AlToque',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Orientación inteligente de productividad',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Nueva conversación',
            onPressed: () {
              controller.limpiarConversacion();
              Get.snackbar(
                'Conversación reiniciada',
                'Puedes comenzar una nueva consulta.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner informativo de servidor seguro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1DCED8).withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 16, color: Color(0xFF0E8E98)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Conexión segura vía backend. No se comparten claves en el dispositivo.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                ),
              ],
            ),
          ),

          // Área de mensajes o estado vacío
          Expanded(
            child: Obx(() {
              if (!controller.tieneMensajes && !controller.estaCargando.value) {
                return _buildEstadoVacio(context, controller);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false,
                itemCount: controller.mensajes.length +
                    (controller.estaCargando.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.mensajes.length &&
                      controller.estaCargando.value) {
                    return _buildBurbujaCargando();
                  }

                  final msg = controller.mensajes[index];
                  return _buildBurbujaMensaje(context, msg, controller);
                },
              );
            }),
          ),

          // Barra inferior de entrada de texto
          _buildBarraEntrada(context, controller, theme),
        ],
      ),
    );
  }

  /// Estado vacío: bienvenida y sugerencias rápidas
  Widget _buildEstadoVacio(BuildContext context, AsistenteController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1DCED8).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 54,
              color: Color(0xFF0E8E98),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Asistente de Productividad',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Puedo ayudarte a priorizar tus tareas del día, resumir tu carga de trabajo y sugerir el siguiente paso para cumplir tus objetivos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          const SizedBox(height: 28),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sugerencias rápidas para comenzar:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...controller.sugerencias.map((sug) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () => controller.enviarMensaje(sug),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: Color(0xFF0E8E98),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sug,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Burbuja de mensaje individual (usuario o asistente)
  Widget _buildBurbujaMensaje(
    BuildContext context,
    MensajeChat msg,
    AsistenteController controller,
  ) {
    final esUsuario = msg.esUsuario;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!esUsuario) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0E8E98).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: Color(0xFF0E8E98),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: esUsuario ? const Color(0xFF0E8E98) : Colors.white,
                borderRadius: BorderRadius.circular(14).copyWith(
                  bottomRight: esUsuario ? const Radius.circular(2) : null,
                  bottomLeft: !esUsuario ? const Radius.circular(2) : null,
                ),
                border: esUsuario
                    ? null
                    : Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.texto,
                    style: TextStyle(
                      color: esUsuario ? Colors.white : Colors.grey.shade900,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (msg.accion != null) ...[
                    const SizedBox(height: 12),
                    _buildTarjetaAccion(context, msg.accion!, controller),
                  ],
                ],
              ),
            ),
          ),
          if (esUsuario) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Tarjeta de acción interactiva sugerida por el asistente
  Widget _buildTarjetaAccion(
    BuildContext context,
    AccionAsistente accion,
    AsistenteController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1DCED8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF0E8E98).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome_rounded,
                  size: 16, color: Color(0xFF0E8E98)),
              SizedBox(width: 6),
              Text(
                'Acción recomendada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF0E8E98),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (accion.titulo != null)
            Text(
              accion.titulo!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0E8E98),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 16),
            label: const Text('Iniciar esta tarea',
                style: TextStyle(fontSize: 12)),
            onPressed: () => controller.ejecutarAccion(accion),
          ),
        ],
      ),
    );
  }

  /// Indicador visual mientras el asistente responde
  Widget _buildBurbujaCargando() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0E8E98).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 18,
              color: Color(0xFF0E8E98),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0E8E98)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'El asistente está analizando tus tareas...',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Barra inferior fija para redactar y enviar consultas
  Widget _buildBarraEntrada(
    BuildContext context,
    AsistenteController controller,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => controller.enviarMensaje(),
                decoration: InputDecoration(
                  hintText: 'Pregunta sobre tus tareas...',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => IconButton.filled(
                  icon: controller.estaCargando.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0E8E98),
                    foregroundColor: Colors.white,
                  ),
                  tooltip: 'Enviar consulta',
                  onPressed: controller.estaCargando.value
                      ? null
                      : controller.enviarMensaje,
                )),
          ],
        ),
      ),
    );
  }
}
