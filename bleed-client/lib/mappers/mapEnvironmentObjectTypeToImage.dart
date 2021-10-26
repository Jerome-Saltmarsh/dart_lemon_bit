
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
      return images.tree01;
    case EnvironmentObjectType.Tree02:
      return images.tree02;
    case EnvironmentObjectType.Rock:
      return images.rock;
    case EnvironmentObjectType.Palisade:
      return images.palisade;
    case EnvironmentObjectType.Palisade_H:
      return images.palisadeH;
    case EnvironmentObjectType.Palisade_V:
      return images.palisadeV;
    case EnvironmentObjectType.Grave:
      return images.grave;
    case EnvironmentObjectType.SmokeEmitter:
      return images.circle64;
    case EnvironmentObjectType.MystEmitter:
      return images.circle64;
    case EnvironmentObjectType.Torch:
      return images.torch_01;
    case EnvironmentObjectType.Bridge:
      return images.bridge;
    case EnvironmentObjectType.Tree_Stump:
      return images.treeStump;
    case EnvironmentObjectType.Rock_Small:
      return images.rockSmall;
    default:
      throw Exception("cannot map type");
  }
}