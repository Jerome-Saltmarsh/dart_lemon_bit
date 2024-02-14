
import 'dart:async';
import 'dart:math';

import 'package:amulet_engine/common.dart';
import 'package:amulet_flutter/isometric/functions/get_render.dart';

import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/isometric/classes/position.dart';
import 'package:amulet_flutter/packages/lemon_components.dart';
import 'package:lemon_math/src.dart';
import '../../audio/audio_loop.dart';
import '../../audio/audio_single.dart';
import 'package:lemon_watch/src.dart';

class IsometricAudio with IsometricComponent implements Updatable {

  late final mutedMusic = Watch(false, onChanged: (bool muted){
    print('music muted: $muted');
  });

  late final enabledSound = Watch(true, onChanged: (bool soundEnabled){
    print('sound enabled: $soundEnabled');
    for (final audioLoop in audioLoops) {
      audioLoop.setVolume(0);
      if (soundEnabled) {
        audioLoop.audioPlayer.resume();
      } else {
        audioLoop.audioPlayer.pause();
      }
    }
  });

  var nextCharacterNoise = 100;
  var nextRandomSound = 0;
  var nextRandomMusic = 0;

  late final musicNight = [
    creepyWhistle,
    creepyWind,
    spookyTribal,
  ];

  late final soundsNight = [
    owl1,
    creepy5,
  ];

  late final soundsDay = [
    windChime,
  ];

  late final soundsLateAfternoon = [
    gong,
  ];

  late final audioLoopFire = AudioLoop(
      name: 'fire',
      getTargetVolume: getVolumeFire,
      volumeFade: 1.0,
  );

  late final audioLoopTrack02 = AudioLoop(
      name: 'music/track02',
      getTargetVolume: getVolumeMusic,
      volumeFade: 1.0,
  );

  late final audioLoopTrack04 = AudioLoop(
      name: 'music/track_04',
      getTargetVolume: getVolumeMusic,
      volumeFade: 1.0,
  );

  late final audioLoops = <AudioLoop> [
    AudioLoop(name: 'wind', getTargetVolume: environment.getVolumeTargetWind),
    AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
    AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
    AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
    AudioLoop(name: 'distant-thunder', getTargetVolume: getVolumeTargetDistanceThunder),
    audioLoopFire,
    // audioLoopTrack02,
    audioLoopTrack04,
  ];

  late final audioSingles = <AudioSingle>[
    owl1,
    creepy5,
    windChime,
    gong,
    creepyWhistle,
    waterDrop,
    unlock_2,
    jump,
    creepyWind,
    spookyTribal,
    dog_woolf_howl_4,
    wolf_howl,
    weaponSwap2,
    eat,
    reviveHeal1,
    drink,
    buff_1,
    buff_10,
    errorSound15,
    popSounds14,
    coins,
    coins_24,
    hoverOverButtonSound5,
    thunder,
    fire_bolt_14,
    dagger_woosh_9,
    metal_light_3,
    footstep_grass_8,
    footstep_grass_7,
    footstep_mud_6,
    footstep_stone,
    footstep_wood_4,
    bow_draw,
    debuff_4,
    buff_16,
    buff_19,
    bow_release,
    arrow_impact,
    arrow_flying_past_6,
  ];

  final owl1 = AudioSingle(name: 'owl-1');
  final creepy5 = AudioSingle(name: 'creepy-5');
  final celestialVoiceAngel = AudioSingle(name: 'music/celestial_voice_angel');
  final windChime = AudioSingle(name: 'wind-chime');
  final gong = AudioSingle(name: 'gong');
  final creepyWhistle = AudioSingle(name: 'creepy-whistle');
  final creepyWind = AudioSingle(name: 'creepy-wind');
  final spookyTribal = AudioSingle(name: 'spooky-tribal');
  final waterDrop = AudioSingle(name: 'sounds/water_drip');
  final unlock_2 = AudioSingle(name: 'sounds/unlock_2');
  final jump = AudioSingle(name: 'sounds/jump');
  final dog_woolf_howl_4 = AudioSingle(name: 'dog-woolf-howl-4');
  final growl10 = AudioSingle(name: 'sounds/growl_10');
  final wolf_howl = AudioSingle(name: 'wolf-howl');
  final weaponSwap2 = AudioSingle(name: 'weapon-swap-2');
  final eat = AudioSingle(name: 'eat');
  final reviveHeal1 = AudioSingle(name: 'revive-heal-1');
  final drink = AudioSingle(name: 'drink-potion-2');
  final buff_1 = AudioSingle(name: 'buff-1');
  final buff_10 = AudioSingle(name: 'buff-10');
  final errorSound15 = AudioSingle(name: 'error-sound-15');
  final popSounds14 = AudioSingle(name: 'pop-sounds-14');
  final coins = AudioSingle(name: 'coins');
  final coins_24 = AudioSingle(name: 'coins-24');
  final hoverOverButtonSound5 = AudioSingle(name: 'hover-over-button-sound-5');
  final thunder = AudioSingle(name: 'thunder');
  final fire_bolt_14 = AudioSingle(name: 'fire-bolt-14');
  final dagger_woosh_9 = AudioSingle(name: 'dagger_woosh_9');
  final metal_light_3 = AudioSingle(name: 'metal-light-3');

