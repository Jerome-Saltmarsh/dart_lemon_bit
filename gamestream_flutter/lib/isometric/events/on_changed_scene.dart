
import 'package:gamestream_flutter/library.dart';

void onChangedScene(){
  gamestream.isometric.clientState.totalActiveParticles = 0;
  gamestream.isometric.clientState.totalParticles = 0;
  gamestream.isometric.clientState.particles.clear();
  gamestream.io.recenterCursor();
}