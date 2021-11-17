

import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/functions/applyLightingToEnvironmentObjects.dart';
import 'package:bleed_client/functions/calculateTileSrcRects.dart';
import 'package:bleed_client/render/functions/applyEnvironmentObjectsToBakeMapping.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/functions/setBakeMapToAmbientLight.dart';

void onAmbientLightChanged(Shade value){
  print("onAmbientLightChanged($value)");
  setBakeMapToAmbientLight();
  resetDynamicShadesToBakeMap();
  calculateTileSrcRects();
  applyEnvironmentObjectsToBakeMapping();
  applyLightingToEnvironmentObjects();
}
