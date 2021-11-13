

import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyLightingToEnvironmentObjects.dart';
import 'package:bleed_client/functions/calculateTileSrcRects.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';

void onAmbientLightChanged(Shade value){
  resetDynamicShadesToBakeMap();
  calculateTileSrcRects();
  applyLightingToEnvironmentObjects();
}
