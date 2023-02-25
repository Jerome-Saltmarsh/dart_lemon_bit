
import 'package:gamestream_flutter/classes/audio_single.dart';
import 'package:gamestream_flutter/lemon_cache/cache.dart';

import 'library.dart';


class GameAudio {

  static void toggleMuted() => muted.value = !muted.value;

  static final muted = Cache(key: 'game-audio-muted', value: false, onChanged: (bool value){
    print("GameAudio.mutedChanged($value)");
    if (value){
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

  static var nextCharacterNoise = 100;
  static var nextRandomSound = 0;
  static var nextRandomMusic = 0;

  static final musicNight = [
    AudioSingle(name: 'creepy-whistle', volume: 0.1),
    AudioSingle(name: 'creepy-wind', volume: 0.1),
    AudioSingle(name: 'spooky-tribal', volume: 1.0),
  ];

  static final soundsNight = [
    AudioSingle(name: 'owl-1', volume: 0.15),
    // wolf_howl,
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
    AudioLoop(name: 'day-ambience', getTargetVolume: getVolumeTargetDayAmbience),
    AudioLoop(name: 'distant-thunder', getTargetVolume: getVolumeTargetDistanceThunder),
    AudioLoop(name: 'heart-beat', getTargetVolume: getVolumeHeartBeat),
  ];

  static final dog_woolf_howl_4 = AudioSingle(name: 'dog-woolf-howl-4', volume: 0.5);
  static final wolf_howl = AudioSingle(name: 'wolf-howl', volume: 0.5);
  static final weaponSwap2 = AudioSingle(name: 'weapon-swap-2', volume: 0.5);
  static final eat = AudioSingle(name: 'eat', volume: 0.5);
  static final buff_1 = AudioSingle(name: 'buff-1', volume: 0.5);
  static final errorSound15 = AudioSingle(name: 'error-sound-15', volume: 0.5);
  static final popSounds14 = AudioSingle(name: 'pop-sounds-14', volume: 0.5);
  static final coins = AudioSingle(name: 'coins', volume: 0.5);
  static final coins_24 = AudioSingle(name: 'coins-24', volume: 0.5);
  static final hoverOverButtonSound5 = AudioSingle(name: 'hover-over-button-sound-5', volume: 0.5);
  static final thunder = AudioSingle(name: 'thunder', volume: 0.5);
  static final fire_bolt_14 = AudioSingle(name: 'fire-bolt-14', volume: 0.5);
  static final dagger_woosh_9 = AudioSingle(name: 'dagger_woosh_9', volume: 0.5);
  static final metal_light_3 = AudioSingle(name: 'metal-light-3', volume: 0.5);
  static final metal_struck = AudioSingle(name: 'metal-struck', volume: 0.5);
  static final footstep_grass_8 = AudioSingle(name: 'footstep-grass-8', volume: 0.05);
  static final footstep_grass_7 = AudioSingle(name: 'footstep-grass-7', volume: 0.05);
  static final footstep_mud_6 = AudioSingle(name: 'mud-footstep-6', volume: 0.05);
  static final footstep_stone = AudioSingle(name: 'footstep-stone', volume: 0.05);
  static final footstep_wood_4 = AudioSingle(name: 'footstep-wood-4', volume: 0.5);
  static final bow_draw = AudioSingle(name: 'bow-draw', volume: 0.5);
  static final bow_release = AudioSingle(name: 'bow-release', volume: 0.5);
  static final arrow_impact = AudioSingle(name: 'arrow-impact', volume: 0.5);
  static final grenade_bounce = AudioSingle(name: 'grenade-bounce', volume: 0.5);
  static final arrow_flying_past_6 = AudioSingle(name: 'arrow-flying-past-6', volume: 0.5);
  static final notification_sound_10 = AudioSingle(name: 'notification-sound-10', volume: 0.5);
  static final notification_sound_12 = AudioSingle(name: 'notification-sound-12', volume: 0.5);
  static final sci_fi_blaster_1 = AudioSingle(name: 'sci-fi-blaster-1', volume: 0.5);
  static final sci_fi_blaster_8 = AudioSingle(name: 'sci-fi-blaster-8', volume: 0.5);
  static final shotgun_shot = AudioSingle(name: 'shotgun-shot', volume: 0.5);
  static final revolver_shot_3 = AudioSingle(name: 'revolver-shot-03', volume: 0.5);
  static final revolver_shot_6 = AudioSingle(name: 'revolver-shot-06', volume: 0.5);
  static final cock_shotgun_3 = AudioSingle(name: 'cock-shotgun-03', volume: 0.5);
  static final cash_register_4 = AudioSingle(name: 'cash_register_4', volume: 0.5);
  static final mag_in_03 = AudioSingle(name: 'mag-in-02', volume: 0.5);
  static final sword_unsheathe = AudioSingle(name: 'sword-unsheathe', volume: 0.5);
  static final gun_pickup_01 = AudioSingle(name: 'gun-pickup-01', volume: 0.5);
  static final assault_rifle_shot = AudioSingle(name: 'assault-rifle-shot', volume: 0.5);
  static final sniper_shot_4 = AudioSingle(name: 'sniper-shot-04', volume: 0.5);
  static final assault_rifle_shot_13 = AudioSingle(name: 'assault_rifle_shot_13', volume: 0.5);
  static final assault_rifle_shot_14 = AudioSingle(name: 'assault_rifle_shot_14', volume: 0.5);
  static final assault_rifle_shot_17 = AudioSingle(name: 'assault_rifle_shot_17', volume: 0.5);
  static final revolver_shot_2 = AudioSingle(name: 'revolver-shot-02', volume: 0.5);
  static final revolver_reload_1 = AudioSingle(name: 'revolver-reload-01', volume: 0.5);
  static final reload_6 = AudioSingle(name: 'reload_06', volume: 0.5);
  static final unlock = AudioSingle(name: 'unlock', volume: 0.5);
  static final zombie_hurt_1 = AudioSingle(name: 'zombie-hurt-1', volume: 0.5);
  static final zombie_hurt_4 = AudioSingle(name: 'zombie-hit-04', volume: 0.5);
  static final splash = AudioSingle(name: 'splash', volume: 0.5);
  static final material_struck_wood = AudioSingle(name: 'material-struck-wood', volume: 0.5);
  static final material_struck_stone = AudioSingle(name: 'material-struck-stone', volume: 0.5);
  static final material_struck_dirt = AudioSingle(name: 'material-struck-dirt', volume: 0.5);
  static final rat_squeak = AudioSingle(name: 'rat-squeak', volume: 0.5);
  static final collect_star_3 = AudioSingle(name: 'collect-star-3', volume: 0.5);
  static final magical_impact_16 = AudioSingle(name: 'magical-impact-16', volume: 0.5);
  static final magical_impact_28 = AudioSingle(name: 'magical-impact-28', volume: 0.5);
  static final bloody_punches_1 = AudioSingle(name: 'bloody-punches-1', volume: 1.0);
  static final bloody_punches_3 = AudioSingle(name: 'bloody-punches-3', volume: 1.0);
  static final crate_breaking = AudioSingle(name: 'crate-breaking', volume: 0.5);
  static final male_hello = AudioSingle(name: 'male-hello-1', volume: 0.5);
  static final rooster = AudioSingle(name: 'rooster', volume: 0.5);
  static final change_cloths = AudioSingle(name: 'change-cloths', volume: 0.5);
  static final draw_sword = AudioSingle(name: 'draw-sword', volume: 0.5);
  static final click_sound_8 = AudioSingle(name: 'click-sound-8', volume: 0.5);
  static final swing_arm_11 = AudioSingle(name: 'swing-arm-11', volume: 0.4);
  static final swing_sword = AudioSingle(name: 'swing-sword', volume: 0.4);
  static final arm_swing_whoosh_11 = AudioSingle(name: 'arm-swing-whoosh-11', volume: 0.4);
  static final heavy_punch_13 = AudioSingle(name: 'heavy-punch-13', volume: 1);
  static final pistol_shot_20 = AudioSingle(name: 'pistol-shot-20', volume: 0.4);
  static final pistol_shot_07 = AudioSingle(name: 'pistol_shot_07', volume: 0.4);
  static final grass_cut = AudioSingle(name: 'grass-cut', volume: 0.4);
  static final switch_sounds_4 = AudioSingle(name: 'switch-sounds-4', volume: 0.4);
  static final teleport = AudioSingle(name: 'teleport-1', volume: 0.5);
  static final hover_over_button_sound_30 = AudioSingle(name: 'hover-over-button-sound-30', volume: 0.5);
  static final hover_over_button_sound_43 = AudioSingle(name: 'hover-over-button-sound-43', volume: 0.5);
  static final explosion_grenade_04 = AudioSingle(name: 'explosion_grenade_04', volume: 0.5);
  static final machine_gun_shot_02 = AudioSingle(name: 'machine_gun_shot_02', volume: 0.5);

  static final zombie_deaths = [
    AudioSingle(name: 'zombie-death-02', volume: 1),
    AudioSingle(name: 'zombie-death-09', volume: 1),
    AudioSingle(name: 'zombie-death-15', volume: 1),
  ];
  static final bloody_punches = [bloody_punches_1, bloody_punches_3];
  static final audioSingleZombieBits = [
    AudioSingle(name: 'zombie-bite-04', volume: 0.4),
    AudioSingle(name: 'zombie-bite-05', volume: 0.4),
  ];
  static final audioSingleZombieTalking = [
    AudioSingle(name: 'zombie-talking-03', volume: 0.4),
    AudioSingle(name: 'zombie-talking-04', volume: 0.4),
    AudioSingle(name: 'zombie-talking-05', volume: 0.4),
  ];

  static double getVolumeTargetDayAmbience() {
    final hours = ServerState.hours.value;
    if (hours > 8 && hours < 4) return 0.2;
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
    if (GameAudio.muted.value) {
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

  static double getVolumeTargetWind() {
    final windLineDistance = (Engine.screenCenterRenderX - GameQueries.windLineRenderX).abs();
    final windLineDistanceVolume = convertDistanceToVolume(windLineDistance, maxDistance: 300);
    var target = 0.0;
    if (GameQueries.windLineRenderX - 250 <= Engine.screenCenterRenderX) {
      target += windLineDistanceVolume;
    }
    final index = ServerState.windTypeAmbient.value;
    if (index <= WindType.Calm) {
      if (ServerState.hours.value < 6) return target;
      if (ServerState.hours.value < 18) return target + 0.1;
      return target;
    }
    if (index <= WindType.Gentle) return target + 0.5;
    return 1.0;
  }

  static double getVolumeTargetRain() {
    switch (ServerState.rainType.value){
      case RainType.None:
        return 0;
      case RainType.Light:
        return 0.5;
      case RainType.Heavy:
        return 1;
      default:
        throw Exception('GameAudio.getVolumeTargetRain()');
    }
  }

  static double getVolumeTargetCrickets() {
    final hour = ServerState.hours.value;
    const max = 0.8;
    if (hour >= 5 && hour < 7) return max;
    if (hour >= 17 && hour < 19) return max;
    return 0;
  }

  static double getVolumeTargetFire(){
    // if (!ClientState.torchesIgnited.value) return 0;
    const r = 4;
    const maxDistance = r * Node_Size;
    var closest = GameQueries.getClosestByType(radius: r, type: NodeType.Fireplace) * Node_Size;
    final closestTorch = GameQueries.getClosestByType(
        radius: r,
        type: NodeType.Torch
    ) * Node_Size;
    if (closestTorch < closest) {
      closest = closestTorch;
    }
    return convertDistanceToVolume(closest, maxDistance: maxDistance);
  }

  static double getVolumeTargetDistanceThunder(){
    if (GameState.lightningOn) return 1.0;
    return 0;
  }

  static double getVolumeHeartBeat(){
    if (ServerState.playerMaxHealth.value <= 0) return 0.0;
    return 1.0 - ServerState.playerHealth.value / ServerState.playerMaxHealth.value;
  }

  static double getVolumeStream(){
    const r = 5;
    const maxDistance = r * Node_Size;
    final distance = GameQueries.getClosestByType(radius: r, type: NodeType.Water) * Node_Size;
    return convertDistanceToVolume(distance, maxDistance: maxDistance * 0.25);
  }

  static void playAudioSingle(AudioSingle audioSingle, double x, double y, double z, {double maxDistance = 400}){
    // TODO calculate from screen center instead
    final distanceFromPlayer = GamePlayer.position.distance3(x, y, z);
    final distanceVolume = convertDistanceToVolume(
      distanceFromPlayer,
      maxDistance: maxDistance,
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
    final hours = ServerState.hours.value;
    if (hours > 22 && hours < 3) {
      playRandom(musicNight);
    }
  }

  static void playRandomAmbientSound(){
    final hour = ServerState.hours.value;

    if (hour > 22 && hour < 4){
      return playRandom(soundsNight);
    }
    if (hour == 6){
      return GameAudio.rooster.play(volume: 0.3);
    }

    if (hour > 9 && hour < 15) {
      return playRandom(soundsDay);
    }
    // if (hour >= 15 && hour < 18) {
    //   playRandom(soundsLateAfternoon);
    //   return;
    // }
  }

  static void playRandom(List<AudioSingle> items){
    Engine.randomItem(items).play();
  }

  static void updateCharacterNoises(){
    if (ServerState.totalCharacters <= 0) return;
    if (nextCharacterNoise-- > 0) return;
    nextCharacterNoise = Engine.randomInt(200, 300);

    final index = randomInt(0, ServerState.totalCharacters);
    final character = ServerState.characters[index];

    switch (character.characterType) {
      case CharacterType.Zombie:
        Engine.randomItem(GameAudio.audioSingleZombieTalking).playV3(character, maxDistance: 500);
        break;
      case CharacterType.Dog:
        if (randomBool()){
          GameAudio.wolf_howl.playV3(character);
        } else {
          GameAudio.dog_woolf_howl_4.playV3(character);
        }
        break;
    }
  }

  static final MapItemTypeAudioSinglesAttack = <int, AudioSingle> {
     ItemType.Empty: swing_arm_11,
     ItemType.Weapon_Melee_Knife: dagger_woosh_9,
     ItemType.Weapon_Melee_Axe: dagger_woosh_9,
     ItemType.Weapon_Melee_Staff: dagger_woosh_9,
     ItemType.Weapon_Melee_Hammer: dagger_woosh_9,
     ItemType.Weapon_Melee_Pickaxe: dagger_woosh_9,
     ItemType.Weapon_Melee_Crowbar: dagger_woosh_9,
     ItemType.Weapon_Melee_Sword: dagger_woosh_9,
     ItemType.Weapon_Handgun_Flint_Lock_Old: revolver_shot_3,
     ItemType.Weapon_Handgun_Flint_Lock: revolver_shot_3,
     ItemType.Weapon_Handgun_Flint_Lock_Superior: revolver_shot_3,
     ItemType.Weapon_Ranged_Glock: pistol_shot_20,
     ItemType.Weapon_Ranged_Smg: pistol_shot_07,
     ItemType.Weapon_Handgun_Desert_Eagle: revolver_shot_6,
     ItemType.Weapon_Ranged_Revolver: revolver_shot_3,
     ItemType.Weapon_Rifle_Arquebus: assault_rifle_shot_13,
     ItemType.Weapon_Rifle_Blunderbuss: assault_rifle_shot_13,
     ItemType.Weapon_Rifle_Musket: assault_rifle_shot_14,
     ItemType.Weapon_Ranged_Rifle: assault_rifle_shot_14,
     ItemType.Weapon_Ranged_AK_47: assault_rifle_shot_14,
     ItemType.Weapon_Rifle_M4: assault_rifle_shot_17,
     ItemType.Weapon_Ranged_Sniper_Rifle: sniper_shot_4,
     ItemType.Weapon_Ranged_Shotgun: shotgun_shot,
     ItemType.Weapon_Ranged_Flamethrower: fire_bolt_14,
     ItemType.Weapon_Ranged_Bazooka: fire_bolt_14,
     ItemType.Weapon_Special_Minigun: machine_gun_shot_02,
     ItemType.Weapon_Thrown_Grenade: swing_sword,
  };

  static final MapItemTypeAudioSinglesAttackMelee = <int, AudioSingle> {
    ItemType.Empty: swing_arm_11,
    ItemType.Weapon_Melee_Knife: dagger_woosh_9,
    ItemType.Weapon_Melee_Axe: dagger_woosh_9,
    ItemType.Weapon_Melee_Staff: dagger_woosh_9,
    ItemType.Weapon_Melee_Hammer: dagger_woosh_9,
    ItemType.Weapon_Melee_Pickaxe: dagger_woosh_9,
    ItemType.Weapon_Melee_Crowbar: dagger_woosh_9,
    ItemType.Weapon_Melee_Sword: dagger_woosh_9,
    ItemType.Weapon_Handgun_Flint_Lock_Old: dagger_woosh_9,
    ItemType.Weapon_Handgun_Flint_Lock: dagger_woosh_9,
    ItemType.Weapon_Handgun_Flint_Lock_Superior: dagger_woosh_9,
    ItemType.Weapon_Ranged_Glock: dagger_woosh_9,
    ItemType.Weapon_Ranged_Smg: dagger_woosh_9,
    ItemType.Weapon_Handgun_Desert_Eagle: dagger_woosh_9,
    ItemType.Weapon_Ranged_Revolver: dagger_woosh_9,
    ItemType.Weapon_Rifle_Arquebus: dagger_woosh_9,
    ItemType.Weapon_Rifle_Blunderbuss: dagger_woosh_9,
    ItemType.Weapon_Rifle_Musket: dagger_woosh_9,
    ItemType.Weapon_Ranged_Rifle: dagger_woosh_9,
    ItemType.Weapon_Ranged_AK_47: dagger_woosh_9,
    ItemType.Weapon_Rifle_M4: dagger_woosh_9,
    ItemType.Weapon_Ranged_Sniper_Rifle: dagger_woosh_9,
    ItemType.Weapon_Ranged_Shotgun: dagger_woosh_9,
    ItemType.Weapon_Ranged_Flamethrower: dagger_woosh_9,
    ItemType.Weapon_Ranged_Bazooka: dagger_woosh_9,
    ItemType.Weapon_Special_Minigun: dagger_woosh_9,
    ItemType.Weapon_Thrown_Grenade: dagger_woosh_9,
  };
}