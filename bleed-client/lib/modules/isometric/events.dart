import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/modules.dart';

import 'enums.dart';

class IsometricEvents {

  void register(){
    if (modules.isometric.state.eventsRegistered) return;
    print("isometric.events.register()");
    modules.isometric.state.eventsRegistered = true;
    modules.isometric.subscriptions.onAmbientChanged = modules.isometric.state.ambient.onChanged(_onAmbientChanged);
    modules.isometric.state.time.onChanged(onTimeChanged);
    modules.isometric.state.phase.onChanged(onPhaseChanged);
    modules.isometric.state.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
    modules.isometric.state.hour.onChanged(onHourChanged);
  }

  void onTimeChanged(int timeInSeconds) {
    final timeInMinutes = timeInSeconds / 60;
    final timeInHours = timeInMinutes / 60;
    modules.isometric.state.hour.value = timeInHours.toInt();
  }

  void onHourChanged(int hour){
    print("isometric.events.onHourChanged($hour)");
    modules.isometric.state.phase.value = modules.isometric.map.hourToPhase(hour);
  }

  void _onAmbientChanged(Shade value){
    print("isometric.events.onAmbientLightChanged($value)");
    modules.isometric.actions.setBakeMapToAmbientLight();
    modules.isometric.actions.setDynamicMapToAmbientLight();
    modules.isometric.actions.resetDynamicShadesToBakeMap();
    modules.isometric.actions.applyDynamicShadeToTileSrc();
    modules.isometric.actions.applyEnvironmentObjectsToBakeMapping();
  }

  void onPhaseChanged(Phase phase){
    print("isometric.events.onPhaseChanged($phase)");
    final phaseBrightness = modules.isometric.map.phaseToShade(phase);
    final maxAmbientBrightness = modules.isometric.state.maxAmbientBrightness.value;
    if (maxAmbientBrightness.isDarkerThan(phaseBrightness)) return;
    modules.isometric.state.ambient.value = phaseBrightness;
  }
}