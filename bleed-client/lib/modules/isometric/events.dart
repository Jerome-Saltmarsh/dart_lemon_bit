import 'package:bleed_client/events/onShadeMaxChanged.dart';
import 'package:bleed_client/modules/isometric/scope.dart';
import 'package:bleed_client/modules/modules.dart';

class IsometricEvents with IsometricScope {

  void register(){
    if (isometric.state.eventsRegistered) return;
    print("isometric.events.register()");
    isometric.state.eventsRegistered = true;
    isometric.subscriptions.onAmbientChanged = isometric.state.ambient.onChanged(onAmbientChanged);
    isometric.state.time.onChanged(onTimeChanged);
    isometric.state.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
    isometric.state.hour.onChanged(onHourChanged);
    isometric.state.totalColumns.onChanged(onTotalColumnsChanged);
    isometric.state.totalRows.onChanged(onTotalRowsChanged);
  }

  void onTotalColumnsChanged(int value){
    state.totalColumnsInt = value;
  }

  void onTotalRowsChanged(int value){
    state.totalRowsInt = value;
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
    if (maxAmbientBrightness > phaseBrightness) return;
    modules.isometric.state.ambient.value = phaseBrightness;
  }

  void onAmbientChanged(int value){
    print("isometric.events.onAmbientChanged($value)");
    modules.isometric.actions.resetLighting();
  }
}