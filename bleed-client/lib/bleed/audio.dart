import 'package:audioplayers/audioplayers.dart';

import 'utils.dart';

AudioPlayer _weaponAudioPlayer = AudioPlayer();
AudioPlayer _zombieAudioPlayer = AudioPlayer();

List<String> _zombieHits = [
  'zombie-hit-01.wav',
  'zombie-hit-02.wav',
  'zombie-hit-03.wav',
  'zombie-hit-05.wav'
];

List<String> _zombieDeath = [
  'zombie-death-02.wav',
  'zombie-death-09.wav',
  'zombie-death-15.wav',
];

List<String> _zombieTalking = [
  'zombie-talking-03.wav',
  'zombie-talking-04.wav',
  'zombie-talking-05.wav',
];

void playAudioZombieTargetAcquired(){
  _playRandom(_zombieTalking, _zombieAudioPlayer);
}

void playAudioZombieDeath(){
  _playRandom(_zombieDeath, _zombieAudioPlayer);
}

void playAudioZombieHit() {
  _playRandom(_zombieHits, _zombieAudioPlayer);
}

void playAudioShotgunShot() {
  _play('shotgun-shot.mp3', _weaponAudioPlayer);
}

void playAudioHandgunShot() {
  _play('handgun-shot.mp3', _weaponAudioPlayer);
}

void _playRandom(List<String> values, AudioPlayer audioPlayer){
  _play(randomItem(values), audioPlayer);
}

void _play(String name, AudioPlayer audioPlayer) {
  audioPlayer.play('assets/audio/$name', isLocal: true);
}
