// lib/main.dart (versión final)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'di/injection_container.dart' as di;
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/book/book_bloc.dart';
import 'presentation/bloc/chat/chat_bloc.dart';
import 'presentation/bloc/loan/loan_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/bloc/reservation/reservation_bloc.dart';
import 'core/providers/voice_navigation_provider.dart';
import 'core/controllers/notification_controller.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await NotificationController.instance.initialize();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<BookBloc>()),
        BlocProvider(create: (_) => di.sl<LoanBloc>()),
        BlocProvider(create: (_) => di.sl<ReservationBloc>()),
        BlocProvider(create: (_) => di.sl<NotificationBloc>()),
        BlocProvider(create: (_) => di.sl<ChatBloc>()),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
          ChangeNotifierProvider(create: (context) => VoiceNavigationProvider()),
        ],
        child: Builder(
          builder: (context) {
            // Inicializar el proveedor de navegación por voz
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<VoiceNavigationProvider>(context, listen: false)
                .initialize(context);
            });
            
            return const App();
          }
        ),
      ),
    );
  }
}