
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/classes/sprite.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

import 'load_file_bytes.dart';
import 'load_file_string.dart';

Future<Sprite?> loadFileSprite() async {

  final file = await loadFileFromDisk(allowedExtensions: ['*']);
  if (file == null) {
    return null;
  }

  final path = file.path;
  if (path == null){
    return null;
  }

  final name = path.replaceAll('.${file.extension}', '');
  final imageBytes = await loadFileBytes('$name.png');
  final text = await loadFileString('$name.json');
  final json = jsonDecode(text);

  return Sprite(
      spriteWidth: json['width'] as int,
      spriteHeight: json['height'] as int,
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      image: decodePng(imageBytes) ?? (throw Exception()),
      src: Uint16List.fromList((json['src'] as List).map((e) => e as int).toList(growable: false)),
      dst: Uint16List.fromList((json['dst'] as List).map((e) => e as int).toList(growable: false)),
  );
}