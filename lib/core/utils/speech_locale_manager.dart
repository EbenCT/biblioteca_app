// lib/core/utils/speech_locale_manager.dart

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechLocaleManager {
  static Future<void> forceConfigure() async {
    final speech = stt.SpeechToText();
    
    try {
      print("🔧 CONFIGURACIÓN FORZADA DE ESPAÑOL");
      
      // Inicializar
      bool available = await speech.initialize();
      if (!available) {
        print("❌ Speech-to-text no disponible");
        return;
      }
      
      // Obtener locales
      List<stt.LocaleName> locales = await speech.locales();
      print("📱 Total de locales en el dispositivo: ${locales.length}");
      
      // Filtrar españoles
      List<stt.LocaleName> spanishLocales = locales
          .where((locale) => locale.localeId.startsWith('es'))
          .toList();
      
      print("🇪🇸 Locales españoles encontrados: ${spanishLocales.length}");
      for (var locale in spanishLocales) {
        print("   - ${locale.localeId}: ${locale.name}");
      }
      
      if (spanishLocales.isEmpty) {
        print("💡 SOLUCIÓN: No hay locales españoles instalados");
        print("   1. Ve a Configuración → Idioma y región");
        print("   2. Agrega 'Español' como idioma");
        print("   3. Descarga el paquete de reconocimiento de voz");
        print("   4. Reinicia la aplicación");
        return;
      }
      
      // Probar cada locale español con una frase de prueba
      print("\n🧪 PROBANDO LOCALES ESPAÑOLES:");
      
      for (var locale in spanishLocales) {
        bool testResult = await _testLocale(speech, locale.localeId);
        print("${testResult ? '✅' : '❌'} ${locale.localeId}: ${testResult ? 'FUNCIONA' : 'FALLA'}");
        
        if (testResult) {
          print("🎯 RECOMENDADO: Usar ${locale.localeId}");
          break;
        }
      }
      
      // Verificar configuración del sistema
      await _checkSystemConfiguration();
      
    } catch (e) {
      print("❌ Error en configuración forzada: $e");
    }
  }
  
  static Future<bool> _testLocale(stt.SpeechToText speech, String localeId) async {
    try {
      bool success = false;
      
      await speech.listen(
        localeId: localeId,
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            success = true;
          }
        },
        listenFor: const Duration(seconds: 2),
        cancelOnError: false,
      );
      
      // Esperar un momento para el resultado
      await Future.delayed(const Duration(seconds: 3));
      speech.stop();
      
      return success;
    } catch (e) {
      return false;
    }
  }
  
  static Future<void> _checkSystemConfiguration() async {
    print("\n🔍 VERIFICACIÓN DEL SISTEMA:");
    print("📋 Pasos para configurar español correctamente:");
    print("   1. Abrir Configuración del dispositivo");
    print("   2. Ir a 'Idioma y región' o 'Language & Input'");
    print("   3. Asegurar que 'Español' esté en la lista");
    print("   4. En 'Idiomas de entrada', habilitar español");
    print("   5. Descargar 'Paquete de idioma offline' para español");
    print("   6. En Google App → Configuración → Voz → Reconocimiento");
    print("   7. Seleccionar 'Español' como idioma principal");
    print("   8. Entrenar Voice Match en español si está disponible");
  }
  
  static Future<String?> getBestSpanishLocale() async {
    final speech = stt.SpeechToText();
    
    try {
      bool available = await speech.initialize();
      if (!available) return null;
      
      List<stt.LocaleName> locales = await speech.locales();
      
      // Prioridad de locales españoles
      final priorities = ['es-ES', 'es_ES', 'es-MX', 'es_MX', 'es-US', 'es_US'];
      
      for (String priority in priorities) {
        for (var locale in locales) {
          if (locale.localeId == priority) {
            print("🎯 Locale español óptimo encontrado: ${locale.localeId}");
            return locale.localeId;
          }
        }
      }
      
      // Si no encuentra ninguno prioritario, usar el primero español disponible
      for (var locale in locales) {
        if (locale.localeId.startsWith('es')) {
          print("🎯 Usando primer locale español disponible: ${locale.localeId}");
          return locale.localeId;
        }
      }
      
      return null;
    } catch (e) {
      print("Error obteniendo locale español: $e");
      return null;
    }
  }
}