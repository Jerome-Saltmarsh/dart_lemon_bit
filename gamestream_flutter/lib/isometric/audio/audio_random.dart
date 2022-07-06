import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';
import 'package:lemon_math/library.dart';

import 'audio_single.dart';

var nextRandomSound = 0;
var nextRandomMusic = 0;

final musicNight = [
  AudioSingle(name: 'creepy-whistle', volume: 0.1),
  AudioSingle(name: 'creepy-wind', volume: 0.1),
  AudioSingle(name: 'spooky-tribal', volume: 1.0),
];

final soundsNight = [
  AudioSingle(name: 'owl-1', volume: 0.15),
  AudioSingle(name: 'wolf-howl', volume: 0.1),
  AudioSingle(name: 'creepy-5', volume: 0.2),
];

final soundsDay = [
  AudioSingle(name: 'wind-chime', volume: 0.25),
];

final soundsLateAfternoon = [
  AudioSingle(name: 'gong', volume: 0.25),
];


void updateRandomAudio(){
  updateRandomMusic();
  updateRandomAmbientSounds();
}

void updateRandomMusic(){
  if (nextRandomMusic-- > 0) return;
  playRandomMusic();
  nextRandomMusic = randomInt(800, 2000);
}

void playRandomMusic(){
   if (ambientShade.value == Shade.Pitch_Black) {
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

  final shade = ambientShade.value;

  if (shade == Shade.Pitch_Black || shade == Shade.Very_Dark){
    return playRandom(soundsNight);
  }
  if (shade == Shade.Very_Bright) {
    return playRandom(soundsDay);
  }
  if (hour > 15 && hour < 18) {
    return playRandom(soundsLateAfternoon);
  }
}

void playRandom(List<AudioSingle> items){
  randomItem(items).play();
}