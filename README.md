# Aplicación Móvil de Biblioteca UAGRM

## Descripción del Proyecto

Esta aplicación móvil para la gestión de bibliotecas está diseñada para la Universidad Autónoma Gabriel René Moreno (UAGRM). Permite a los usuarios (lectores) consultar el catálogo de libros, gestionar préstamos, hacer reservas, escribir reseñas y comunicarse con el personal de la biblioteca a través de un asistente virtual.

## Características Implementadas

1. **Autenticación de Usuarios**
   - Registro, inicio de sesión y recuperación de contraseña
   - Gestión de perfil de usuario

2. **Catálogo de Libros**
   - Visualización de libros disponibles
   - Búsqueda por título, autor, categoría o tipo
   - Detalles completos de cada libro
   - Recomendaciones personalizadas

3. **Gestión de Préstamos**
   - Visualización de préstamos activos e historial
   - Detalles de cada préstamo incluido fechas y multas

4. **Sistema de Reservas**
   - Reserva de libros no disponibles
   - Cancelación de reservas
   - Seguimiento del estado de las reservas

5. **Reseñas y Calificaciones**
   - Lectura de reseñas de otros usuarios
   - Publicación de reseñas propias
   - Sistema de votación para reseñas útiles

6. **Asistente Virtual**
   - Chat interactivo para consultas
   - Funcionalidades para preguntar por disponibilidad de libros

7. **Interfaz de Usuario**
   - Diseño minimalista y moderno
   - Soporte para modo oscuro
   - Interfaz adaptativa y responsive

## Arquitectura

El proyecto sigue la arquitectura Clean Code con una clara separación de responsabilidades:

- **Domain**: Contiene las entidades de negocio, los casos de uso y las interfaces de repositorios.
- **Data**: Implementación de repositorios, fuentes de datos y modelos.
- **Presentation**: Capa de UI que incluye widgets, páginas y BLoCs para la gestión del estado.
- **Core**: Utilidades comunes, constantes y manejo de errores.
- **DI**: Contenedor de inyección de dependencias.

## Tecnologías Utilizadas

- **Flutter**: Framework para desarrollo multiplataforma
- **BLoC Pattern**: Para la gestión del estado de la aplicación
- **Clean Architecture**: Para una separación clara de responsabilidades
- **GraphQL**: Para la comunicación con la API del backend (simulada localmente por ahora)
- **Provider**: Para la gestión del tema claro/oscuro

## Cómo Continuar la Implementación

Para continuar con la implementación real de esta aplicación, sigue estos pasos:

1. **Configuración del Entorno**
   - Asegúrate de tener Flutter 3.10.0 o superior instalado
   - Ejecuta `flutter pub get` para instalar las dependencias

2. **Integración con Backend Real**
   - Reemplaza los datos estáticos (mock_data.dart) con llamadas reales a la API GraphQL
   - Implementa un cliente GraphQL en la capa de datos

3. **Implementación de Imágenes**
   - Configura Cloudinary u otro servicio de alojamiento de imágenes
   - Añade las URLs correctas para las imágenes de portada de los libros

4. **Autenticación Real**
   - Integra JWT u otro sistema de autenticación
   - Implementa almacenamiento seguro para tokens de sesión

5. **Funcionalidades Adicionales**
   - Implementa notificaciones push para recordatorios de devolución
   - Agrega la funcionalidad de escaneo de códigos QR/barras para libros
   - Implementa el sistema de recomendaciones con TensorFlow

## Estructura de Archivos Principal

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── mock_data.dart
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/
├── di/
└── main.dart
```

## Flujo de la Aplicación

1. El usuario abre la app y es recibido por la pantalla de splash
2. Si no hay sesión, se muestra la pantalla de login
3. Al iniciar sesión, se muestra la página principal con el catálogo de libros y recomendaciones
4. El usuario puede navegar por las diferentes secciones: Buscar, Préstamos, Reservas y Chat
5. El usuario puede ver detalles de libros, hacer reservas y consultar su perfil

## Consideraciones para la Implementación Real

- **Seguridad**: Implementa medidas de seguridad para proteger los datos del usuario
- **Rendimiento**: Optimiza las consultas a la API y el almacenamiento en caché
- **Testeo**: Añade pruebas unitarias, de integración y de widgets
- **Accesibilidad**: Asegúrate de que la aplicación sea accesible para todos los usuarios
- **Internacionalización**: Prepara la app para múltiples idiomas si es necesario

## Notas Adicionales

- La aplicación está diseñada pensando en escalabilidad y mantenibilidad
- El código está comentado para facilitar su comprensión
- Se han seguido las mejores prácticas de desarrollo con Flutter
- La estructura del proyecto permite agregar nuevas funcionalidades fácilmente