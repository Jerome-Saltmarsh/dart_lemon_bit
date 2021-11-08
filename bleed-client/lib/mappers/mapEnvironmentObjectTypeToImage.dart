
import 'dart:ui';

import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/images.dart';

Image mapEnvironmentObjectTypeToImage(EnvironmentObjectType type){
  switch(type){
    case EnvironmentObjectType.House01:
      return images.house;
    case EnvironmentObjectType.House02:
      return images.house02;
    case EnvironmentObjectType.Tree01:
      return images.tree01Bright;
    case EnvironmentObjectType.Tree02:
      return images.tree02Bright;
    case EnvironmentObjectType.Rock:
      return images.rock1;
    case EnvironmentObjectType.Palisade:
      return images.palisadeBright;
    case EnvironmentObjectType.Palisade_H:
      return images.palisadeHBright;
    case EnvironmentObjectType.Palisade_V:
      return images.palisadeVBright;
    case EnvironmentObjectType.Grave:
      return images.graveBright;
    case EnvironmentObjectType.SmokeEmitter:
      return images.circle;
    case EnvironmentObjectType.MystEmitter:
      return images.circle;
    case EnvironmentObjectType.Torch:
      return images.torch_01;
    case EnvironmentObjectType.Bridge:
      return images.bridge;
    case EnvironmentObjectType.Tree_Stump:
      return images.treeStump1;
    case EnvironmentObjectType.Rock_Small:
      return images.rockSmallBright;
    case EnvironmentObjectType.Character:
      return images.isoCharacter;
    case EnvironmentObjectType.LongGrass:
      return images.longGrassNormal;
    default:
      throw Exception("cannot map type");
  }
}