// lib/core/services/tts_service.dart (MEJORADO - async/await correcto)

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
      await _flutterTts.setSpeechRate(0.5); // Más lento para mejor comprensión
      await _flutterTts.setVolume(0.8);
      
      // CORREGIDO: Configurar callbacks correctamente
      _flutterTts.setCompletionHandler(() {
        print("✅ TTS completado");
        _isSpeaking = false;
        _speechCompleter?.complete();
        _speechCompleter = null;
      });
      
      _flutterTts.setStartHandler(() {
        print("🔊 TTS iniciado");
        _isSpeaking = true;
      });
      
      _flutterTts.setErrorHandler((message) {
        print("❌ Error en TTS: $message");
        _isSpeaking = false;
        _speechCompleter?.completeError("TTS Error: $message");
        _speechCompleter = null;
      });
      
      // NUEVO: Handler para cuando se cancela
      _flutterTts.setCancelHandler(() {
        print("🛑 TTS cancelado");
        _isSpeaking = false;
        _speechCompleter?.complete();
        _speechCompleter = null;
      });
      
      _isInitialized = true;
      print("✅ TTS inicializado correctamente");
      
    } catch (e) {
      print("❌ Error inicializando TTS: $e");
      _isInitialized = false;
    }
  }

  // CORREGIDO: Método speak que realmente espera a que termine
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      print("⚠️ TTS no inicializado, inicializando...");
      await _init();
    }
    
    if (text.trim().isEmpty) {
      print("⚠️ Texto vacío para TTS");
      return;
    }
    
    // Parar cualquier TTS anterior
    if (_isSpeaking) {
      print("🛑 Parando TTS anterior...");
      await stop();
    }
    
    try {
      print("🔊 TTS reproduciendo: '$text'");
      
      // Crear un completer para esperar a que termine
      _speechCompleter = Completer<void>();
      
      // Iniciar TTS
      _isSpeaking = true;
      final result = await _flutterTts.speak(text);
      
      if (result == 1) {
        // TTS inició correctamente, esperar a que termine
        await _speechCompleter!.future.timeout(
          Duration(seconds: text.length ~/ 2 + 10), // Timeout basado en longitud del texto
          onTimeout: () {
            print("⏰ TTS timeout, forzando completado");
            _isSpeaking = false;
            _speechCompleter = null;
          },
        );
      } else {
        print("❌ TTS no pudo iniciar");
        _isSpeaking = false;
        _speechCompleter = null;
      }
      
      print("✅ TTS completado para: '$text'");
      
    } catch (e) {
      print("❌ Error al reproducir TTS: $e");
      _isSpeaking = false;
      _speechCompleter?.completeError(e);
      _speechCompleter = null;
    }
  }

  // CORREGIDO: Método stop que realmente para el TTS
  Future<void> stop() async {
    if (_isSpeaking) {
      print("🛑 Deteniendo TTS...");
      
      try {
        await _flutterTts.stop();
        _isSpeaking = false;
        
        // Completar el completer si existe
        if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
          _speechCompleter!.complete();
        }
        _speechCompleter = null;
        
        print("✅ TTS detenido");
        
        // Agregar delay para asegurar que se detuvo completamente
        await Future.delayed(const Duration(milliseconds: 100));
        
      } catch (e) {
        print("❌ Error al detener TTS: $e");
        _isSpeaking = false;
        _speechCompleter = null;
      }
    }
  }

  bool get isSpeaking => _isSpeaking;

  void dispose() {
    print("🗑️ Limpiando TTS...");
    _flutterTts.stop();
    _speechCompleter?.complete();
    _speechCompleter = null;
    _isSpeaking = false;
  }
}