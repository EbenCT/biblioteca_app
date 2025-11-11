// lib/presentation/widgets/qr/qr_floating_button.dart
import 'package:flutter/material.dart';

class QRFloatingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isActive;

  const QRFloatingButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  State<QRFloatingButton> createState() => _QRFloatingButtonState();
}

class _QRFloatingButtonState extends State<QRFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(QRFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159,
            child: FloatingActionButton.large(
              onPressed: widget.onPressed,
              backgroundColor: widget.isActive 
                  ? Colors.red.shade400 
                  : Theme.of(context).primaryColor,
              elevation: 8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Efecto de pulso cuando está activo
                  if (widget.isActive)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  
                  // Icono principal
                  Icon(
                    widget.isActive ? Icons.close : Icons.qr_code_scanner,
                    size: 32,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}