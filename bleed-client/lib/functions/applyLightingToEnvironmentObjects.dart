
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToShadedImage.dart';
import 'package:bleed_client/state.dart';

void applyLightingToEnvironmentObjects() {
  for (EnvironmentObject environmentObject in compiledGame.environmentObjects) {
    Shading shade = getShade(environmentObject.tileRow, environmentObject.tileColumn);
    environmentObject.image = mapEnvironmentObjectToToShadedImage(environmentObject, shade);
  }
}
