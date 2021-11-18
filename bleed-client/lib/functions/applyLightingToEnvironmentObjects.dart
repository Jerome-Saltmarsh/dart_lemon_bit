
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/state/game.dart';

void applyLightingToEnvironmentObjects() {
  for (EnvironmentObject environmentObject in game.environmentObjects) {
    Shade shade = getShade(environmentObject.tileRow, environmentObject.tileColumn);
    applyShadeToEnvironmentObject(environmentObject, shade);
  }
}

void applyShadeToEnvironmentObject(EnvironmentObject obj, Shade shade){
  setSrcIndex(obj, shade.index);
}

void setSrcIndex(EnvironmentObject obj, int index){
  obj.src[1] = index * obj.height;
  obj.src[3] = obj.src[1] + obj.height;
}
