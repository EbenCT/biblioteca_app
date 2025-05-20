// lib/core/utils/speech_recognition_state.dart

import 'package:flutter/material.dart';

enum SpeechRecognitionState {
  idle,
  listening,
  processing,
  error,
}

class SpeechState extends StatelessWidget {
  final SpeechRecognitionState state;
  final String? message;
  final Color? color;
  
  const SpeechState({
    super.key,
    required this.state,
    this.message,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).colorScheme.primary;
    
    switch (state) {
      case SpeechRecognitionState.idle:
        return const SizedBox.shrink();
        
      case SpeechRecognitionState.listening:
        return _buildIndicator(
          Icons.mic,
          message ?? 'Escuchando...',
          color ?? defaultColor,
          true,
        );
      
      case SpeechRecognitionState.processing:
        return _buildIndicator(
          Icons.sync,
          message ?? 'Procesando...',
          color ?? Colors.orange,
          true,
        );
      
      case SpeechRecognitionState.error:
        return _buildIndicator(
          Icons.error_outline,
          message ?? 'Error en el reconocimiento',
          color ?? Colors.red,
          false,
        );
    }
  }
  
  Widget _buildIndicator(IconData icon, String text, Color color, bool animate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          animate
              ? _AnimatedIcon(icon: icon, color: color)
              : Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  
  const _AnimatedIcon({
    required this.icon,
    required this.color,
  });
  
  @override
  _AnimatedIconState createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: child,
        );
      },
      child: Icon(
        widget.icon,
        color: widget.color,
      ),
    );
  }
}