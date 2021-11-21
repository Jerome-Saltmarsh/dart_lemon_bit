import 'dart:typed_data';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/common/enums/ObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/functions/applyLightingToEnvironmentObjects.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/render/functions/setSrc.dart';
import 'package:bleed_client/watches/ambientLight.dart';

final Map<ObjectType, double> environmentObjectWidth = {
  ObjectType.Palisade: 48,
  ObjectType.Palisade_H: 48,
  ObjectType.Palisade_V: 48,
  ObjectType.Rock: 48,
  ObjectType.Grave: 48,
  ObjectType.Tree_Stump: 48,
  ObjectType.Rock_Small: 48,
  ObjectType.LongGrass: 48,
  ObjectType.Torch: 48,
  ObjectType.Tree01: 96,
  ObjectType.Tree02: 96,
  ObjectType.House01: 150,
  ObjectType.House02: 150,
};

final Map<ObjectType, double> environmentObjectHeight = {
  ObjectType.Palisade: 100,
  ObjectType.Palisade_H: 100,
  ObjectType.Palisade_V: 100,
  ObjectType.Rock: 48,
  ObjectType.Grave: 48,
  ObjectType.Tree_Stump: 48,
  ObjectType.Rock_Small: 48,
  ObjectType.LongGrass: 48,
  ObjectType.Torch: 48,
  ObjectType.Tree01: 96,
  ObjectType.Tree02: 96,
  ObjectType.House01: 150,
  ObjectType.House02: 150,
};

final Vector2 small = Vector2(2056, 994);
final Vector2 medium  = Vector2(2051, 1);
final Vector2 large  = Vector2(2056, 393);
final Vector2 palisades  = Vector2(2072, 1222);
final Vector2 torches = Vector2(2254, 1);

final Map<ObjectType, Vector2> objectTypeSrcPosition = {
  ObjectType.Rock: small,
  ObjectType.Grave: small,
  ObjectType.Tree_Stump: small,
  ObjectType.Rock_Small: small,
  ObjectType.LongGrass: small,
  ObjectType.Torch: small,
  ObjectType.Tree01: medium,
  ObjectType.Tree02: medium,
  ObjectType.House01: large,
  ObjectType.House02: large,
  ObjectType.Palisade: palisades,
  ObjectType.Palisade_V: palisades,
  ObjectType.Palisade_H: palisades,
};

void mapEnvironmentObjectToSrc(EnvironmentObject env){
  Shade shade = getShadeAtEnvironmentObject(env);
  if (shade == Shade.PitchBlack){
    env.src[0] = 0;
    env.src[1] = 0;
    env.src[2] = 0;
    env.src[3] = 0;
    return;
  }

  ObjectType type = env.type;
  Vector2 translation = objectTypeSrcPosition[type];
  if (translation == null){
    throw Exception(type);
  }
  int index =  environmentObjectIndex[type];
  double width = environmentObjectWidth[type];
  double height = environmentObjectHeight[type];
  double left = index * width + translation.x;
  double right = left + width;
  double top = shade.index * height + translation.y;
  double bottom = top + height;

  if (type == ObjectType.Torch && ambient.isDarkerThan(Shade.Bright)){
    left = torches.x;
    right = torches.x + 25.0;
    top = 1;
    bottom = top + 70;
  }

  env.src[0] = left;
  env.src[1] = top;
  env.src[2] = right;
  env.src[3] = bottom;
}
