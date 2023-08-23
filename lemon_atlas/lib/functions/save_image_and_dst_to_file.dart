import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart';
import 'package:lemon_atlas/functions/build_atlas.dart';

import 'create_directory_if_not_exists.dart';
import 'map_sprite_sheet_to_json.dart';

void exportSpriteSheet(SpriteSheet spriteSheet, String directory, String name) async {
  await createDirectoryIfNotExists(directory);
  final dstImageBytes = encodePng(spriteSheet.image);
  final outputName = '$directory/$name';
  final spriteSheetJson = mapSpriteSheetToJson(spriteSheet);
  final jsonStr = json.encode(spriteSheetJson);
  File('$outputName.json').writeAsStringSync(jsonStr);
  File('$outputName.png').writeAsBytes(dstImageBytes);
}


