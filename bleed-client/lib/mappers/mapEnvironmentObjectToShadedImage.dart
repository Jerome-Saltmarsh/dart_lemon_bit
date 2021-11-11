import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/variables/ambientLight.dart';

Image mapEnvironmentObjectToToShadedImage(EnvironmentObject environmentObject, Shading shade) {

  try {
    if (typeShades.containsKey(environmentObject.type)) {
      return typeShades[environmentObject.type][shade.index];
    }
  }catch(e){
    print('failed to map $environmentObject for shade $shade');
  }

  if (environmentObject.type == EnvironmentObjectType.House01) {
    switch (ambientLight) {
      case Shading.Bright:
        return images.houseDay;
      default:
        return images.house;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Torch){
    return images.torch;
  }

  if (environmentObject.type == EnvironmentObjectType.House01){
    switch (ambientLight) {
      case Shading.Bright:
        return images.houseDay;
      default:
        return images.house;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.House02){
    return images.house02;
  }

  return images.empty;
}
