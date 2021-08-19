import 'package:audioplayers/audioplayers.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';

List<AudioPlayer> _audioPlayers = [];

const _totalAudioPlayers = 150;

const _zombieHits = [
  'zombie-hit-01.wav',
  'zombie-hit-02.wav',
  'zombie-hit-03.wav',
  'zombie-hit-05.wav'
];

const _humanHurt = [
  'male-hurt-01.wav',
  'male-hurt-02.wav',
];

const _zombieDeath = [
  'zombie-death-02.wav',
  'zombie-death-09.wav',
  'zombie-death-15.wav',
];

const _zombieTalking = [
  'zombie-talking-03.wav',
  'zombie-talking-04.wav',
  'zombie-talking-05.wav',
];

const _zombieBite = [
  'zombie-bite-04.wav',
  'zombie-bite-05.wav',
  'bloody-punches-1.wav',
  'bloody-punches-2.wav',
  'bloody-punches-3.wav',
];

const _maleScreams = [
  'male-screams-01.wav',
  'male-screams-05.wav',
  'male-screams-06.wav',
];

const grenadeExplosions = [
  'explosion-grenade-01.wav',
  'explosion-grenade-04.wav'
];


void initAudioPlayers(){
  for(int i = 0; i < _totalAudioPlayers; i++){
    _audioPlayers.add(AudioPlayer());
  }
}

void playAudioSniperShot(double x, double y) {
  _play('sniper-shot-04.wav', x, y);
}

void playAudioAssaultRifleShot(double x, double y) {
  _play('assault-rifle-shot-04.wav', x, y);
}

void playAudioExplosion(double x, double y) {
  _playRandom(grenadeExplosions, x, y);
}

void playAudioSniperEquipped(double x, double y) {
  _play("gun-pickup-01.wav", x, y);
}

void playAudioReload(double x, double y) {
  _play('reload-06.wav', x, y);
}

void playAudioCockShotgun(double x, double y) {
  _play('cock-shotgun-03.wav', x, y);
}

void playPlayerDeathAudio(double x, double y) {
  _playRandom(_maleScreams, x, y);
}

void playAudioReloadHandgun(double x, double y) {
  _play('mag-in-02.wav', x, y);
}

void playAudioClipEmpty(double x, double y) {
  _play('dry-shot-02.wav', x, y);
}

void playAudioZombieBite(double x, double y) {
  _playRandom(_zombieBite, x, y);
}

void playAudioZombieTargetAcquired(double x, double y) {
  _playRandom(_zombieTalking, x, y);
}

void playAudioZombieDeath(double x, double y) {
  _playRandom(_zombieDeath, x, y);
}

void playAudioZombieHit(double x, double y) {
  _playRandom(_zombieHits, x, y);
}

void playAudioPlayerHurt(double x, double y){
  _playRandom(_humanHurt, x, y);
}

void playAudioShotgunShot(double x, double y) {
  _play('shotgun-shot.mp3', x, y);
}

void playAudioHandgunShot(double x, double y) {
  _play('handgun-shot.mp3', x, y);
}

void _playRandom(List<String> values, double x, double y) {
  _play(randomItem(values), x, y);
}

//
int _index = 0;

AudioPlayer _getAudioPlayer(){
  _index = (_index + 1) % _audioPlayers.length;
  return _audioPlayers[_index];
}

void _play(String name, double x, double y) {
  if (settings.audioMuted) return;

  try {
    double d = distance(x, y, centerX, centerY);
    double volume = 1.0 / ((d * 0.005) + 1);
    if (volume < 0.1) return;
    _getAudioPlayer().play('assets/audio/$name', isLocal: true, volume: volume);
  } catch (error) {
    print(error);
  }
}
