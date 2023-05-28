
import 'package:gamestream_flutter/library.dart';

void onChangedScene(){
  gamestream.games.isometric.clientState2.totalActiveParticles = 0;
  gamestream.games.isometric.clientState2.totalParticles = 0;
  gamestream.games.isometric.clientState2.particles.clear();
  gamestream.io.recenterCursor();
}