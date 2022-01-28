
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules/modules.dart';

void onMaxAmbientBrightnessChanged(int maxShade){
  print("onShadeMaxChanged($maxShade)");
  final ambient = modules.isometric.state.ambient.value;
  if (maxShade == ambient) return;

  if (maxShade > ambient){
    modules.isometric.state.ambient.value = maxShade;
    return;
  }
  modules.isometric.state.ambient.value = modules.isometric.properties.currentPhaseShade;
}
