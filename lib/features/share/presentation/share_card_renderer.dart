import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Render [RepaintBoundary] → PNG temp → native share sheet.
Future<void> shareCardAsPng({
  required GlobalKey repaintKey,
  required String caption,
  required Rect sharePositionOrigin,
}) async {
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

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/sambasku-share-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: caption,
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}
