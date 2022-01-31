import 'package:bleed_client/modules/isometric/actions.dart';
import 'package:bleed_client/modules/isometric/scope.dart';
import 'package:bleed_client/modules/isometric/state.dart';
import 'package:bleed_client/modules/modules.dart';

class IsometricEvents with IsometricScope {
  
  final IsometricState state;
  final IsometricActions actions;
  IsometricEvents(this.state, this.actions);

  void register(){
    if (state.eventsRegistered) return;
    print("isometric.events.register()");
    state.eventsRegistered = true;
    isometric.subscriptions.onAmbientChanged = state.ambient.onChanged(onAmbientChanged);
    state.time.onChanged(onTimeChanged);
    state.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
    state.hour.onChanged(onHourChanged);
    state.totalColumns.onChanged(onTotalColumnsChanged);
    state.totalRows.onChanged(onTotalRowsChanged);
  }

  void onMaxAmbientBrightnessChanged(int maxShade){
    print("onShadeMaxChanged($maxShade)");
    final ambient = state.ambient.value;
    if (maxShade == ambient) return;

    if (maxShade > ambient){
      state.ambient.value = maxShade;
      return;
    }
    state.ambient.value = properties.currentPhaseShade;
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
    state.hour.value = timeInHours.toInt();
  }

  void onHourChanged(int hour){
    print("isometric.events.onHourChanged($hour)");
    final phase = modules.isometric.map.hourToPhase(hour);
    final phaseBrightness = modules.isometric.map.phaseToShade(phase);
    final maxAmbientBrightness = state.maxAmbientBrightness.value;
    if (maxAmbientBrightness > phaseBrightness) return;
    state.ambient.value = phaseBrightness;
  }

  void onAmbientChanged(int value){
    print("isometric.events.onAmbientChanged($value)");
    actions.resetLighting();
  }
}