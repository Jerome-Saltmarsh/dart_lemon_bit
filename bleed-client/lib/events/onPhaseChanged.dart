

import 'package:bleed_client/enums/Phase.dart';
import 'package:bleed_client/setters/setAmbientLightAccordingToPhase.dart';

void onPhaseChanged(Phase phase){
  print("onPhaseChanged($phase)");
  setAmbientLightAccordingToPhase(phase);
}