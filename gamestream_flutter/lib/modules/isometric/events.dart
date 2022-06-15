import 'package:gamestream_flutter/isometric/state/time.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:gamestream_flutter/modules/modules.dart';

class IsometricEvents {
  
  final IsometricModule state;
  IsometricEvents(this.state);

  void register(){
    if (isometric.eventsRegistered) return;
    isometric.eventsRegistered = true;
  }

  void onTotalColumnsChanged(int value){
    isometric.totalColumnsInt = value;
  }

  void onTotalRowsChanged(int value){
    // print("isometric.events.onTotalRowsChanged($value)");
    isometric.totalRowsInt = value;
  }

  // void onHourChanged(int hour){
  //   isometric.refreshAmbientLight();
  // }

  void onAmbientChanged(int value){
    // isometric.resetLighting();
  }
}