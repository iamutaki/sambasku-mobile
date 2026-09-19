import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> pickedPersistDir() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory(p.join(base.path, 'picked_files'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

/// Copies [source] into app persist dir so picker/cache paths don't vanish.
/// If [source] is already inside the persist dir, return it as-is.
Future<File> copyToUniqueTempPath(File source) async {
  final dir = await pickedPersistDir();

  if (p.isWithin(dir.path, source.path)) {
    if (await source.exists() && await source.length() > 0) return source;
    throw StateError('Persisted file missing or empty: ${source.path}');
  }

  final destPath = p.join(
    dir.path,
    'pick_${DateTime.now().microsecondsSinceEpoch}_${p.basename(source.path)}',
  );

  try {
    final copied = await source.copy(destPath);
    if (await copied.length() > 0) return copied;
  } catch (_) {
    // fall through to byte-copy
  }

  final bytes = await source.readAsBytes();
  if (bytes.isEmpty) throw StateError('Picked file is empty');
  final dest = File(destPath);
  await dest.writeAsBytes(bytes, flush: true);
  return dest;
}
