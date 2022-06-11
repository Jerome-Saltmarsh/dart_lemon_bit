
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/state/grid.dart';

void refreshLighting(){
  gridSetAmbient(isometric.ambient.value);
}