import 'package:gamestream_flutter/isometric/time.dart';
import 'package:lemon_math/library.dart';

import 'audio_singles.dart';

var nextRandomSound = 0;
var nextRandomMusic = 0;

void updateRandomAudio(){
  updateRandomMusic();
  updateRandomAmbientSounds();
}

void updateRandomMusic(){
  if (nextRandomMusic-- > 0) return;
  playRandomMusic();
  nextRandomMusic = randomInt(600, 1500);
}

void playRandomMusic(){
   final hour = hours.value;
   if (hour < 4){
     if (randomBool()){
       return audioSingleCreepyWhistle(0.2);
     }
     return audioSingleCreepyWind(0.1);
   }
}

void updateRandomAmbientSounds(){
  if (nextRandomSound-- > 0) return;
  playRandomAmbientSound();
  nextRandomSound = randomInt(200, 1000);
}

void playRandomAmbientSound(){
  final hour = hours.value;

  if (hour < 3){
    if (randomBool()){
      return audioSingleOwl(0.05);
    }
  }
  if (hour > 12 && hour < 16) {
    if (randomBool()){
      return audioSingleGong(0.05);
    }
    return audioSingleWindChime(0.3);
  }
}