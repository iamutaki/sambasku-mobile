import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Capture [RepaintBoundary] → PNG bytes.
Future<Uint8List> captureShareCardPngBytes(GlobalKey repaintKey) async {
  final boundary =
      repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw StateError('Kartu share belum siap digambar');
  }

  final image = await boundary.toImage(pixelRatio: 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Gagal encode PNG');
  }
  return byteData.buffer.asUint8List();
}

/// Render [RepaintBoundary] → PNG temp → native share sheet.
Future<void> shareCardAsPng({
  required GlobalKey repaintKey,
  required String caption,
  required Rect sharePositionOrigin,
}) async {
  final bytes = await captureShareCardPngBytes(repaintKey);

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/sambasku-share-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(bytes, flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: caption,
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}

/// Render [RepaintBoundary] → simpan PNG ke galeri perangkat.
///
/// Throws [StateError] jika render gagal, atau [GalException] dari plugin.
/// Returns `false` jika user menolak izin galeri.
Future<bool> saveCardToGallery({required GlobalKey repaintKey}) async {
  final granted = await Gal.requestAccess();
  if (!granted) return false;

  final bytes = await captureShareCardPngBytes(repaintKey);
  final name = 'sambasku-share-${DateTime.now().millisecondsSinceEpoch}';
  await Gal.putImageBytes(bytes, name: name);
  return true;
}
