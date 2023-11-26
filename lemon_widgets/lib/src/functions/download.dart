import 'package:universal_html/html.dart' as html;
import 'dart:convert';

void downloadString({
  required String contents,
  required String filename,
}) =>
    downloadBytes(
      bytes: utf8.encode(contents),
      name: filename,
    );

void downloadBytes({
  required List<int> bytes,
  required String name,
}) {
  final base64 = base64Encode(bytes);
  final anchor = html.AnchorElement(
      href: 'data:application/octet-stream;base64,$base64'
  )
    ..target = 'blank';
  anchor.download = name;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}