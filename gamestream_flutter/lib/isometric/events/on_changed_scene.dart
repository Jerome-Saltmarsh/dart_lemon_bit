
import 'package:gamestream_flutter/library.dart';

void onChangedScene(){
  ClientState.totalActiveParticles = 0;
  ClientState.totalParticles = 0;
  ClientState.particles.clear();
  gamestream.io.recenterCursor();
}