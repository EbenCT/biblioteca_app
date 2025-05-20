// lib/presentation/widgets/voice_assistant_overlay.dart (simplificado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/voice_navigation_provider.dart';

class VoiceAssistantOverlay extends StatelessWidget {
  final Widget child;
  
  const VoiceAssistantOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<VoiceNavigationProvider>(
          builder: (context, provider, _) {
            if (!provider.isListening) {
              return const SizedBox.shrink();
            }
            
            return Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Cerrar el asistente al tocar fuera
                  provider.toggleVoiceInput();
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Escuchando...',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca para cancelar',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}