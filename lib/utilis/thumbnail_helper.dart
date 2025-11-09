import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:js_util' as js_util;

/// Returns thumbnail bytes (Uint8List) or null on failure
Future<Uint8List?> generateThumbnailWeb(html.File videoFile) async {
  if (!kIsWeb) return null;

  try {
    // Call the global JS function
    final blob = await js_util.promiseToFuture<html.Blob>(
      js_util.callMethod(html.window, 'generateVideoThumbnail', [videoFile]),
    );

    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is Uint8List) {
        completer.complete(result);
      } else {
        completer.completeError('FileReader result is not Uint8List');
      }
    });

    reader.onError.listen(completer.completeError);
    reader.readAsArrayBuffer(blob);
    return completer.future;
  } catch (e) {
    debugPrint('Thumbnail error: $e');
    return null;
  }
}