import 'package:gamestream_flutter/modules/isometric/actions.dart';
import 'package:gamestream_flutter/modules/isometric/properties.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';

class IsometricEvents {
  
  final IsometricState state;
  final IsometricActions actions;
  final IsometricProperties properties;
  IsometricEvents(this.state, this.actions, this.properties);

  void register(){
    if (state.eventsRegistered) return;
    state.eventsRegistered = true;
    isometric.subscriptions.onAmbientChanged = state.ambient.onChanged(onAmbientChanged);
    state.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
    state.hours.onChanged(onHourChanged);
    state.totalColumns.onChanged(onTotalColumnsChanged);
    state.totalRows.onChanged(onTotalRowsChanged);
  }

  void onMaxAmbientBrightnessChanged(int maxShade){
    // print("onShadeMaxChanged($maxShade)");
    final ambient = state.ambient.value;
    if (maxShade == ambient) return;

    if (maxShade > ambient){
      state.ambient.value = maxShade;
      return;
    }
    state.ambient.value = properties.currentPhaseShade;
  }

  void onTotalColumnsChanged(int value){
    // print("isometric.events.onTotalColumnsChanged($value)");
    state.totalColumnsInt = value;
  }

  void onTotalRowsChanged(int value){
    // print("isometric.events.onTotalRowsChanged($value)");
    state.totalRowsInt = value;
  }

  void onHourChanged(int hour){
    modules.isometric.actions.refreshAmbientLight();
  }

  void onAmbientChanged(int value){
    actions.resetLighting();
  }
}