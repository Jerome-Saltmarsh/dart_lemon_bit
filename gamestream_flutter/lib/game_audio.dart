
import 'package:gamestream_flutter/classes/audio_single.dart';

import 'lemon_cache/cache.dart';
import 'library.dart';


class GameAudio {

  static var nextZombieGrowl = 100;
  static final soundEnabled = Cache(key: 'audio-enabled', value: true);
  static var nextRandomSound = 0;
  static var nextRandomMusic = 0;


  static final musicNight = [
    AudioSingle(name: 'creepy-whistle', volume: 0.1),
    AudioSingle(name: 'creepy-wind', volume: 0.1),
    AudioSingle(name: 'spooky-tribal', volume: 1.0),
  ];

  static final soundsNight = [
    AudioSingle(name: 'owl-1', volume: 0.15),
    AudioSingle(name: 'wolf-howl', volume: 0.1),
    AudioSingle(name: 'creepy-5', volume: 0.2),
  ];

  static final soundsDay = [
    AudioSingle(name: 'wind-chime', volume: 0.25),
  ];

  static final soundsLateAfternoon = [
    AudioSingle(name: 'gong', volume: 0.25),
  ];

  static final audioLoops = <AudioLoop> [
    AudioLoop(name: 'wind', getTargetVolume: getVolumeTargetWind),
    AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
    AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
    AudioLoop(name: 'day-ambience', getTargetVolume: GameAudio.getVolumeTargetDayAmbience),
    AudioLoop(name: 'fire', getTargetVolume: getVolumeTargetFire),
    AudioLoop(name: 'distant-thunder', getTargetVolume: getVolumeTargetDistanceThunder),
    AudioLoop(name: 'heart-beat', getTargetVolume: getVolumeHeartBeat),
    AudioLoop(name: 'stream', getTargetVolume: getVolumeStream),
  ];

