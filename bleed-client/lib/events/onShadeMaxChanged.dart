
import 'package:bleed_client/common/enums/Shade.dart';

import '../modules.dart';

void onMaxAmbientBrightnessChanged(Shade maxShade){
  print("onShadeMaxChanged($maxShade)");
  final ambient = modules.isometric.state.ambient.value;
  if (maxShade == ambient) return;

  if (maxShade.isDarkerThan(ambient)){
    modules.isometric.state.ambient.value = maxShade;
    return;
  }
  modules.isometric.state.ambient.value = modules.isometric.properties.currentPhaseShade;
}