  final footstep_grass_8 = AudioSingle(name: 'footstep-grass-8');
  final footstep_grass_7 = AudioSingle(name: 'footstep-grass-7');
  final footstep_mud_6 = AudioSingle(name: 'mud-footstep-6');
  final footstep_stone = AudioSingle(name: 'footstep-stone');
  final footstep_wood_4 = AudioSingle(name: 'footstep-wood-4');
  final bow_draw = AudioSingle(name: 'bow-draw');
  final debuff_4 = AudioSingle(name: 'debuff-4');
  final buff_16 = AudioSingle(name: 'buff-16');
  final buff_19 = AudioSingle(name: 'buff-19');
  final bow_release = AudioSingle(name: 'bow-release');
  final arrow_impact = AudioSingle(name: 'arrow-impact');
  final arrow_flying_past_6 = AudioSingle(name: 'arrow-flying-past-6');
  final notification_sound_10 = AudioSingle(name: 'notification-sound-10');
  final notification_sound_12 = AudioSingle(name: 'notification-sound-12');
  final sci_fi_blaster_1 = AudioSingle(name: 'sci-fi-blaster-1');
  final sci_fi_blaster_8 = AudioSingle(name: 'sci-fi-blaster-8');
  final cash_register_4 = AudioSingle(name: 'cash_register_4');
  final mag_in_03 = AudioSingle(name: 'mag-in-02');
  final sword_unsheathe = AudioSingle(name: 'sword-unsheathe');
  final unlock = AudioSingle(name: 'unlock');
  final zombie_hurt_1 = AudioSingle(name: 'zombie-hurt-1');
  final zombie_hurt_4 = AudioSingle(name: 'zombie-hit-04');
  final splash = AudioSingle(name: 'splash');
  final material_struck_metal = AudioSingle(name: 'sounds/material_struck_glass');
  final material_struck_flesh = AudioSingle(name: 'sounds/material_struck_flesh');
  final material_struck_wood = AudioSingle(name: 'sounds/material_struck_wood');
  final material_struck_glass = AudioSingle(name: 'sounds/material_struck_glass');
  final material_struck_stone = AudioSingle(name: 'sounds/material_struck_stone');
  final material_struck_dirt = AudioSingle(name: 'sounds/material_struck_dirt');
  final rat_squeak = AudioSingle(name: 'rat-squeak');
  final collect_star_3 = AudioSingle(name: 'collect-star-3');
  final magical_impact_16 = AudioSingle(name: 'magical-impact-16');
  final magical_impact_28 = AudioSingle(name: 'magical-impact-28');
  final magical_swoosh_18 = AudioSingle(name: 'sounds/magical_swoosh_18');
  final bloody_punches_1 = AudioSingle(name: 'bloody-punches-1');
  final bloody_punches_3 = AudioSingle(name: 'bloody-punches-3');
  final crate_breaking = AudioSingle(name: 'crate-breaking');
  final male_hello = AudioSingle(name: 'male-hello-1');
  final rooster = AudioSingle(name: 'rooster');
  final change_cloths = AudioSingle(name: 'change-cloths');
  final draw_sword = AudioSingle(name: 'draw-sword');
  final click_sound_8 = AudioSingle(name: 'click-sound-8');
  final click_sounds_35 = AudioSingle(name: 'ui/click_sounds_35');
  final swing_arm_11 = AudioSingle(name: 'swing-arm-11');
  final swing_sword = AudioSingle(name: 'swing-sword');
  final arm_swing_whoosh_11 = AudioSingle(name: 'arm-swing-whoosh-11');
  final heavy_punch_13 = AudioSingle(name: 'heavy-punch-13');
  final grass_cut = AudioSingle(name: 'grass-cut');
  final switch_sounds_4 = AudioSingle(name: 'switch-sounds-4');
  final teleport = AudioSingle(name: 'teleport-1');
  final hover_over_button_sound_30 = AudioSingle(name: 'hover-over-button-sound-30');
  final hover_over_button_sound_43 = AudioSingle(name: 'hover-over-button-sound-43');
  final explosion_grenade_04 = AudioSingle(name: 'explosion_grenade_04');

