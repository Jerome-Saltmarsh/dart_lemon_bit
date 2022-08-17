import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_math/library.dart';

import '../lemon_cache/cache.dart';
import 'audio/convert_distance_to_volume.dart';

final audio = _Audio();

class _Audio {

  final soundEnabled = Cache(key: 'audio-enabled', value: true);
  final musicEnabled = Cache(key: 'music-enabled', value: true, onChanged: (bool value){
    print("music enabled: $value");
  });

  void objectStruck(double x, double y) {
    _playPositioned('object-struck.mp3', x, y);
  }

  void materialStruckWood(double x, double y) {
    _playPositioned('material-struck-wood.mp3', x, y);
  }

  void materialStruckRock(double x, double y){
    _playPositioned('material-struck-stone.mp3', x, y);
  }

  void materialStruckMetal(double x, double y){
     objectStruck(x, y);
  }

  void toggleSoundEnabled(){
    soundEnabled.value = !soundEnabled.value;
  }

  void toggleEnabledMusic(){
    musicEnabled.value = !musicEnabled.value;
  }

  void winSound2() {
    play('win-sound-2.mp3');
  }

  void clickSound8(){
    play('click-sound-8.mp3');
  }

  void error(){
    play('error-sound-15.mp3');
  }

  void gong() {
    play('gong.mp3');
  }

  void assaultRifleShot(double x, double y) {
    _playPositioned('assault-rifle-shot.mp3', x, y);
  }

  void explosion(double x, double y) {
    _playRandom(_grenadeExplosions, x, y);
  }

  void sniperEquipped(double x, double y) {
    gunPickup(x, y);
  }

  void gunPickup(double x, double y) {
    _playPositioned("gun-pickup-01.mp3", x, y);
  }

  void potBreaking(double x, double y){
    _playPositioned('pot-breaking.mp3', x, y);
  }

  void arrowImpact(double x, double y) {
    _playPositioned("arrow-impact.mp3", x, y);
  }

  void bloodyImpact(double x, double y) {
    _playPositioned('bloody-impact.mp3', x, y);
  }

  void reload(double x, double y) {
    _playPositioned('reload-06.mp3', x, y);
  }

  void itemAcquired(double x, double y) {
    _playPositioned('item-acquired.mp3', x, y);
  }

  void itemPurchased(double x, double y) {
    _playPositioned('item-purchase-3.mp3', x, y);
  }

  void coins(double x, double y){
    _playPositioned('coins.mp3', x, y);
  }

  void coins24(double x, double y){
    _playPositioned('coins-24.mp3', x, y);
  }

  void bottle(double x, double y){
    _playPositioned('bottle.mp3', x, y);
  }

  void cockShotgun(double x, double y) {
    _playPositioned('cock-shotgun-03.mp3', x, y);
  }

  void maleScream(double x, double y) {
    _playRandom(_maleScreams, x, y);
  }

  void magIn2(double x, double y) {
    _playPositioned('mag-in-02.mp3', x, y);
  }

  void dryShot2(double x, double y) {
    _playPositioned('dry-shot-02.mp3', x, y);
  }

  void zombieBite(double x, double y) {
    _playRandom(_zombieBite, x, y);
  }

  void zombieTargetAcquired(double x, double y) {
    _playRandom(_zombieTalking, x, y);
  }

  void humanHurt(double x, double y) {
    _playRandom(_humanHurt, x, y);
  }

  void handgunShot(double x, double y) {
    _playRandom(_pistolShot, x, y);
  }

  void medkit(double x, double y) {
    audio._playPositioned('medkit.mp3', x, y);
  }

  void buff(double x, double y) {
    audio._playPositioned('buff-1.mp3', x, y);
  }

  void magicalSwoosh(double x, double y) {
    audio._playPositioned('magical-swoosh-18.mp3', x, y);
  }

  void _playPositioned(String name, double x, double y, {double volume = 1.0}) {
    if (!soundEnabled.value) return;
    play(name, volume: _calculateVolume(x, y) * volume);
  }

  void play(String name, {double volume = 1}){
    if (volume.isNaN) return;
    // if (volume <= 0) return;
    if (volume <= 0.025) return;
      // _getAudioPlayer().play(
      //     'assets/audio/$name',
      //     isLocal: true,
      //     volume: volume
      // );
  }


  void playAudioHeal(double x, double y) {
    _playPositioned('revive-heal-1.mp3', x, y);
  }

  void playAudioKnifeStrike(double x, double y) {
    _playRandom(_knifeStrikes, x, y);
  }

  void playAudioThrowGrenade(double x, double y) {
    _playPositioned('throw.mp3', x, y);
  }

  void crateBreaking(double x, double y) {
    _playPositioned('crate-breaking.mp3', x, y);
  }

  void crateDestroyed(double x, double y) {
    _playPositioned('crate-destroyed.mp3', x, y);
  }

  void unlock(double x, double y) {
    _playPositioned('unlock.mp3', x, y);
  }

  void buff11(double x, double y) {
    _playPositioned('buff-11.mp3', x, y);
  }

  void arrowFlyingPast6(double x, double y) {
    _playPositioned('arrow-flying-past-6.mp3', x, y);
  }

  void sciFiBlaster1(double x, double y) {
    _playPositioned('sci-fi-blaster-1.mp3', x, y);
  }

  void collectStar3(double x, double y) {
    _playPositioned('collect-star-3.mp3', x, y);
  }

  void collectStar4(double x, double y) {
    _playPositioned('collect-star-4.mp3', x, y);
  }

  void rockBreaking(double x, double y) {
    _playPositioned('rock-breaking.mp3', x, y);
  }

  void strikeWood(double x, double y) {
    _playPositioned('rock-breaking.mp3', x, y);
  }

  void treeBreaking(double x, double y) {
    _playPositioned('tree-breaking.mp3', x, y);
  }
}

const _humanHurt = [
  'male-hurt-01.mp3',
  'male-hurt-02.wav',
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
  audio._playPositioned(randomItem(values), x, y);
}

double _calculateVolume(double x, double y) {
  return convertDistanceToVolume(distanceBetween(x, y, player.x, player.y), maxDistance: 300);
}



