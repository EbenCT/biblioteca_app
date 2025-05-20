// lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/widgets/voice_assistant_overlay.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Biblioteca UAGRM',
          debugShowCheckedModeBanner: false,
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