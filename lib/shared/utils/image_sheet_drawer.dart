import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'file_persist_helper.dart';
import 'permission_helper.dart';

enum PhotoPickSource { camera, gallery, file }

/// Shows the "Pilih Sumber" bottom sheet.
void showImageSheetDrawer(
  BuildContext context, {
  ImagePicker? picker,
  Function(XFile image)? onImagePicked,
  Function(XFile image)? onCameraCaptured,
  Function(File image)? onFilePicked,
  Function(File image)? onPicked,
  Function(File image, PhotoPickSource source)? onPickedWithSource,
  Function()? onRemoved,
  bool cameraPicker = true,
  bool galleryPicker = true,
  bool filePicker = true,
  bool requireGpsForCamera = false,
}) {
  final imagePicker = picker ?? ImagePicker();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Sumber',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                children: [
                  if (cameraPicker)
                    _SourceButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Kamera',
                      onTap: () => openCamera(
                        sheetContext,
                        imagePicker,
                        (xfile) {
                          final file = File(xfile.path);
                          onCameraCaptured?.call(xfile);
                          onPickedWithSource?.call(file, PhotoPickSource.camera);
                          onPicked?.call(file);
                        },
                      ),
                    ),
                  if (galleryPicker)
                    _SourceButton(
                      icon: Icons.photo_outlined,
                      label: 'Galeri',
                      onTap: () => pickImageFromGallery(
                        sheetContext,
                        imagePicker,
                        (xfile) {
                          final file = File(xfile.path);
                          onImagePicked?.call(xfile);
                          onPickedWithSource?.call(
                            file,
                            PhotoPickSource.gallery,
                          );
                          onPicked?.call(file);
                        },
                      ),
                    ),
                  if (filePicker)
                    _SourceButton(
                      icon: Icons.insert_drive_file_outlined,
                      label: 'File',
                      onTap: () => pickImageFromFile(
                        sheetContext,
                        (file) {
                          onFilePicked?.call(file);
                          onPickedWithSource?.call(file, PhotoPickSource.file);
                          onPicked?.call(file);
                        },
                      ),
                    ),
                  _SourceButton(
                    icon: Icons.restart_alt,
                    label: 'Reset',
                    onTap: () => onRemoved?.call(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> openCamera(
  BuildContext context,
  ImagePicker picker,
  Function(XFile) onSuccess,
) async {
  try {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (context.mounted) showPermissionDeniedDialog(context);
      return;
    }

    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final persisted = await copyToUniqueTempPath(File(picked.path));
    onSuccess(XFile(persisted.path));
    if (context.mounted) Navigator.of(context).pop();
  } catch (e, st) {
    debugPrint('[Camera] $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka kamera')),
      );
    }
  }
}

Future<void> pickImageFromGallery(
  BuildContext context,
  ImagePicker picker,
  Function(XFile) onSuccess,
) async {
  try {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final persisted = await copyToUniqueTempPath(File(picked.path));
    onSuccess(XFile(persisted.path));
    if (context.mounted) Navigator.of(context).pop();
  } catch (e, st) {
    debugPrint('[Gallery] $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih dari galeri')),
      );
    }
  }
}

Future<void> pickImageFromFile(
  BuildContext context,
  Function(File) onSuccess,
) async {
  try {
    final platformFile = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
    );
    if (platformFile == null) return;

    File source;
    final path = platformFile.path;
    if (path != null && path.isNotEmpty) {
      source = File(path);
    } else {
      final bytes = await platformFile.readAsBytes();
      if (bytes.isEmpty) return;
      final dir = await pickedPersistDir();
      source = File(
        '${dir.path}/pick_${DateTime.now().microsecondsSinceEpoch}_${platformFile.name}',
      );
      await source.writeAsBytes(bytes, flush: true);
    }

    final persisted = await copyToUniqueTempPath(source);
    onSuccess(persisted);
    if (context.mounted) Navigator.of(context).pop();
  } catch (e, st) {
    debugPrint('[ImageSheet] file pick $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memilih file')),
      );
    }
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
