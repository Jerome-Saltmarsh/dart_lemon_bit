import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:lemon_math/library.dart';

var nextRandomSound = 0;

void updateRandomAmbientSounds(){
  if (nextRandomSound-- > 0) return;
  playRandomAmbientSound();
  nextRandomSound = randomInt(200, 1000);
}

void playRandomAmbientSound(){
  final hour = hours.value;

  if (hour < 3){
     audioSingleOwl.play(volume: 0.05);
  }
}