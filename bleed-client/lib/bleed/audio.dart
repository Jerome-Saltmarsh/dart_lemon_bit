import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_game_engine/bleed/maths.dart';

import 'utils.dart';

AudioPlayer _audioPlayer = AudioPlayer();
AudioPlayer _audioPlayer2 = AudioPlayer();

List<String> _zombieHit = [
  'zombie-hit-01.wav',
  'zombie-hit-02.wav',
  'zombie-hit-03.wav',
  'zombie-hit-05.wav'
];

void playAudioZombieHit() {
  _play(randomItem(_zombieHit));
}

void playAudioShotgunShot() {
  _playMp3('shotgun-shot');
}

void playAudioHandgunShot() {
  _playMp3('handgun-shot');
}

void _playMp3(String name) {
  _audioPlayer.play('assets/audio/$name.mp3', isLocal: true);
}

void _play(String name) {
  _audioPlayer2.play('assets/audio/$name', isLocal: true);
}
