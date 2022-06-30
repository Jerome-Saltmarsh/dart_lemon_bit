import 'package:gamestream_flutter/isometric/audio.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:lemon_math/library.dart';

var nextRandomSound = 0;
var nextRandomMusic = 0;

void updateRandomAudio(){
  updateRandomMusic();
  updateRandomAmbientSounds();
}

void updateRandomMusic(){
  if (nextRandomMusic-- > 0) return;
  playRandomMusic();
  nextRandomMusic = randomInt(200, 1000);
}

void playRandomMusic(){

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
      return audioSingleOwl.play(volume: 0.05);
    }
  }
  if (hour > 12 && hour < 16) {
    if (randomBool()){
      return audioSingleGong.play(volume: 0.1);
    }
    return audioSingleWindChime.play(volume: 0.3);
  }
}