import 'package:audioplayers/audioplayers.dart';

import 'utils.dart';

AudioPlayer _weaponAudioPlayer = AudioPlayer();
AudioPlayer _zombieAudioPlayer = AudioPlayer();
AudioPlayer _playerAudioPlayer = AudioPlayer();
AudioPlayer _equipAudioPlayer = AudioPlayer();

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

List<String> _zombieBite = [
   'zombie-bite-04.wav',
   'zombie-bite-05.wav',
   'bloody-punches-1.wav',
   'bloody-punches-2.wav',
   'bloody-punches-3.wav',
];

List<String> _maleScreams = [
  'male-screams-01.wav',
  'male-screams-05.wav',
  'male-screams-06.wav',
];

void playAudioReload(){
  _play('reload-06.wav', _equipAudioPlayer);
}

void playAudioCockShotgun(){
  _play('cock-shotgun-03.wav', _equipAudioPlayer);
}

void playPlayerDeathAudio(){
  _playRandom(_maleScreams, _playerAudioPlayer);
}

void playAudioExplosion(){

}

void playAudioZombieBite(){
  _playRandom(_zombieBite, _zombieAudioPlayer);
}

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
