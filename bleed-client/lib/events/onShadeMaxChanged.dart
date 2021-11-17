
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/setters/setAmbientLightAccordingToPhase.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:bleed_client/watches/phase.dart';

void onShadeMaxChanged(Shade shade){
  print("onShadeMaxChanged($shade)");
  if (shade.isDarkerThan(ambient)){
    ambient = shade;
  } else if (shade.isLighterThan(ambient)) {
    applyAmbientLightToCurrentPhase();
  }
}

void applyAmbientLightToCurrentPhase() {
  print("applyAmbientLightToCurrentPhase");
  setAmbientLightAccordingToPhase(phase.value);
}