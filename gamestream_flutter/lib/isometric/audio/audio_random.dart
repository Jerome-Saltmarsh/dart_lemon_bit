import 'package:gamestream_flutter/isometric/time.dart';
import 'package:lemon_math/library.dart';

import 'audio_single.dart';

var nextRandomSound = 0;
var nextRandomMusic = 0;


final musicNight = [
  AudioSingle(name: 'creepy-5', volume: 0.2),
  AudioSingle(name: 'creepy-whistle', volume: 0.1),
  AudioSingle(name: 'creepy-wind', volume: 0.1),
];

final soundsNight = [
  AudioSingle(name: 'owl-1', volume: 0.2),
];

final soundsDay = [
  AudioSingle(name: 'gong', volume: 0.2),
  AudioSingle(name: 'wind-chime', volume: 0.2)
];


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
     playRandom(musicNight);
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
    return playRandom(soundsNight);
  }
  if (hour > 12 && hour < 16) {
    return playRandom(soundsDay);
  }
}

void playRandom(List<AudioSingle> items){
  randomItem(items).play();
}