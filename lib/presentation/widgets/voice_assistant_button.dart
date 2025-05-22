// lib/presentation/widgets/voice_assistant_button.dart (con animación)

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
                ? _buildPulsingMic(context)
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
  
  Widget _buildPulsingMic(BuildContext context) {
    return PulsingMicIcon(
      color: iconColor ?? Colors.white,
      size: size * 0.5,
    );
  }
}

class PulsingMicIcon extends StatefulWidget {
  final Color color;
  final double size;
  
  const PulsingMicIcon({
    super.key,
    required this.color,
    required this.size,
  });
  
  @override
  State<PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<PulsingMicIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            Icons.mic,
            color: widget.color,
            size: widget.size,
            key: const ValueKey('listening'),
          ),
        );
      },
    );
  }
}