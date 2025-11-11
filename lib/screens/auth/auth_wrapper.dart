// lib/screens/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import 'login_screen.dart';
import '../dashboard/dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Verificar si ya hay una sesión activa
    context.read<AuthBloc>().add(CheckAuthEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Manejar errores
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Mostrar éxito al crear miembro
        if (state is MiembroCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Perfil de miembro creado exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        // Mostrar loading
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando...'),
                ],
              ),
            ),
          );
        }

        // Usuario autenticado -> Dashboard
        if (state is Authenticated) {
          return DashboardScreen(
            user: state.user,
            miembro: state.miembro,
          );
        }

        // Usuario no autenticado -> Login
        return const LoginScreen();
      },
    );
  }
}