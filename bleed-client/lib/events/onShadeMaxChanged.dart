
import 'package:bleed_client/common/enums/Shade.dart';

import '../modules.dart';

void onMaxAmbientBrightnessChanged(Shade maxShade){
  print("onShadeMaxChanged($maxShade)");
  if (maxShade.isDarkerThan(modules.isometric.state.ambient.value)){
    modules.isometric.state.ambient.value = maxShade;
  } else if (maxShade.isLighterThan(modules.isometric.state.ambient.value)) {
    applyAmbientLightToCurrentPhase();
  }
}

void applyAmbientLightToCurrentPhase() {
  print("applyAmbientLightToCurrentPhase");
  modules.isometric.actions.setAmbientAccordingToPhase(modules.isometric.state.phase.value);
}