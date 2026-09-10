import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

/// Compression changes storage only; it never changes authored content.
Future<String> readDesignAsset(String path) async {
  if (!path.endsWith('.gz')) return rootBundle.loadString(path);
  final bytes = await rootBundle.load(path);
  return utf8.decode(
    const GZipDecoder().decodeBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    ),
  );
}
