import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/watches/ambientLight.dart';

Image mapEnvironmentObjectToToShadedImage(
    EnvironmentObject environmentObject, Shade shade) {

  if (shade == Shade.PitchBlack) return images.empty;

  if (typeShades.containsKey(environmentObject.type)) {
    return typeShades[environmentObject.type][shade.index];
  }

  if (environmentObject.type == EnvironmentObjectType.House01) {
    switch (ambient) {
      case Shade.Bright:
        return images.houseDay;
      default:
        return images.house;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Torch) {
    if (ambient == Shade.Bright) return images.torchOut;
    return images.torch;
  }

  if (environmentObject.type == EnvironmentObjectType.House01) {
    switch (ambient) {
      case Shade.Bright:
        return images.houseDay;
      default:
        return images.house;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.House02) {
    return images.house02;
  }

  return images.empty;
}
