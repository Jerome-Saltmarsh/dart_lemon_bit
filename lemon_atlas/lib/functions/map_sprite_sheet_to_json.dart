
import 'build_atlas.dart';

Map<String, dynamic> mapSpriteSheetToJson(SpriteSheet spriteSheet){
  final json = <String, dynamic>{};
  json['sprite_width'] = spriteSheet.spriteWidth;
  json['sprite_height'] = spriteSheet.spriteHeight;
  json['rows'] = spriteSheet.rows;
  json['columns'] = spriteSheet.columns;
  json['dst'] = spriteSheet.dst;
  json['src'] = spriteSheet.src;
  return json;
}