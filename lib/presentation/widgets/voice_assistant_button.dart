// lib/presentation/widgets/voice_assistant_button.dart (simplificado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/voice_navigation_provider.dart';

class VoiceAssistantButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  
  const VoiceAssistantButton({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.size = 56.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceNavigationProvider>(
      builder: (context, provider, child) {
        final bool isListening = provider.isListening;
        
        return FloatingActionButton(
          onPressed: () {
            provider.toggleVoiceInput();
          },
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isListening
                ? Icon(
                    Icons.mic,
                    color: iconColor ?? Colors.white,
                    size: size * 0.5,
                    key: const ValueKey('listening'),
                  )
                : Icon(
                    Icons.mic_none,
                    color: iconColor ?? Colors.white,
                    size: size * 0.5,
                    key: const ValueKey('not_listening'),
                  ),
          ),
        );
      },
    );
  }
}