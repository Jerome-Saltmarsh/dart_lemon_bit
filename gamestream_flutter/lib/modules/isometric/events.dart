import 'package:gamestream_flutter/modules/isometric/actions.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:gamestream_flutter/modules/isometric/properties.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';
import 'package:gamestream_flutter/modules/modules.dart';

class IsometricEvents {
  
  final IsometricModule state;
  final IsometricActions actions;
  final IsometricProperties properties;
  IsometricEvents(this.state, this.actions, this.properties);

  void register(){
    if (isometric.eventsRegistered) return;
    isometric.eventsRegistered = true;
    isometric.subscriptions.onAmbientChanged = isometric.ambient.onChanged(onAmbientChanged);
    isometric.maxAmbientBrightness.onChanged(onMaxAmbientBrightnessChanged);
    isometric.hours.onChanged(onHourChanged);
    isometric.totalColumns.onChanged(onTotalColumnsChanged);
    isometric.totalRows.onChanged(onTotalRowsChanged);
  }

  void onMaxAmbientBrightnessChanged(int maxShade){
    // print("onShadeMaxChanged($maxShade)");
    final ambient = isometric.ambient.value;
    if (maxShade == ambient) return;

    if (maxShade > ambient){
      isometric.ambient.value = maxShade;
      return;
    }
    isometric.ambient.value = properties.currentPhaseShade;
  }

  void onTotalColumnsChanged(int value){
    // print("isometric.events.onTotalColumnsChanged($value)");
    isometric.totalColumnsInt = value;
  }

  void onTotalRowsChanged(int value){
    // print("isometric.events.onTotalRowsChanged($value)");
    isometric.totalRowsInt = value;
  }

  void onHourChanged(int hour){
    isometric.refreshAmbientLight();
  }

  void onAmbientChanged(int value){
    isometric.resetLighting();
  }
}