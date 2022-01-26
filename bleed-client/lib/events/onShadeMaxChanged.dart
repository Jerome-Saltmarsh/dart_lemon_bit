
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:bleed_client/watches/phase.dart';

import '../modules.dart';

void onShadeMaxChanged(Shade shade){
  print("onShadeMaxChanged($shade)");
  if (shade.isDarkerThan(modules.isometric.state.ambient.value)){
    ambient = shade;
  } else if (shade.isLighterThan(modules.isometric.state.ambient.value)) {
    applyAmbientLightToCurrentPhase();
  }
}

void applyAmbientLightToCurrentPhase() {
  print("applyAmbientLightToCurrentPhase");
  modules.isometric.actions.setAmbientLightAccordingToPhase(modules.isometric.state.phase.value);
}