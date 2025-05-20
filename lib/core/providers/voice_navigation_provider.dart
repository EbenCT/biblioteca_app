// lib/core/providers/voice_navigation_provider.dart

import 'package:flutter/material.dart';
import '../services/voice_navigation_manager.dart';

class VoiceNavigationProvider extends ChangeNotifier {
  VoiceNavigationManager? _manager;
  bool _isListening = false;
  
  bool get isListening => _isListening;
  
  void initialize(BuildContext context) {
    _manager = VoiceNavigationManager(context);
    
    // Escuchar el estado de escucha
    _manager?.listeningStatus.listen((listening) {
      _isListening = listening;
      notifyListeners();
    });
  }
  
  void toggleVoiceInput() {
    _manager?.toggleListening();
  }
  
  @override
  void dispose() {
    _manager?.dispose();
    super.dispose();
  }
}