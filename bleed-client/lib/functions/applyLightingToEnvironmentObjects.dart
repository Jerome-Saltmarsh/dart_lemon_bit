
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToShadedImage.dart';
import 'package:bleed_client/state/game.dart';

void applyLightingToEnvironmentObjects() {
  for (EnvironmentObject environmentObject in game.environmentObjects) {
    Shade shade = getShade(environmentObject.tileRow, environmentObject.tileColumn);
    environmentObject.src[1] = shade.index * environmentObject.height;
    environmentObject.src[3] = environmentObject.src[1] + environmentObject.height;
  }
}