  final zombie_deaths = [
    AudioSingle(name: 'zombie-death-02'),
    AudioSingle(name: 'zombie-death-09'),
    AudioSingle(name: 'zombie-death-15'),
  ];
  late final bloody_punches = [bloody_punches_1, bloody_punches_3];
  final audioSingleZombieBits = [
    AudioSingle(name: 'zombie-bite-04'),
    AudioSingle(name: 'zombie-bite-05'),
  ];
  final audioSingleZombieTalking = [
    AudioSingle(name: 'zombie-talking-03'),
    AudioSingle(name: 'zombie-talking-04'),
    AudioSingle(name: 'zombie-talking-05'),
  ];

  double getVolumeTargetDayAmbience() {
    if (!enabledSound.value) {
      return 0;
    }

    final hours = environment.hours.value;
    if (hours > 8 && hours < 4) return 0.2;
    return 0;
  }

  void updateRandomAmbientSounds(){
    if (nextRandomSound-- > 0) return;
    playRandomAmbientSound();
    nextRandomSound = randomInt(200, 1000);
  }

  void updateRandomMusic(){
    if (nextRandomMusic-- > 0) return;
    playRandomMusic();
    nextRandomMusic = randomInt(800, 2000);
  }

  var _nextAudioSourceUpdate = 0;

  void onComponentUpdate() {
    if (!audio.enabledSound.value) {
      return;
    }

    updateAudioLoops();
    updateRandomAmbientSounds();
    updateRandomMusic();
    updateCharacterNoises();
  }

  void updateAudioLoops() {
    if (_nextAudioSourceUpdate-- > 0) return;
    _nextAudioSourceUpdate = 5;
    final loops = audioLoops;
    for (final audioLoop in loops) {
      audioLoop.update();
    }
  }

  double getVolumeTargetRain() {
    if (!enabledSound.value) {
      return 0;
    }

    switch (environment.rainType.value){
      case RainType.None:
        return 0;
      case RainType.Light:
        return 0.5;
      case RainType.Heavy:
        return 1;
      default:
        throw Exception('gamestream.audio.getVolumeTargetRain()');
    }
  }

  double getVolumeTargetCrickets() {
    if (!enabledSound.value) {
      return 0;
    }

    final hour = environment.hours.value;
    const max = 0.8;
    if (hour >= 5 && hour < 7) return max;
    if (hour >= 17 && hour < 19) return max;
    return 0;
  }

  double getVolumeTargetDistanceThunder(){
    if (!enabledSound.value) {
      return 0;
    }

    if (environment.lightningOn) return 1.0;
    return 0;
  }

  double getDistanceFromScreenCenter(double x, double y, double z){
    final engine = this.engine;
    final screenCenterWorldX = engine.screenCenterWorldX;
    final screenCenterWorldY = engine.screenCenterWorldY;
    final screenCenterGridX = convertRenderToSceneX(screenCenterWorldX, screenCenterWorldY);
    final screenCenterGridY = convertRenderToSceneY(screenCenterWorldX, screenCenterWorldY);
    return getDistanceXYZ(x, y, z, screenCenterGridX, screenCenterGridY, player.z);
  }

  double getVolumeFire() {

    final scene = this.scene;
    final nodeLightSourcesTotal = scene.nodeLightSourcesTotal;
    final nodeLightSources = scene.nodeLightSources;
    final nodeTypes = scene.nodeTypes;

    var nearestDistance = 10000.0;

    for (var i = 0; i < nodeLightSourcesTotal; i++){
      final nodeIndex = nodeLightSources[i];
      final nodeType = nodeTypes[nodeIndex];

      if (!const [
        NodeType.Torch,
        NodeType.Fireplace,
        NodeType.Torch_Red,
        NodeType.Torch_Blue,
      ].contains(nodeType)) {
        continue;
      }

      final nodeX = scene.getIndexPositionX(nodeIndex);
      final nodeY = scene.getIndexPositionY(nodeIndex);
      final nodeZ = scene.getIndexPositionZ(nodeIndex);

      final nodeDistanceFromScreenCenter = getDistanceFromScreenCenter(
          nodeX,
          nodeY,
          nodeZ,
      );

      if (nodeDistanceFromScreenCenter > nearestDistance){
        continue;
      }

      nearestDistance = nodeDistanceFromScreenCenter;
    }

    return convertDistanceToVolume(nearestDistance, maxDistance: 100);
  }

  double getVolumeHeartBeat(){
    if (player.maxHealth.value <= 0) return 0.0;
    return 1.0 - player.health.value / player.maxHealth.value;
  }

  void playAudioSingle2D(AudioSingle audioSingle, double x, double y){
    if (!enabledSound.value) return;
    final distanceX = engine.screenCenterWorldX - x;
    final distanceY = engine.screenCenterWorldY - y;
    final distance = hyp2(distanceX, distanceY);
    final distanceSqrt = sqrt(distance);
    final distanceSrtClamped = max(distanceSqrt * 0.5, 1);
    audioSingle.play(volume: 1 / distanceSrtClamped);
  }

