
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
      return images.treeA1;
    case EnvironmentObjectType.Tree02:
      return images.treeB1;
    case EnvironmentObjectType.Rock:
      return images.rock1;
    case EnvironmentObjectType.Palisade:
      return images.palisade1;
    case EnvironmentObjectType.Palisade_H:
      return images.palisadeH1;
    case EnvironmentObjectType.Palisade_V:
      return images.palisadeV1;
    case EnvironmentObjectType.Grave:
      return images.grave1;
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
      return images.rockSmall1;
    case EnvironmentObjectType.LongGrass:
      return images.longGrass2;
    default:
      throw Exception("cannot map type");
  }
}