  static final popSounds14 = AudioSingle(name: 'pop-sounds-14', volume: 0.5, maxDistance: 100);
  static final coins_24 = AudioSingle(name: 'coins-24', volume: 0.5, maxDistance: 100);
  static final hoverOverButtonSound5 = AudioSingle(name: 'hover-over-button-sound-5', volume: 0.5, maxDistance: 100);
  static final thunder = AudioSingle(name: 'thunder', volume: 0.5, maxDistance: 100);
  static final fireBolt = AudioSingle(name: 'fire-bolt-14', volume: 0.5, maxDistance: 200);
  static final footstep_grass_8 = AudioSingle(name: 'footstep-grass-8', volume: 0.05, maxDistance: 200);
  static final footstep_grass_7 = AudioSingle(name: 'footstep-grass-7', volume: 0.05, maxDistance: 200);
  static final footstep_mud_6 = AudioSingle(name: 'mud-footstep-6', volume: 0.05, maxDistance: 200);
  static final footstep_stone = AudioSingle(name: 'footstep-stone', volume: 0.05, maxDistance: 250);
  static final footstep_wood_4 = AudioSingle(name: 'footstep-wood-4', volume: 0.5, maxDistance: 250);
  static final bow_draw = AudioSingle(name: 'bow-draw', volume: 0.5, maxDistance: 200);
  static final bow_release = AudioSingle(name: 'bow-release', volume: 0.5, maxDistance: 250);
  static final arrow_impact = AudioSingle(name: 'arrow-impact', volume: 0.5, maxDistance: 250);
  static final arrow_flying_past_6 = AudioSingle(name: 'arrow-flying-past-6', volume: 0.5, maxDistance: 250);
  static final notification_sound_10 = AudioSingle(name: 'notification-sound-10', volume: 0.5, maxDistance: 200);
  static final notification_sound_12 = AudioSingle(name: 'notification-sound-12', volume: 0.5, maxDistance: 200);
  static final sci_fi_blaster_1 = AudioSingle(name: 'sci-fi-blaster-1', volume: 0.5, maxDistance: 400);
  static final sci_fi_blaster_8 = AudioSingle(name: 'sci-fi-blaster-8', volume: 0.5, maxDistance: 400);
  static final shotgun_shot = AudioSingle(name: 'shotgun-shot', volume: 0.5, maxDistance: 400);
  static final cock_shotgun_3 = AudioSingle(name: 'cock-shotgun-03', volume: 0.5, maxDistance: 400);
  static final mag_in_03 = AudioSingle(name: 'mag-in-02', volume: 0.5, maxDistance: 400);
  static final sword_unsheathe = AudioSingle(name: 'sword-unsheathe', volume: 0.5, maxDistance: 400);
  static final gun_pickup_01 = AudioSingle(name: 'gun-pickup-01', volume: 0.5, maxDistance: 400);
  static final assault_rifle_shot = AudioSingle(name: 'assault-rifle-shot', volume: 0.5, maxDistance: 400);
  static final sniper_shot_4 = AudioSingle(name: 'sniper-shot-04', volume: 0.5, maxDistance: 400);
  static final revolver_shot_2 = AudioSingle(name: 'revolver-shot-02', volume: 0.5, maxDistance: 400);
  static final revolver_reload_1 = AudioSingle(name: 'revolver-reload-01', volume: 0.5, maxDistance: 400);
  static final reload_6 = AudioSingle(name: 'reload_06', volume: 0.5, maxDistance: 400);
  static final unlock = AudioSingle(name: 'unlock', volume: 0.5, maxDistance: 400);
  static final zombie_hurt_1 = AudioSingle(name: 'zombie-hurt-1', volume: 0.5, maxDistance: 400);
  static final zombie_hurt_4 = AudioSingle(name: 'zombie-hit-04', volume: 0.5, maxDistance: 400);
  static final splash = AudioSingle(name: 'splash', volume: 0.5, maxDistance: 400);
  static final material_struck_wood = AudioSingle(name: 'material-struck-wood', volume: 0.5, maxDistance: 400);
  static final material_struck_stone = AudioSingle(name: 'material-struck-stone', volume: 0.5, maxDistance: 400);
  static final rat_squeak = AudioSingle(name: 'rat-squeak', volume: 0.5, maxDistance: 400);
  static final collect_star_3 = AudioSingle(name: 'collect-star-3', volume: 0.5, maxDistance: 400);
  static final magical_impact_28 = AudioSingle(name: 'magical-impact-28', volume: 0.5, maxDistance: 400);
  static final bloody_punches_1 = AudioSingle(name: 'bloody-punches-1', volume: 1.0, maxDistance: 400);
  static final bloody_punches_3 = AudioSingle(name: 'bloody-punches-3', volume: 1.0, maxDistance: 400);
  static final crate_breaking = AudioSingle(name: 'crate-breaking', volume: 0.5, maxDistance: 400);
  static final male_hello = AudioSingle(name: 'male-hello-1', volume: 0.5, maxDistance: 400);
  static final rooster = AudioSingle(name: 'rooster', volume: 0.5, maxDistance: 400);
  static final change_cloths = AudioSingle(name: 'change-cloths', volume: 0.5, maxDistance: 80);
  static final draw_sword = AudioSingle(name: 'draw-sword', volume: 0.5, maxDistance: 250);
  static final click_sound_8 = AudioSingle(name: 'click-sound-8', volume: 0.5, maxDistance: 250);
  static final swing_arm_11 = AudioSingle(name: 'swing-arm-11', volume: 0.4, maxDistance: 250);
  static final swing_sword = AudioSingle(name: 'swing-sword', volume: 0.4, maxDistance: 250);
  static final arm_swing_whoosh_11 = AudioSingle(name: 'arm-swing-whoosh-11', volume: 0.4, maxDistance: 250);
  static final heavy_punch_13 = AudioSingle(name: 'heavy-punch-13', volume: 1, maxDistance: 250);
  static final pistol_shot_20 = AudioSingle(name: 'pistol-shot-20', volume: 0.4, maxDistance: 250);
  static final grass_cut = AudioSingle(name: 'grass-cut', volume: 0.4, maxDistance: 250);
  static final switch_sounds_4 = AudioSingle(name: 'switch-sounds-4', volume: 0.4, maxDistance: 250);
  static final teleport = AudioSingle(name: 'teleport-1', volume: 0.5, maxDistance: 250);
  static final hover_over_button_sound_30 = AudioSingle(name: 'hover-over-button-sound-30', volume: 0.5, maxDistance: 250);
  static final hover_over_button_sound_43 = AudioSingle(name: 'hover-over-button-sound-43', volume: 0.5, maxDistance: 250);

  static final zombie_deaths = [
    AudioSingle(name: 'zombie-death-02', volume: 1, maxDistance: 400),
    AudioSingle(name: 'zombie-death-09', volume: 1, maxDistance: 400),
    AudioSingle(name: 'zombie-death-15', volume: 1, maxDistance: 400),
  ];
  static final bloody_punches = [bloody_punches_1, bloody_punches_3];
  static final audioSingleZombieBits = [
    AudioSingle(name: 'zombie-bite-04', volume: 0.4, maxDistance: 250),
    AudioSingle(name: 'zombie-bite-05', volume: 0.4, maxDistance: 250),
  ];
  static final audioSingleZombieTalking = [
    AudioSingle(name: 'zombie-talking-03', volume: 0.4, maxDistance: 350),
    AudioSingle(name: 'zombie-talking-04', volume: 0.4, maxDistance: 350),
    AudioSingle(name: 'zombie-talking-05', volume: 0.4, maxDistance: 350),
  ];

  static double getVolumeTargetDayAmbience() {
    if (GameState.ambientShade.value == Shade.Very_Bright) return 0.2;
    return 0;
  }

  static void updateRandomAmbientSounds(){
    if (nextRandomSound-- > 0) return;
    playRandomAmbientSound();
    nextRandomSound = Engine.randomInt(200, 1000);
  }

