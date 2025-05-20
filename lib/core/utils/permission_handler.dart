// lib/core/utils/permission_handler.dart

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class AppPermissionHandler {
  // Verifica y solicita permiso de micrófono
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        return true;
      }
    }
    
    // Si el permiso fue denegado permanentemente o la solicitud fue denegada
    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context, 'micrófono');
    } else {
      _showPermissionDeniedDialog(context, 'micrófono');
    }
    
    return false;
  }
  
  // Muestra un diálogo cuando el permiso es denegado
  static void _showPermissionDeniedDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso de $permissionName requerido'),
          content: Text('Esta funcionalidad necesita acceso al $permissionName para funcionar correctamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Permission.microphone.request();
              },
              child: const Text('Solicitar permiso'),
            ),
          ],
        );
      },
    );
  }
  
  // Muestra un diálogo cuando el permiso es denegado permanentemente
  static void _showPermanentlyDeniedDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso de $permissionName denegado'),
          content: Text(
            'El permiso de $permissionName ha sido denegado permanentemente. '
            'Para utilizar esta función, debes habilitarlo en la configuración de la aplicación.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Ir a configuración'),
            ),
          ],
        );
      },
    );
  }
}