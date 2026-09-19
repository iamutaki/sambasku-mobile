import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void showPermissionDeniedDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (innerContext) {
      return AlertDialog(
        title: const Text('Izin Ditolak'),
        content: const Text(
          'Untuk menggunakan fitur ini, Anda perlu mengizinkan akses '
          'ke galeri atau kamera dari pengaturan aplikasi.',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(innerContext).pop(),
          ),
          TextButton(
            child: const Text('Pengaturan'),
            onPressed: () {
              openAppSettings();
              Navigator.of(innerContext).pop();
            },
          ),
        ],
      );
    },
  );
}