  static void updateRandomMusic(){
    if (nextRandomMusic-- > 0) return;
    playRandomMusic();
    nextRandomMusic = Engine.randomInt(800, 2000);
  }

  static var _nextAudioSourceUpdate = 0;

  static void update() {
    if (_nextAudioSourceUpdate-- <= 0){
      _nextAudioSourceUpdate = 5;
      for (final audioSource in audioLoops){
        audioSource.update();
      }
    }
    updateRandomAmbientSounds();
    updateRandomMusic();
    updateZombieGrowls();
  }

  static double getVolumeTargetWind() {
    final windLineDistance = (Engine.screenCenterRenderX - GameQueries.windLineRenderX).abs();
    final windLineDistanceVolume = convertDistanceToVolume(windLineDistance, maxDistance: 300);
    var target = 0.0;
    if (GameQueries.windLineRenderX - 250 <= Engine.screenCenterRenderX) {
      target += windLineDistanceVolume;
    }
    final index = GameState.windAmbient.value.index;
    if (index <= windIndexCalm) {
      if (GameState.hours.value < 6) return target;
      if (GameState.hours.value < 18) return target + 0.1;
      return target;
    }
    if (index <= windIndexGentle) return target + 0.5;
    return 1.0;
  }

  static double getVolumeTargetRain() {
    if (GameState.rain.value == Rain.None) return 0.0;
    const r = 7;
    const maxDistance = r * tileSize;
    final distance = GameQueries.getClosestByType(radius: r, type: NodeType.Rain_Landing) * tileSize;
    final v = convertDistanceToVolume(distance, maxDistance: maxDistance);
    return v * (GameState.rain.value == Rain.Light ? 0.5 : 1.0) * 0.5;
  }

  static double getVolumeTargetCrickets() {
    final hour = GameState.hours.value;
    const max = 0.8;
    if (hour >= 5 && hour < 7) return max;
    if (hour >= 17 && hour < 19) return max;
    return 0;
  }

  static double getVolumeTargetFire(){
    const r = 4;
    const maxDistance = r * tileSize;
    var closest = GameQueries.getClosestByType(radius: r, type: NodeType.Fireplace) * tileSize;
    if (GameState.torchesIgnited.value) {
      final closestTorch = GameQueries.getClosestByType(radius: r, type: NodeType.Torch) * tileSize;
      if (closestTorch < closest) {
        closest = closestTorch;
      }
    }
    return convertDistanceToVolume(closest, maxDistance: maxDistance) * 1.0;
  }

  static double getVolumeTargetDistanceThunder(){
    if (GameState.lightningOn) return 1.0;
    return 0;
  }

  static double getVolumeHeartBeat(){
    return 1.0 - ServerState.playerHealth.value / ServerState.playerMaxHealth.value;
  }

  static double getVolumeStream(){
    const r = 7;
    const maxDistance = r * tileSize;
    final distance = GameQueries.getClosestByType(radius: r, type: NodeType.Water_Flowing) * tileSize;
    return convertDistanceToVolume(distance, maxDistance: maxDistance) * 0.3;
  }

  static void playAudioSingle(AudioSingle audioSingle, double x, double y, double z){
    // TODO calculate from screen center instead
    final distanceFromPlayer = GamePlayer.position.distance3(x, y, z);
    final distanceVolume = convertDistanceToVolume(
      distanceFromPlayer,
      maxDistance: audioSingle.maxDistance,
    );
    audioSingle.play(volume: distanceVolume);
  }

  static double convertDistanceToVolume(double distance, {required double maxDistance}){
    if (distance > maxDistance) return 0;
    if (distance < 1) return 1.0;
    final perc = distance / maxDistance;
    return 1.0 - perc;
  }

  static void playRandomMusic(){
    if (GameState.ambientShade.value == Shade.Pitch_Black) {
      playRandom(musicNight);
    }
  }

  static void playRandomAmbientSound(){
    final hour = GameState.hours.value;

    final shade = GameState.ambientShade.value;

    if (shade == Shade.Pitch_Black || shade == Shade.Very_Dark){
      return playRandom(soundsNight);
    }
    if (hour == 6){
      return GameAudio.rooster.play(volume: 0.3);
    }

    if (hour > 9 && hour < 15) {
      return playRandom(soundsDay);
    }
    if (hour >= 15 && hour < 18) {
      return playRandom(soundsLateAfternoon);
    }
  }

  static void playRandom(List<AudioSingle> items){
    Engine.randomItem(items).play();
  }

  static void updateZombieGrowls(){
    if (GameState.totalZombies <= 0) return;
    nextZombieGrowl--;
    if (nextZombieGrowl > 0) return;
    nextZombieGrowl = Engine.randomInt(200, 300);
    Engine.randomItem(GameAudio.audioSingleZombieTalking).playV3(GameState.zombies[Engine.randomInt(0, GameState.totalZombies)]);
  }
}