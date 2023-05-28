
import 'package:gamestream_flutter/library.dart';

void onChangedScene(){
  gamestream.games.isometric.clientState.totalActiveParticles = 0;
  gamestream.games.isometric.clientState.totalParticles = 0;
  gamestream.games.isometric.clientState.particles.clear();
  gamestream.io.recenterCursor();
}