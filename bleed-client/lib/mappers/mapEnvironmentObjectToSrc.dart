
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';

final Map<ObjectType, double> environmentObjectWidth = {
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

final Map<ObjectType, double> environmentObjectHeight = {
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

final _Translations _translations = _Translations();

class _Translations {
  final Vector2 objects48 = Vector2(2056, 994);
  final Vector2 objects96  = Vector2(2051, 1);
  final Vector2 objects150  = Vector2(2056, 393);
  final Vector2 palisades  = Vector2(2072, 1222);
  final Vector2 torches = Vector2(2272, 0);
}

final Map<ObjectType, Vector2> objectTypeSrcPosition = {
  ObjectType.Rock: _translations.objects48,
  ObjectType.Grave: _translations.objects48,
  ObjectType.Tree_Stump: _translations.objects48,
  ObjectType.Rock_Small: _translations.objects48,
  ObjectType.LongGrass: _translations.objects48,
  ObjectType.Torch: _translations.torches,
  ObjectType.Tree01: _translations.objects96,
  ObjectType.House01: _translations.objects150,
  ObjectType.House02: _translations.objects150,
  ObjectType.Palisade: _translations.palisades,
  ObjectType.Palisade_V: _translations.palisades,
  ObjectType.Palisade_H: _translations.palisades,
  ObjectType.MystEmitter: atlas.circle,
  ObjectType.Rock_Wall: atlas.rockWall,
};

final _torchHeight = environmentObjectHeight[ObjectType.Torch]!;

void mapEnvironmentObjectToSrc(EnvironmentObject env){
  final shade = isometric.properties.getShade(env.row, env.column);
  final type = env.type;
  final translation = objectTypeSrcPosition[type];
  if (translation == null){
    throw Exception(type);
  }
  final index =  environmentObjectIndex[type]!;
  final width = environmentObjectWidth[type]!;
  final height = environmentObjectHeight[type]!;
  final left = index * width + translation.x;
  var top = shade * height + translation.y;
  if (type == ObjectType.Torch && modules.isometric.state.ambient.value > Shade.Bright){
    top = _translations.torches.y + ((core.state.timeline.frame % 4) * _torchHeight) + _torchHeight;
  }
  engine.state.mapSrc(x: left, y: top, width: width, height: height);
}

final Map<ObjectType, int> environmentObjectIndex = {
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