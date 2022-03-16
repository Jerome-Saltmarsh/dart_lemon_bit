

import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:bleed_common/enums/ObjectType.dart';
import 'package:bleed_common/enums/Shade.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';


final _translations = _Translations();
final _torchHeight = environmentObjectHeight[ObjectType.Torch]!;

const Map<ObjectType, double> environmentObjectWidth = {
  ObjectType.Palisade: 48,
  ObjectType.Palisade_H: 48,
  ObjectType.Palisade_V: 48,
  ObjectType.Rock_Wall: 48,
  ObjectType.Rock: 48,
  ObjectType.Grave: 48,
  ObjectType.Tree_Stump: 48,
  ObjectType.Rock_Small: 48,
  ObjectType.LongGrass: 48,
  ObjectType.Torch: 25,
  ObjectType.Tree01: 96,
  ObjectType.House01: 150,
  ObjectType.House02: 150,
  ObjectType.MystEmitter: 48
};

const Map<ObjectType, double> environmentObjectHeight = {
  ObjectType.Palisade: 100,
  ObjectType.Palisade_H: 100,
  ObjectType.Palisade_V: 100,
  ObjectType.Rock_Wall: 100,
  ObjectType.Rock: 48,
  ObjectType.Grave: 48,
  ObjectType.Tree_Stump: 48,
  ObjectType.Rock_Small: 48,
  ObjectType.LongGrass: 48,
  ObjectType.Torch: 70,
  ObjectType.Tree01: 96,
  ObjectType.House01: 150,
  ObjectType.House02: 150,
  ObjectType.MystEmitter: 48
};

const Map<ObjectType, int> environmentObjectIndex = {
  ObjectType.Rock: 0,
  ObjectType.Grave: 1,
  ObjectType.Tree_Stump: 2,
  ObjectType.Rock_Small: 3,
  ObjectType.LongGrass: 4,
  ObjectType.Torch: 0,
  ObjectType.Tree01: 0,
  ObjectType.House01: 0,
  ObjectType.House02: 1,
  ObjectType.Palisade: 0,
  ObjectType.Palisade_H: 1,
  ObjectType.Palisade_V: 2,
  ObjectType.MystEmitter: 0,
  ObjectType.Rock_Wall: 0,
};

class _Translations {
  final Vector2 objects48 = Vector2(1459, 1);
  final Vector2 trees  = Vector2(2049, 1);
  final Vector2 objects150  = Vector2(1748, 1);
  final Vector2 palisades  = Vector2(1314, 1);
  final Vector2 torches = Vector2(2146, 1 );
}

final Map<ObjectType, Vector2> objectTypeSrcPosition = {
  ObjectType.Rock: _translations.objects48,
  ObjectType.Grave: _translations.objects48,
  ObjectType.Tree_Stump: _translations.objects48,
  ObjectType.Rock_Small: _translations.objects48,
  ObjectType.LongGrass: _translations.objects48,
  ObjectType.Torch: _translations.torches,
  ObjectType.Tree01: _translations.trees,
  ObjectType.House01: _translations.objects150,
  ObjectType.House02: _translations.objects150,
  ObjectType.Palisade: _translations.palisades,
  ObjectType.Palisade_V: _translations.palisades,
  ObjectType.Palisade_H: _translations.palisades,
  ObjectType.MystEmitter: atlas.circle,
  ObjectType.Rock_Wall: atlas.rockWall,
};

final _ambient = modules.isometric.state.ambient;
final _isoState = isometric.state;

void mapEnvironmentObjectToSrc(EnvironmentObject env){
  // TODO Optimize
  var shade = _isoState.getShade(env.row, env.column);
  final type = env.type;

  if (type == ObjectType.House01 || type == ObjectType.House02){
    shade = _ambient.value == Shade.Bright ? 0 : 1;
  }

  var top = shade * env.height + 1;
  if (type == ObjectType.Torch && _ambient.value > Shade.Bright){
    top = _translations.torches.y + ((core.state.timeline.frame % 4) * _torchHeight) + _torchHeight;
  }
  engine.mapSrc(x: env.srcX, y: top, width: env.width, height: env.height);
}
