
import 'dart:ui';

import 'package:bleed_client/common/ObjectType.dart';
import 'package:bleed_client/images.dart';

Image mapEnvironmentObjectTypeToImage(EnvironmentObjectType type){
  switch(type){
    case EnvironmentObjectType.House01:
      return images.house;
    case EnvironmentObjectType.Tree01:
      return images.tree;
    case EnvironmentObjectType.Rock:
      return images.rock;
    default:
      throw Exception("cannot map type");
  }
}