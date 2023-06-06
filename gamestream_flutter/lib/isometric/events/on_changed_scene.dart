
import 'package:gamestream_flutter/library.dart';

void onChangedScene(){
  gamestream.isometricEngine.clientState.totalActiveParticles = 0;
  gamestream.isometricEngine.clientState.totalParticles = 0;
  gamestream.isometricEngine.clientState.particles.clear();
  gamestream.io.recenterCursor();
}