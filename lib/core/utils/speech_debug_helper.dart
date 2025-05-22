// lib/core/utils/speech_debug_helper.dart - Para debugging

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechDebugHelper {
  static Future<void> debugSpeechCapabilities() async {
    final speech = stt.SpeechToText();
    
    try {
      print("=== DEBUGGING SPEECH CAPABILITIES ===");
      
      // Verificar si el speech-to-text está disponible
      bool available = await speech.initialize();
      print("Speech-to-text disponible: $available");
      
      if (!available) {
        print("Speech-to-text NO está disponible en este dispositivo");
        return;
      }
      
      // Verificar si hay micrófonos disponibles
      bool hasPermission = await speech.hasPermission;
      print("Permiso de micrófono: $hasPermission");
      
      // Obtener todos los locales disponibles
      List<stt.LocaleName> locales = await speech.locales();
      print("Total de locales disponibles: ${locales.length}");
      
      // Filtrar locales españoles
      List<stt.LocaleName> spanishLocales = locales
          .where((locale) => locale.localeId.startsWith('es'))
          .toList();
      
      print("\n=== LOCALES ESPAÑOLES DISPONIBLES ===");
      if (spanishLocales.isEmpty) {
        print("❌ NO se encontraron locales españoles");
        print("Esto puede significar que:");
        print("- El dispositivo no tiene el idioma español instalado");
        print("- Los servicios de Google no incluyen español");
        print("- Hay un problema con la configuración del dispositivo");
      } else {
        print("✅ Se encontraron ${spanishLocales.length} locales españoles:");
        for (var locale in spanishLocales) {
          print("  📍 ${locale.localeId}: ${locale.name}");
        }
      }
      
      // Mostrar todos los locales para comparación
      print("\n=== TODOS LOS LOCALES DISPONIBLES ===");
      Map<String, List<stt.LocaleName>> localesByLanguage = {};
      
      for (var locale in locales) {
        String language = locale.localeId.split('-')[0];
        if (!localesByLanguage.containsKey(language)) {
          localesByLanguage[language] = [];
        }
        localesByLanguage[language]!.add(locale);
      }
      
      localesByLanguage.forEach((language, localeList) {
        print("$language: ${localeList.length} variantes");
        for (var locale in localeList.take(3)) { // Solo mostrar las primeras 3
          print("  - ${locale.localeId}: ${locale.name}");
        }
        if (localeList.length > 3) {
          print("  ... y ${localeList.length - 3} más");
        }
      });
      
      print("\n=== RECOMENDACIONES ===");
      if (spanishLocales.isEmpty) {
        print("🔧 Para solucionar el problema:");
        print("1. Verificar idioma del sistema en Configuración > Idioma");
        print("2. Descargar paquete de idioma español en Google");
        print("3. Verificar que Google Assistant esté en español");
        print("4. Reiniciar la aplicación después de cambios");
      } else {
        print("✅ Configuración correcta para español");
        print("Locale recomendado: ${spanishLocales.first.localeId}");
      }
      
      print("==========================================");
      
    } catch (e) {
      print("Error durante el debugging: $e");
    }
  }
}