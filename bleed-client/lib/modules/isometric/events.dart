import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums/Phase.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/events/onTimeChanged.dart';
import 'package:bleed_client/watches/ambientLight.dart';

import '../../modules.dart';

class IsometricEvents {

  void register(){
    print("isometric.events.register()");
    modules.isometric.subscriptions.onAmbientChanged = modules.isometric.state.ambient.onChanged(_onAmbientChanged);
    modules.isometric.state.time.onChanged(onTimeChanged);
    modules.isometric.state.phase.onChanged(modules.isometric.actions.setAmbientAccordingToPhase);
    modules.isometric.state.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
  }

  void _onAmbientChanged(Shade value){
    print("isometric.events.onAmbientLightChanged($value)");
    modules.isometric.actions.setBakeMapToAmbientLight();
    modules.isometric.actions.setDynamicMapToAmbientLight();
    modules.isometric.actions.resetDynamicShadesToBakeMap();
    modules.isometric.actions.applyDynamicShadeToTileSrc();
    modules.isometric.actions.applyEnvironmentObjectsToBakeMapping();
  }

}