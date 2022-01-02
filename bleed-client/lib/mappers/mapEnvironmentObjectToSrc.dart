import 'dart:typed_data';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/state.dart';
import 'package:bleed_client/watches/ambientLight.dart';
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

final double _torchHeight = environmentObjectHeight[ObjectType.Torch]!;

final Float32List _src = Float32List(4);

Float32List mapEnvironmentObjectToSrc(EnvironmentObject env){
  Shade shade = getShade(env.row, env.column);
  ObjectType type = env.type;

  if (shade == Shade.PitchBlack){
    clearSrc(_src);
    return _src;
  }

  Vector2? translation = objectTypeSrcPosition[type];
  if (translation == null){
    throw Exception(type);
  }
  int index =  environmentObjectIndex[type]!;
  double width = environmentObjectWidth[type]!;
  double height = environmentObjectHeight[type]!;
  double left = index * width + translation.x;
  double right = left + width;
  double top = shade.index * height + translation.y;

  if (type == ObjectType.Torch && ambient.isDarkerThan(Shade.Bright)){
    top = _translations.torches.y + ((drawFrame % 4) * _torchHeight) + _torchHeight;
  }

  double bottom = top + height;
  _src[0] = left;
  _src[1] = top;
  _src[2] = right;
  _src[3] = bottom;
  return _src;
}

void clearSrc(Float32List src){
  src[0] = 0;
  src[1] = 0;
  src[2] = 0;
  src[3] = 0;
}
