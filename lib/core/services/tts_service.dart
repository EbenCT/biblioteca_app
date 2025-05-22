// lib/core/services/tts_service.dart (mejorado con async/await)

import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;
  Completer<void>? _speechCompleter;

  TTSService() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Obtener idiomas disponibles
      List<dynamic> languages = await _flutterTts.getLanguages;
      print("Idiomas TTS disponibles: $languages");
      
      // Buscar el mejor idioma español disponible
      String? selectedLanguage;
      final preferredLanguages = ['es-ES', 'es-MX', 'es-AR', 'es-CO', 'es-US', 'es'];
      
      for (String preferred in preferredLanguages) {
        if (languages.contains(preferred)) {
          selectedLanguage = preferred;
          print("Usando idioma TTS: $selectedLanguage");
          break;
        }
      }
      
      // Si no encuentra español, usar el primero que empiece con 'es'
      if (selectedLanguage == null) {
        for (String lang in languages.cast<String>()) {
          if (lang.startsWith('es')) {
            selectedLanguage = lang;
            print("Usando idioma TTS alternativo: $selectedLanguage");
            break;
          }
        }
      }
      
      // Configurar el idioma
      if (selectedLanguage != null) {
        await _flutterTts.setLanguage(selectedLanguage);
      } else {
        print("No se encontró idioma español para TTS, usando configuración por defecto");
        await _flutterTts.setLanguage('es-ES');
      }
      
      // Configurar otros parámetros
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.6); // Ligeramente más rápido
      await _flutterTts.setVolume(0.8);
      
      // Configurar callbacks con Completer para async/await
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        print("TTS completado");
        _speechCompleter?.complete();
        _speechCompleter = null;
      });
      
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        print("TTS iniciado");
      });
      
      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        print("Error en TTS: $message");
        _speechCompleter?.completeError("TTS Error: $message");
        _speechCompleter = null;
      });
      
      _isInitialized = true;
      print("TTS inicializado correctamente");
      
    } catch (e) {
      print("Error inicializando TTS: $e");
      _isInitialized = false;
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await _init();
    }
    
    // Parar cualquier TTS anterior
    if (_isSpeaking) {
      await stop();
    }
    
    try {
      print("TTS reproduciendo: $text");
      
      // Crear un completer para esperar a que termine
      _speechCompleter = Completer<void>();
      
      _isSpeaking = true;
      await _flutterTts.speak(text);
      
      // Esperar a que termine de hablar
      await _speechCompleter!.future;
      
    } catch (e) {
      print("Error al reproducir TTS: $e");
      _isSpeaking = false;
      _speechCompleter = null;
    }
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
      _speechCompleter?.complete(); // Completar si estaba esperando
      _speechCompleter = null;
      print("TTS detenido");
    }
  }

  bool get isSpeaking => _isSpeaking;

  void dispose() {
    _flutterTts.stop();
    _speechCompleter?.complete();
  }
}