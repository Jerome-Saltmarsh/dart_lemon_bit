import 'package:gamestream_flutter/isometric/grid/state/wind.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/weather.dart';
import 'package:gamestream_flutter/isometric/time.dart';
import 'package:gamestream_flutter/isometric/utils/screen_utils.dart';
import 'package:gamestream_flutter/isometric/weather/breeze.dart';
import 'package:lemon_math/library.dart';
import 'package:just_audio/just_audio.dart';
import '../cache.dart';

final audio = _Audio();

class AudioLoop {
  final String name;
  var volume = 0.0;
  double Function() getTargetVolume;
  final audioPlayer = AudioPlayer();
  late Duration duration;
  var durationInSeconds = 0;

  AudioLoop({required this.name, required this.getTargetVolume}) {
    load();
  }

  void load() async {
    final d = await audioPlayer.setUrl('assets/audio/sounds/$name.mp3');
    audioPlayer.play();
    audioPlayer.positionStream.listen(onPositionChanged);
    if (d == null) throw Exception("could not get duration for $name");
    durationInSeconds = d.inSeconds;
    duration = d;
    audioPlayer.setLoopMode(LoopMode.one);
  }

  void onPositionChanged(Duration duration){
     if (duration.inSeconds < durationInSeconds) return;
     restart();
  }

  void restart(){
    audioPlayer.seek(const Duration());
  }

  void update(){
    final change = (getTargetVolume() - volume) * 0.05;
    volume = clamp(volume + change, 0, 1.0);
    audioPlayer.setVolume(volume);
  }
}

class _Audio {

  final audioSourceThunder = AudioSource.uri(Uri.parse('assets/audio/thunder.mp3'));
  final audioThunder = AudioPlayer()..setUrl('assets/audio/thunder.mp3');

  final audioLoops = <AudioLoop>[
    AudioLoop(name: 'wind', getTargetVolume: getVolumeTargetWind),
    AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
    AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
    AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
  ];

  void update(){
    for (final audioSource in audioLoops){
      audioSource.update();
    }
  }

  double get windVolumeAmbientTarget {
     if (windAmbient.value <= Wind.Calm) return 0.1;
     if (windAmbient.value <= Wind.Gentle) return 0.5;
     return 1.0;
  }

  var trackIndex = 0;

  final tracks = [
    'song01',
    'song02',
    'song03',
    'song04',
  ];

  final soundEnabled = Cache(key: 'audio-enabled', value: true);
  final musicEnabled = Cache(key: 'music-enabled', value: true, onChanged: (bool value){
    print("music enabled: $value");
     if (value){
       _musicPlayer.setVolume(1.0);
     } else {
       _musicPlayer.setVolume(0);
     }
  });


  void playRandomSong(){
    trackIndex = randomInt(0, tracks.length) % tracks.length;
    _playMusic(tracks[trackIndex]);
  }

  void objectStruck(double x, double y) {
    _playPositioned('object-struck.mp3', x, y);
  }

  void materialStruckWood(double x, double y) {
    _playPositioned('material-struck-wood.mp3', x, y);
  }

  void footstepGrass(double x, double y) {
    // _playPositioned('step-grass.mp3', x, y, volume: 0.15);
  }

  void materialStruckRock(double x, double y){
    _playPositioned('material-struck-stone.mp3', x, y);
  }

  void materialStruckFlesh(double x, double y){
   if (random.nextBool()){
     _playPositioned('bloody-punches-1.mp3', x, y);
   } else {
     bloodyImpact(x, y);
   }
  }

  void materialStruckMetal(double x, double y){
     objectStruck(x, y);
  }

  void stopMusic(){
    _musicPlayer.stop();
  }

  void toggleSoundEnabled(){
    soundEnabled.value = !soundEnabled.value;
  }

  void nextSong(){
     trackIndex++;
     trackIndex %= tracks.length;
     _playMusic(tracks[trackIndex]);
  }

  void toggleEnabledMusic(){
    musicEnabled.value = !musicEnabled.value;
  }

  void sniperShot(double x, double y) {
    _playPositioned('sniper-shot-04.mp3', x, y);
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

  void drawBow(double x, double y) {
    _playPositioned("draw-bow.mp3", x, y);
  }

  void releaseBow(double x, double y) {
    _playPositioned('release-bow.mp3', x, y);
  }

  void swordWoosh(double x, double y) {
    _playPositioned('sword-woosh.mp3', x, y);
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

  void zombieDeath(double x, double y) {
    _playRandom(_zombieDeath, x, y);
  }

  void zombieHurt(double x, double y){
    _playRandom(_zombieHurt, x, y);
  }

  void playAudioZombieHit(double x, double y) {
    _playRandom(_zombieHits, x, y);
  }

  void humanHurt(double x, double y) {
    _playRandom(_humanHurt, x, y);
  }

  void shotgunShot(double x, double y) {
    audio._playPositioned('shotgun-shot.mp3', x, y);
  }

  void firebolt(double x, double y) {
    audio._playPositioned('fire-bolt-3.mp3', x, y);
  }

  void handgunShot(double x, double y) {
    _playRandom(_pistolShot, x, y);
  }

  void changeCloths(double x, double y){
    audio._playPositioned('change-cloths.mp3', x, y);
  }

  void drawSword(double x, double y){
    audio._playPositioned('draw-sword.mp3', x, y);
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

  void lightning(){
    audioThunder.setAudioSource(audioSourceThunder);
    audioThunder.seek(const Duration());
    audioThunder.play();

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

  void _playMusic(String name){
    _musicPlayer.stop();
    if (!musicEnabled.value) return;
    // _musicPlayer.play(
    //     'assets/audio/music/$name.mp3',
    //     isLocal: true,
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

// abstraction
final _musicPlayer = AudioPlayer();

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

const _zombieHurt = [
  'zombie-hurt-1.mp3',
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
  return convertDistanceToVolume(distanceBetween(x, y, player.x, player.y));
}

double convertDistanceToVolume(double distance){
  const distanceFade = 0.0065;
  final v = 1.0 / ((distance * distanceFade) + 1);
  return v * v;
}


double getVolumeTargetWind() {
  final windLineDistance = (screenCenterRenderX - windLineRenderX).abs();
  final windLineDistanceVolume = convertDistanceToVolume(windLineDistance);
  var target = 0.0;
  if (windLineRenderX - 250 <= screenCenterRenderX) {
    target += windLineDistanceVolume;
  }
  if (windAmbient.value <= Wind.Calm) return target + 0.1;
  if (windAmbient.value <= Wind.Gentle) return target + 0.5;
  return 1.0;
}

double getVolumeTargetRain() => raining ? 1 : 0;

double getVolumeTargetCrickets() {
   final hour = hours.value;
   if (hour >= 5 && hour < 7) return 1.0;
   if (hour >= 17 && hour < 19) return 1.0;
   return 0;
}

double getVolumeTargetDayAmbience() {
  final hour = hours.value;
  if (hour >= 10 && hour < 15) return 0.1;
  return 0;
}