// lib/core/utils/device_config_checker.dart

class DeviceConfigChecker {
  static void printConfigurationGuide() {
    print("""
🔧 GUÍA DE CONFIGURACIÓN PARA RECONOCIMIENTO EN ESPAÑOL

El dispositivo sigue reconociendo en inglés. Aquí están las soluciones:

📱 CONFIGURACIÓN DEL DISPOSITIVO:
1. Ir a Configuración → Idioma y región
2. Agregar 'Español' como idioma preferido
3. Moverlo al primer lugar en la lista
4. Reiniciar el dispositivo

🗣️ GOOGLE VOICE SETTINGS:
1. Abrir Google App
2. Ir a Configuración → Voz
3. En 'Idiomas', seleccionar 'Español'
4. Descargar 'Paquete offline para español'
5. Activar 'Reconocimiento de voz offline'

🎙️ GOOGLE ASSISTANT:
1. Abrir Google Assistant
2. Ir a Configuración → Idiomas
3. Agregar 'Español' como idioma principal
4. Entrenar Voice Match en español

⚙️ SPEECH SERVICES:
1. Ir a Configuración → Aplicaciones
2. Buscar 'Speech Services by Google'
3. Configurar idioma predeterminado como 'Español'

🔄 PASOS ADICIONALES:
1. Desinstalar y reinstalar Google App
2. Limpiar caché de Speech Services
3. Verificar que el micrófono funcione correctamente
4. Probar con otras apps de reconocimiento de voz

❗ IMPORTANTE:
- Después de cada cambio, reiniciar la aplicación
- Algunos cambios requieren reiniciar el dispositivo
- El problema suele estar en la configuración del sistema Android
- No es un problema de la aplicación, sino del dispositivo

✅ PRUEBA RÁPIDA:
1. Abrir Google Assistant
2. Decir algo en español
3. Verificar que reconozca correctamente
4. Si funciona en Assistant, debería funcionar en la app
""");
  }
  
  static Map<String, String> getQuickFixes() {
    return {
      'Configuración rápida': 'Configuración → Idioma → Agregar Español → Reiniciar',
      'Google Voice': 'Google App → Configuración → Voz → Español → Offline',
      'Assistant': 'Google Assistant → Configuración → Idiomas → Español',
      'Speech Services': 'Configuración → Apps → Speech Services → Español',
      'Prueba final': 'Reiniciar dispositivo y probar Google Assistant',
    };
  }
}