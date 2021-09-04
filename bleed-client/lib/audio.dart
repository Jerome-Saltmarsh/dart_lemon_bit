import 'package:audioplayers/audioplayers.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:bleed_client/instances/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';

List<AudioPlayer> _audioPlayers = [];

const _totalAudioPlayers = 150;

const _zombieHits = [
  'zombie-hit-01.mp3',
  'zombie-hit-02.mp3',
  'zombie-hit-03.mp3',
  'zombie-hit-05.mp3'
];

const _humanHurt = [
  'male-hurt-01.mp3',
  'male-hurt-02.wav',
];

const _zombieDeath = [
  'zombie-death-02.mp3',
  'zombie-death-09.mp3',
  'zombie-death-15.mp3',
];

const _zombieTalking = [
  'zombie-talking-03.mp3',
  'zombie-talking-04.mp3',
  'zombie-talking-05.mp3',
];

const _zombieBite = [
  'zombie-bite-04.mp3',
  'zombie-bite-05.mp3',
  'bloody-punches-1.mp3',
  'bloody-punches-2.mp3',
  'bloody-punches-3.mp3',
];

const _maleScreams = [
  'male-screams-01.mp3',
  'male-screams-05.mp3',
  'male-screams-06.mp3',
];

const grenadeExplosions = [
  'explosion-grenade-01.mp3',
  'explosion-grenade-04.mp3'
];


void initAudioPlayers(){
  for(int i = 0; i < _totalAudioPlayers; i++){
    _audioPlayers.add(AudioPlayer());
  }
}

void playAudioSniperShot(double x, double y) {
  _play('sniper-shot-04.mp3', x, y);
}

void playAudioAssaultRifleShot(double x, double y) {
  _play('assault-rifle-shot-04.mp3', x, y);
}

void playAudioExplosion(double x, double y) {
  _playRandom(grenadeExplosions, x, y);
}

void playAudioSniperEquipped(double x, double y) {
  _play("gun-pickup-01.mp3", x, y);
}

void playAudioReload(double x, double y) {
  _play('reload-06.mp3', x, y);
}

void playAudioCockShotgun(double x, double y) {
  _play('cock-shotgun-03.mp3', x, y);
}

void playPlayerDeathAudio(double x, double y) {
  _playRandom(_maleScreams, x, y);
}

void playAudioReloadHandgun(double x, double y) {
  _play('mag-in-02.mp3', x, y);
}

void playAudioClipEmpty(double x, double y) {
  _play('dry-shot-02.mp3', x, y);
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

void playAudioUseMedkit(double x, double y){
  _play('medkit.mp3', x, y);
}

void playAudioAcquireItem(double x, double y){
  _play('item-acquired.mp3', x, y);
}

void playAudioThrowGrenade(double x, double y){
  _play('throw.mp3', x, y);
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
    double d = distance(x, y, screenCenterWorldX, screenCenterWorldY);
    double volume = 1.0 / ((d * 0.005) + 1);
    if (volume < 0.1) return;
    _getAudioPlayer().play('assets/audio/$name', isLocal: true, volume: volume);
  } catch (error) {
    print(error);
  }
}
