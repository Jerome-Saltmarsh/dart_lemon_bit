
import 'dart:math';

import 'package:gamestream_flutter/isometric/functions/get_render.dart';
import 'package:just_audio/just_audio.dart';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_math/src.dart';
import '../../audio/audio_loop.dart';
import '../../audio/audio_single.dart';
import '../../audio/audio_tracks.dart';
import 'package:lemon_watch/src.dart';

class IsometricAudio with IsometricComponent implements Updatable {

  late final mutedMusic = Watch(false, onChanged: (bool muted){
    print('music muted: $muted');
    if (muted) {
      audioTracks.audioPlayer.pause();
    } else {
      audioTracks.play();
    }
  });

  late final enabledSound = Watch(false, onChanged: (bool soundEnabled){
    print('sound enabled: $soundEnabled');
    if (!soundEnabled){
      for (final audioSource in audioLoops) {
        audioSource.setVolume(0);
        audioSource.audioPlayer.pause();
      }
    } else {
      for (final audioSource in audioLoops) {
        audioSource.audioPlayer.play();
      }
    }
  });

  var nextCharacterNoise = 100;
  var nextRandomSound = 0;
  var nextRandomMusic = 0;

  final audioTracks = AudioTracks(
     tracks: [
       AudioSource.uri(Uri.parse('assets/audio/music/gamestream-track-01.mp3')),
       AudioSource.uri(Uri.parse('assets/audio/music/gamestream-track-02.mp3')),
       AudioSource.uri(Uri.parse('assets/audio/music/gamestream-track-03.mp3')),
     ]
  );

  final musicNight = [
    AudioSingle(name: 'creepy-whistle'),
    AudioSingle(name: 'creepy-wind'),
    AudioSingle(name: 'spooky-tribal'),
  ];

  final soundsNight = [
    AudioSingle(name: 'owl-1'),
    AudioSingle(name: 'creepy-5'),
  ];

  final soundsDay = [
    AudioSingle(name: 'wind-chime'),
  ];

  final soundsLateAfternoon = [
    AudioSingle(name: 'gong'),
  ];

  late final audioLoops = <AudioLoop> [
    AudioLoop(name: 'wind', getTargetVolume: environment.getVolumeTargetWind),
    AudioLoop(name: 'rain', getTargetVolume: getVolumeTargetRain),
    AudioLoop(name: 'crickets', getTargetVolume: getVolumeTargetCrickets),
    AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
    AudioLoop(name: 'distant-thunder', getTargetVolume: getVolumeTargetDistanceThunder),
    AudioLoop(name: 'heart-beat', getTargetVolume: getVolumeHeartBeat),
  ];


  final voiceYourTeamHasTheEnemyFlag = AudioSingle(name: 'voices/voice_your_team_has_the_enemy_flag');
  final voiceYourTeamHasYourFlag = AudioSingle(name: 'voices/voice_your_team_has_your_flag');
  final voiceTheEnemyFlagHasBeenDropped = AudioSingle(name: 'voices/voice_the_enemy_flag_has_been_dropped');
  final voiceTheEnemyHasScored = AudioSingle(name: 'voices/voice_the_enemy_has_scored');
  final voiceTheEnemyHasTheirFlag = AudioSingle(name: 'voices/voice_the_enemy_has_their_flag');
  final voiceTheEnemyHasYourFlag = AudioSingle(name: 'voices/voice_the_enemy_has_your_flag');
  final voiceYourFlagHasBeenDropped = AudioSingle(name: 'voices/voice_your_flag_has_been_dropped');
  final voiceYourFlagIsAtYourBase = AudioSingle(name: 'voices/voice_your_flag_is_at_your_base');
  final voiceYourTeamHasScoredAPoint = AudioSingle(name: 'voices/voice_your_team_has_scored_a_point');
  final voiceTheEnemyFlagIsAtTheirBase = AudioSingle(name: 'voices/voice_the_enemy_flag_is_at_their_base');

