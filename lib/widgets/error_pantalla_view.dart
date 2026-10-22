import 'package:flutter/material.dart';

/// Vista amigable que reemplaza la pantalla roja de depuración de Flutter.
///
/// Si un widget falla de forma inesperada durante su construcción, el usuario
/// ve esta pantalla con un diseño agradable y la opción de volver a la vista
/// principal en lugar de una traza técnica ininteligible.
class ErrorPantallaView extends StatelessWidget {
  final FlutterErrorDetails? detalles;

  const ErrorPantallaView({super.key, this.detalles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sentiment_dissatisfied_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'Algo no salió como esperábamos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Hemos registrado este fallo para resolverlo. Puedes volver a intentar o regresar al inicio.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver atrás'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
