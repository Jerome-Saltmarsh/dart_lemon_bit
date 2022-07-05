
import 'package:gamestream_flutter/isometric/particles.dart';

void onChangedScene(){
  for (var i = 0; i < totalParticles; i++){
     particles[i].duration = 0;
  }
  totalParticles = 0;
}