  final unlock_2 = AudioSingle(name: 'sounds/unlock_2');
  final jump = AudioSingle(name: 'sounds/jump');
  final dog_woolf_howl_4 = AudioSingle(name: 'dog-woolf-howl-4');
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
  final grenade_bounce = AudioSingle(name: 'grenade-bounce');
  final arrow_flying_past_6 = AudioSingle(name: 'arrow-flying-past-6');
  final notification_sound_10 = AudioSingle(name: 'notification-sound-10');
  final notification_sound_12 = AudioSingle(name: 'notification-sound-12');
  final sci_fi_blaster_1 = AudioSingle(name: 'sci-fi-blaster-1');
  final sci_fi_blaster_8 = AudioSingle(name: 'sci-fi-blaster-8');
  final shotgun_shot = AudioSingle(name: 'shotgun-shot');
  final revolver_shot_3 = AudioSingle(name: 'revolver-shot-03');
  final revolver_shot_6 = AudioSingle(name: 'revolver-shot-06');
  final cock_shotgun_3 = AudioSingle(name: 'cock-shotgun-03');
  final cash_register_4 = AudioSingle(name: 'cash_register_4');
  final mag_in_03 = AudioSingle(name: 'mag-in-02');
  final sword_unsheathe = AudioSingle(name: 'sword-unsheathe');
  final gun_pickup_01 = AudioSingle(name: 'gun-pickup-01');
  final assault_rifle_shot = AudioSingle(name: 'assault-rifle-shot');
  final sniper_shot_4 = AudioSingle(name: 'sniper-shot-04');
  final assault_rifle_shot_13 = AudioSingle(name: 'assault_rifle_shot_13');
  final assault_rifle_shot_14 = AudioSingle(name: 'assault_rifle_shot_14');
  final assault_rifle_shot_17 = AudioSingle(name: 'assault_rifle_shot_17');
  final revolver_shot_2 = AudioSingle(name: 'revolver-shot-02');
  final revolver_reload_1 = AudioSingle(name: 'revolver-reload-01');
  final reload_6 = AudioSingle(name: 'reload_06');
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
  final pistol_shot_20 = AudioSingle(name: 'pistol-shot-20');
  final pistol_shot_07 = AudioSingle(name: 'pistol_shot_07');
  final grass_cut = AudioSingle(name: 'grass-cut');
  final switch_sounds_4 = AudioSingle(name: 'switch-sounds-4');
  final teleport = AudioSingle(name: 'teleport-1');
  final hover_over_button_sound_30 = AudioSingle(name: 'hover-over-button-sound-30');
  final hover_over_button_sound_43 = AudioSingle(name: 'hover-over-button-sound-43');
  final explosion_grenade_04 = AudioSingle(name: 'explosion_grenade_04');
  final machine_gun_shot_02 = AudioSingle(name: 'machine_gun_shot_02');

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

    if (_nextAudioSourceUpdate-- <= 0) {
      _nextAudioSourceUpdate = 5;
        for (final audioSource in audioLoops){
          audioSource.update();
        }
    }

    updateRandomAmbientSounds();
    updateRandomMusic();
    updateCharacterNoises();
  }

  double getVolumeTargetRain() {
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
    final hour = environment.hours.value;
    const max = 0.8;
    if (hour >= 5 && hour < 7) return max;
    if (hour >= 17 && hour < 19) return max;
    return 0;
  }

  double getVolumeTargetDistanceThunder(){
    if (environment.lightningOn) return 1.0;
    return 0;
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

  late final MapItemTypeAudioSinglesAttack = <int, AudioSingle> {
     WeaponType.Unarmed: swing_arm_11,
     WeaponType.Knife: dagger_woosh_9,
     WeaponType.Axe: dagger_woosh_9,
     WeaponType.Staff: dagger_woosh_9,
     WeaponType.Hammer: dagger_woosh_9,
     WeaponType.Pickaxe: dagger_woosh_9,
     WeaponType.Sword: dagger_woosh_9,
     WeaponType.Revolver: revolver_shot_3,
     WeaponType.Musket: assault_rifle_shot_14,
     WeaponType.Grenade: swing_sword,
  };

  late final MapItemTypeAudioSinglesAttackMelee = <int, AudioSingle> {
    WeaponType.Unarmed: swing_arm_11,
    WeaponType.Knife: dagger_woosh_9,
    WeaponType.Axe: dagger_woosh_9,
    WeaponType.Staff: dagger_woosh_9,
    WeaponType.Hammer: dagger_woosh_9,
    WeaponType.Pickaxe: dagger_woosh_9,
    WeaponType.Sword: dagger_woosh_9,
    WeaponType.Revolver: dagger_woosh_9,
    WeaponType.Musket: dagger_woosh_9,
    WeaponType.Grenade: dagger_woosh_9,
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

    final engine = this.engine;
    final screenCenterWorldX = engine.screenCenterWorldX;
    final screenCenterWorldY = engine.screenCenterWorldY;
    final screenCenterGridX = convertRenderToSceneX(screenCenterWorldX, screenCenterWorldY);
    final screenCenterGridY = convertRenderToSceneY(screenCenterWorldX, screenCenterWorldY);
    final distanceFromPlayer = getDistanceXYZ(x, y, z, screenCenterGridX, screenCenterGridY, player.z);;
    final distanceVolume = IsometricAudio.convertDistanceToVolume(
      distanceFromPlayer,
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

  void playAudioError(){
    errorSound15();
  }

  void toggleMutedSound() => enabledSound.value = !enabledSound.value;

  void toggleMutedMusic() => mutedMusic.value = !mutedMusic.value;

  void musicPlay(){
    if (mutedMusic.value) return;
    audioTracks.play();
  }

  void musicStop(){
    audioTracks.stop();
  }

}