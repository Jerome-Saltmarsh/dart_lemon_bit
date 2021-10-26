import 'package:audioplayers/audioplayers.dart';
import 'package:bleed_client/engine/render/game_widget.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/utils.dart';

// interface
void initAudioPlayers() {
  for (int i = 0; i < _totalAudioPlayers; i++) {
    _audioPlayers.add(AudioPlayer());
  }
}

void playAudioButtonHover() {
  if (settings.audioMuted) return;
  _getAudioPlayer()
      .play('assets/audio/button-hover.mp3', isLocal: true, volume: 1);
}

void playAudioSniperShot(double x, double y) {
  _playAudio('sniper-shot-04.mp3', x, y);
}

void playAudioAssaultRifleShot(double x, double y) {
  _playAudio('assault-rifle-shot.mp3', x, y);
}

void playAudioExplosion(double x, double y) {
  _playRandom(_grenadeExplosions, x, y);
}

void playAudioSniperEquipped(double x, double y) {
  playAudioGunPickup(x, y);
}

void playAudioGunPickup(double x, double y){
  _playAudio("gun-pickup-01.mp3", x, y);
}

void playAudioReload(double x, double y) {
  _playAudio('reload-06.mp3', x, y);
}

void playAudioCockShotgun(double x, double y) {
  _playAudio('cock-shotgun-03.mp3', x, y);
}

void playPlayerDeathAudio(double x, double y) {
  _playRandom(_maleScreams, x, y);
}

void playAudioReloadHandgun(double x, double y) {
  _playAudio('mag-in-02.mp3', x, y);
}

void playAudioClipEmpty(double x, double y) {
  _playAudio('dry-shot-02.mp3', x, y);
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

void playAudioPlayerHurt(double x, double y) {
  _playRandom(_humanHurt, x, y);
}

void playAudioShotgunShot(double x, double y) {
  _playAudio('shotgun-shot.mp3', x, y);
}

void playAudioHandgunShot(double x, double y) {
  _playRandom(_pistolShot, x, y);
}

void playAudioUseMedkit(double x, double y) {
  _playAudio('medkit.mp3', x, y);
}

void playAudioAcquireItem(double x, double y) {
  _playAudio('item-acquired.mp3', x, y);
}

void playAudioCollectStar(double x, double y){
  _playAudio('collect-star-4.mp3', x, y);
}

void playAudioHeal(double x, double y){
  _playAudio('revive-heal-1.mp3', x, y);
}

void playAudioKnifeStrike(double x, double y) {
  _playRandom(_knifeStrikes, x, y);
}

void playAudioThrowGrenade(double x, double y) {
  _playAudio('throw.mp3', x, y);
}

void playAudioCrateBreaking(double x, double y) {
  _playAudio('crate-breaking.mp3', x, y);
}

// abstraction
int _index = 0;

final List<AudioPlayer> _audioPlayers = [];
const _audioDistanceFade = 0.0065;
const _totalAudioPlayers = 200;

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

const _pistolShot = [
  "pistol-shot-19.mp3",
  "pistol-shot-20.mp3",
  "pistol-shot-21.mp3",
  "pistol-shot-22.mp3",
];

const _maleScreams = [
  'male-screams-01.mp3',
  'male-screams-05.mp3',
  'male-screams-06.mp3',
];

const _grenadeExplosions = [
  'explosion-grenade-01.mp3',
  'explosion-grenade-04.mp3'
];

const _knifeStrikes = [
  'dagger-woosh-1.mp3',
  'dagger-woosh-2.mp3',
];

void _playRandom(List<String> values, double x, double y) {
  _playAudio(randomItem(values), x, y);
}

AudioPlayer _getAudioPlayer() {
  _index = (_index + 1) % _audioPlayers.length;
  return _audioPlayers[_index];
}

void _playAudio(String name, double x, double y) {
  if (settings.audioMuted) return;

  try {
    double volume = _calculateVolume(x, y);
    // if (volume < 0.025) return;
    _getAudioPlayer().play('assets/audio/$name', isLocal: true, volume: volume);
  } catch (error) {
    // innocuous
  }
}

double _calculateVolume(double x, double y) {
  double d = distance(x, y, screenCenterWorldX, screenCenterWorldY);
  double v = 1.0 / ((d * _audioDistanceFade) + 1);
  return v * v;
}
