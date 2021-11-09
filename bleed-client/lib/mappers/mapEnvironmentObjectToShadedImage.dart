import 'dart:ui';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/images.dart';

Image mapEnvironmentObjectToToShadedImage(EnvironmentObject environmentObject, Shading shade) {

  if (typeShades.containsKey(environmentObject.type)){
    return typeShades[environmentObject.type][shade.index];
  }

  if (environmentObject.type == EnvironmentObjectType.Palisade) {
    switch (shade) {
      case Shading.Bright:
        return images.palisadeBright;
      case Shading.Medium:
        return images.palisadeMedium;
      case Shading.Dark:
        return images.palisadeDark;
      case Shading.VeryDark:
        return images.palisadeDarkDark;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Palisade_H) {
    switch (shade) {
      case Shading.Bright:
        return images.palisadeHBright;
      case Shading.Medium:
        return images.palisadeHMedium;
      case Shading.Dark:
        return images.palisadeHDark;
      case Shading.VeryDark:
        return images.palisadeHDarkDark;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Palisade_V) {
    switch (shade) {
      case Shading.Bright:
        return images.palisadeVBright;
      case Shading.Medium:
        return images.palisadeVMedium;
      case Shading.Dark:
        return images.palisadeVDark;
      case Shading.VeryDark:
        return images.palisadeVDarkDark;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Tree_Stump) {
    switch (shade) {
      case Shading.Bright:
        return images.treeStump1;
      case Shading.Medium:
        return images.treeStump2;
      case Shading.Dark:
        return images.treeStump3;
      case Shading.VeryDark:
        return images.treeStump3;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Rock_Small) {
    switch (shade) {
      case Shading.Bright:
        return images.rockSmallBright;
      case Shading.Medium:
        return images.rockSmallMedium;
      case Shading.Dark:
        return images.rockSmallDark;
      case Shading.VeryDark:
        return images.rockSmallDark;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Grave) {
    switch (shade) {
      case Shading.Bright:
        return images.grave1;
      case Shading.Medium:
        return images.grave2;
      case Shading.Dark:
        return images.grave3;
      case Shading.VeryDark:
        return images.grave3;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.House01) {
    switch (shade) {
      case Shading.Bright:
        return images.houseDay;
      default:
        return images.house;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.LongGrass) {
    switch (shade) {
      case Shading.Bright:
        return images.longGrassBright;
      case Shading.Medium:
        return images.longGrassNormal;
      case Shading.Dark:
        return images.longGrassDark;
      case Shading.VeryDark:
        return images.longGrassDark;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.Torch){
    return images.torch;
  }

  if (environmentObject.type == EnvironmentObjectType.House01){
    switch (shade) {
      case Shading.Bright:
        return images.houseDay;
      default:
        return images.house;
    }
  }

  if (environmentObject.type == EnvironmentObjectType.House02){
    return images.house02;
  }

  if (environmentObject.type == EnvironmentObjectType.SmokeEmitter){
    return images.empty;
  }

  if (environmentObject.type == EnvironmentObjectType.MystEmitter){
    return images.empty;
  }

  return images.empty;
}
