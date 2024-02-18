
import 'package:lemon_atlas/atlas/classes/sprite.dart';

Map<String, dynamic> mapSpriteToJson(Sprite sprite) => <String, dynamic> {
    'width': sprite.spriteWidth,
    'height': sprite.spriteHeight,
    'rows': sprite.rows,
    'columns': sprite.columns,
    'dst': sprite.dst,
    'src': sprite.src,
};