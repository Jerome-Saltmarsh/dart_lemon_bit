import 'package:audioplayers/audioplayers.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';

AudioPlayer _weaponAudioPlayer = AudioPlayer();
AudioPlayer _zombieAudioPlayer = AudioPlayer();
AudioPlayer _playerAudioPlayer = AudioPlayer();
AudioPlayer _equipAudioPlayer = AudioPlayer();
AudioPlayer _explosionAudioPlayer = AudioPlayer();

List<String> _zombieHits = [
  'zombie-hit-01.wav',
  'zombie-hit-02.wav',
  'zombie-hit-03.wav',
  'zombie-hit-05.wav'
];

List<String> _humanHurt = [
  'male-hurt-01.wav',
  'male-hurt-02.wav',
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

List<String> grenadeExplosions = [
  'explosion-grenade-01.wav',
  'explosion-grenade-04.wav'
];

void playAudioSniperShot(double x, double y) {
  _play('sniper-shot-04.wav', _weaponAudioPlayer, x, y);
}

void playAudioAssaultRifleShot(double x, double y) {
  _play('assault-rifle-shot-04.wav', _weaponAudioPlayer, x, y);
}

void playAudioExplosion(double x, double y) {
  _playRandom(grenadeExplosions, _explosionAudioPlayer, x, y);
}

void playAudioSniperEquipped(double x, double y) {
  _play("gun-pickup-01.wav", _weaponAudioPlayer, x, y);
}

void playAudioReload(double x, double y) {
  _play('reload-06.wav', _equipAudioPlayer, x, y);
}

void playAudioCockShotgun(double x, double y) {
  _play('cock-shotgun-03.wav', _equipAudioPlayer, x, y);
}

void playPlayerDeathAudio(double x, double y) {
  _playRandom(_maleScreams, _playerAudioPlayer, x, y);
}

void playAudioReloadHandgun(double x, double y) {
  _play('mag-in-02.wav', _equipAudioPlayer, x, y);
}

void playAudioClipEmpty(double x, double y) {
  _play('dry-shot-02.wav', _equipAudioPlayer, x, y);
}

void playAudioZombieBite(double x, double y) {
  _playRandom(_zombieBite, _zombieAudioPlayer, x, y);
}

void playAudioZombieTargetAcquired(double x, double y) {
  _playRandom(_zombieTalking, _zombieAudioPlayer, x, y);
}

void playAudioZombieDeath(double x, double y) {
  _playRandom(_zombieDeath, _zombieAudioPlayer, x, y);
}

void playAudioZombieHit(double x, double y) {
  _playRandom(_zombieHits, _zombieAudioPlayer, x, y);
}

void playAudioPlayerHurt(double x, double y){
  _playRandom(_humanHurt, _playerAudioPlayer, x, y);
}

void playAudioShotgunShot(double x, double y) {
  _play('shotgun-shot.mp3', _weaponAudioPlayer, x, y);
}

void playAudioHandgunShot(double x, double y) {
  _play('handgun-shot.mp3', _weaponAudioPlayer, x, y);
}

void _playRandom(List<String> values, AudioPlayer audioPlayer, double x, double y) {
  _play(randomItem(values), audioPlayer, x, y);
}

void _play(String name, AudioPlayer audioPlayer, double x, double y) {
  if (settings.audioMuted) return;

  try {
    double d = distance(x, y, centerX, centerY);
    double volume = 1.0 / ((d * 0.005) + 1);
    if (volume < 0.05) return;
    audioPlayer.play('assets/audio/$name', isLocal: true, volume: volume);
  } catch (error) {
    // audioPlayer.resume();
  }
}
