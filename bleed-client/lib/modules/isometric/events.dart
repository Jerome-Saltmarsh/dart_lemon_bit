import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/modules/modules.dart';

import 'enums.dart';

class IsometricEvents {

  void register(){
    if (isometric.state.eventsRegistered) return;
    print("isometric.events.register()");
    isometric.state.eventsRegistered = true;
    isometric.subscriptions.onAmbientChanged = isometric.state.ambient.onChanged(onAmbientChanged);
    isometric.state.time.onChanged(onTimeChanged);
    isometric.state.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
    isometric.state.hour.onChanged(onHourChanged);
  }

  void onTimeChanged(int timeInSeconds) {
    final timeInMinutes = timeInSeconds / 60;
    final timeInHours = timeInMinutes / 60;
    modules.isometric.state.hour.value = timeInHours.toInt();
  }

  void onHourChanged(int hour){
    print("isometric.events.onHourChanged($hour)");
    final phase = modules.isometric.map.hourToPhase(hour);
    final phaseBrightness = modules.isometric.map.phaseToShade(phase);
    final maxAmbientBrightness = modules.isometric.state.maxAmbientBrightness.value;
    if (maxAmbientBrightness.isDarkerThan(phaseBrightness)) return;
    modules.isometric.state.ambient.value = phaseBrightness;
  }

  void onAmbientChanged(Shade value){
    print("isometric.events.onAmbientChanged($value)");
    modules.isometric.actions.resetLighting();
  }
}