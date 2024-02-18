import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/classes/sprite.dart';

import '../../io/create_directory_if_not_exists.dart';
import 'map_sprite_sheet_to_json.dart';

String exportSprite({
  required Sprite sprite,
  required String directory,
  required String name,
}) {
  createDirectoryIfNotExists(directory);
  final dstImageBytes = encodePng(sprite.image);
  final outputName = '$directory/$name';
  final spriteSheetJson = mapSpriteToJson(sprite);
  final jsonStr = json.encode(spriteSheetJson);
  File('$outputName.json').writeAsStringSync(jsonStr);
  File('$outputName.png').writeAsBytesSync(dstImageBytes, flush: true);
  return outputName;
}


