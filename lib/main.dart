// lib/main.dart - Con inicialización de servicios

import 'package:flutter/material.dart';
import 'services/graphql_service.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  // Inicializar Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicios
  await GraphQLService.initialize();
  await NotificationService.initialize();
  
  runApp(const App());
}