// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/widgets/voice_assistant_overlay.dart';

// GlobalKey para acceso al navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Biblioteca UAGRM',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // Agregar el navigatorKey
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: appRoutes,
          onGenerateRoute: onGenerateRoute,
          builder: (context, child) {
            // Envolvemos la aplicación con el overlay del asistente de voz
            return VoiceAssistantOverlay(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}