import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';
import 'package:lemon_engine/render.dart';

void renderGameObject(GameObject value) {

  if (value.type == GameObjectType.Rock)
    return render(
       dstX: value.renderX,
       dstY: value.renderY,
       srcX: 1664,
       srcY: value.shade * 16,
       srcWidth: 16,
       srcHeight: 16,
    );

  if (value.type == GameObjectType.Flower)
    return render(
      dstX: value.renderX,
      dstY: value.renderY,
      srcX: 1680,
      srcY: value.shade * 16,
      srcWidth: 16,
      srcHeight: 16,
    );
}
