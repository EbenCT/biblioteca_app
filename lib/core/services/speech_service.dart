// lib/core/services/speech_service.dart (simplificado)

import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  
  final StreamController<String> _textStreamController = 
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningStatusController = 
      StreamController<bool>.broadcast();
  
  Stream<String> get textStream => _textStreamController.stream;
  Stream<bool> get listeningStatus => _listeningStatusController.stream;
  
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    // Solicitar permiso de micrófono
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Permiso de micrófono denegado');
      return false;
    }
    
  // Inicializar el speech-to-text
  _isInitialized = await _speech.initialize(
    onError: (error) => print('Error de reconocimiento: $error'),
    onStatus: (status) {
      print('Estado del reconocimiento: $status');
      if (status == 'done' || status == 'notListening') {
        _isListening = false;
        _listeningStatusController.add(false);
      }
    },
  );
  
  // Verificar si el idioma español está disponible
  if (_isInitialized) {
    final locales = await _speech.locales();
    print("Idiomas disponibles: $locales");
    
    // Buscar el idioma español
    // ignore: unused_local_variable
    stt.LocaleName? spanish;
    for (var locale in locales) {
      if (locale.localeId.startsWith('es')) {
        spanish = locale;
        print("Idioma español encontrado: ${locale.localeId} - ${locale.name}");
        break;
      }
    }
  }
    
    return _isInitialized;
  }

  Future<void> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    
    if (!_isListening) {
      _isListening = await _speech.listen(
        localeId: 'es_ES',
        onResult: (result) {
          // Enviar el texto reconocido al stream
          if (result.finalResult) {
            final recognizedWords = result.recognizedWords;
            if (recognizedWords.isNotEmpty) {
              print("Texto reconocido: $recognizedWords");
              _textStreamController.add(recognizedWords);
            }
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
      );
      
      _listeningStatusController.add(_isListening);
    }
  }

  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      _listeningStatusController.add(false);
    }
  }

  void dispose() {
    stopListening();
    _textStreamController.close();
    _listeningStatusController.close();
  }
}