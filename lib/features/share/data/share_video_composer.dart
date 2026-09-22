import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ShareVideoComposer {
  ShareVideoComposer._();

  static const _channel = MethodChannel('sambasku/share_video');

  static Future<String> compose({
    required String videoPath,
    required String overlayPngPath,
    int maxSeconds = 15,
  }) async {
    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/sambasku-share-${DateTime.now().millisecondsSinceEpoch}.mp4';
    final result = await _channel.invokeMethod<String>('compose', {
      'videoPath': videoPath,
      'overlayPngPath': overlayPngPath,
      'outputPath': outPath,
      'maxSeconds': maxSeconds,
    });
    if (result == null || result.isEmpty) {
      throw StateError('Gagal compose video');
    }
    return result;
  }
}