  static double convertDistanceToVolume(double distance, {required double maxDistance}){
    if (distance > maxDistance) return 0;
    if (distance < 1) return 1.0;
    final perc = distance / maxDistance;
    return 1.0 - perc;
  }

  void playRandomMusic(){
    final hours = environment.hours.value;
    if (hours > 22 && hours < 3) {
      playRandom(musicNight);
    }
  }

  void playRandomAmbientSound(){
    final hour = environment.hours.value;

    if (hour > 22 && hour < 4){
      playRandom(soundsNight);
      return;
    }
    if (hour == 6 && randomBool()){
      rooster.play(volume: 0.3);
      return;
    }

    // if (hour > 9 && hour < 15) {
    //   return playRandom(soundsDay);
    // }
    // if (hour >= 15 && hour < 18) {
    //   playRandom(soundsLateAfternoon);
    //   return;
    // }
  }

  void playRandom(List<AudioSingle> items){
    randomItem(items).play();
  }

  void updateCharacterNoises(){
    if (scene.totalCharacters <= 0) return;
    if (nextCharacterNoise-- > 0) return;
    nextCharacterNoise = randomInt(200, 300);

    final index = randomInt(0, scene.totalCharacters);
    final character = scene.characters[index];

    if (character.dead){
      return;
    }

    switch (character.characterType) {
      case CharacterType.Fallen:
        playAudioSingleV3(
            audioSingle: randomItem(audio.audioSingleZombieTalking),
            position: character,
            maxDistance: 300,
        );
        break;
      // case CharacterType.Dog:
      //   playAudioSingleV3(
      //       audioSingle: audio.dog_woolf_howl_4,
      //       position: character,
      //       maxDistance: 500,
      //   );
      //   break;
    }
  }

  late final MapItemTypeAudioSinglesAttackMelee = <int, AudioSingle> {
    WeaponType.Unarmed: swing_arm_11,
    WeaponType.Staff: dagger_woosh_9,
    WeaponType.Shortsword: dagger_woosh_9,
  };

  void play(
      AudioSingle audioSingle,
      double x,
      double y,
      double z,{
        double maxDistance = 600,
        double volume = 1.0,
      }){
    if (!enabledSound.value) return;

    final distanceFromScreenCenter = getDistanceFromScreenCenter(x, y, z);

    if (distanceFromScreenCenter > maxDistance){
      return;
    }

    final distanceVolume = convertDistanceToVolume(
      distanceFromScreenCenter,
      maxDistance: maxDistance,
    );
    audioSingle.play(volume: distanceVolume * volume);
  }

  void playAudioSingleV3({
    required AudioSingle audioSingle,
    required Position position,
    double maxDistance = 600}) => play(
    audioSingle,
    position.x,
    position.y,
    position.z,
    maxDistance: maxDistance,
  );

  void playAudioError() => playSound(errorSound15);

  void playSound(AudioSingle audioSingle, {double volume = 1.0}){
    if (!enabledSound.value) return;
    audioSingle.play(volume: volume);
  }

  void toggleMutedSound() => enabledSound.value = !enabledSound.value;

  void toggleMutedMusic() => mutedMusic.value = !mutedMusic.value;

  void musicPlay(){
    if (mutedMusic.value) return;
    // audioTracks.play();
  }

  void musicStop(){
    // audioTracks.stop();
  }

  @override
  Future onComponentInit(sharedPreferences) async {
    print('isometricAudio.onComponentInit()');
    final completer = Completer();
    var total = 0;
    var totalLoaded = 0;

    final timeStarted = DateTime.now();
    for (final audioLoop in audioLoops){
      audioLoop.load();
    }
    for (final audioSingle in audioSingles){
      total++;
      audioSingle.load().then((value) {
        totalLoaded++;
        if (totalLoaded >= total){
          completer.complete(true);
          // final ms = DateTime.now().difference(timeStarted).inMilliseconds;
          // print('audio took $ms: milliseconds to load');
        }
      });
    }
    // return completer.future;
  }

  AudioSingle? getCharacterTypeAudioHurt(int characterType) =>
      switch (characterType) {
        CharacterType.Fallen => randomBool() ? zombie_hurt_1 : zombie_hurt_4,
        CharacterType.Gargoyle_01 => growl10,
        CharacterType.Wolf => dog_woolf_howl_4,
        _ => null
      };

  AudioSingle? getCharacterTypeAudioDeath(int characterType) =>
      switch (characterType) {
        CharacterType.Fallen => randomItem(audio.zombie_deaths),
        CharacterType.Gargoyle_01 => growl10,
        CharacterType.Wolf => dog_woolf_howl_4,
        _ => null
      };

  double getVolumeMusic() => mutedMusic.value ? 0 : 1;
}