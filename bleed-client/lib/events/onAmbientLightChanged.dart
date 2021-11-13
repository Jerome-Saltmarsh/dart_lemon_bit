

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyLightingToEnvironmentObjects.dart';
import 'package:bleed_client/functions/calculateTileSrcRects.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';

import '../images.dart';

void onAmbientLightChanged(Shade value){
  print("onAmbientLightChanged($value)");
  setBakeMapToAmbientLight();
  resetDynamicShadesToBakeMap();
  calculateTileSrcRects();
  applyEnvironmentObjectsToBakeMapping();
  applyLightingToEnvironmentObjects();
  if (value == Shade.Bright){
    images.torch = images.torchOut;
  }
}
