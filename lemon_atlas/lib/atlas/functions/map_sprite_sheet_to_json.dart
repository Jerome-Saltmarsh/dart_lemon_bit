
import 'package:lemon_atlas/atlas/classes/sprite.dart';

Map<String, dynamic> mapSpriteToJson(Sprite sprite){
  final json = <String, dynamic>{};
  json['sprite_width'] = sprite.spriteWidth;
  json['sprite_height'] = sprite.spriteHeight;
  json['rows'] = sprite.rows;
  json['columns'] = sprite.columns;
  json['dst'] = sprite.dst;
  json['src'] = sprite.src;
  return json;
}