
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/audio/audio_loop.dart';
import 'package:gamestream_flutter/isometric/audio/audio_loops.dart';
import 'package:gamestream_flutter/isometric/audio/audio_single.dart';

class GameAudio {

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

  static final audioSingleThunder = AudioSingle(name: 'thunder', volume: 0.5, maxDistance: 100);
  static final audioSingleFireball = AudioSingle(name: 'fire-bolt-14', volume: 0.5, maxDistance: 200);
  static final audioSingleFootstepGrass8 = AudioSingle(name: 'footstep-grass-8', volume: 0.05, maxDistance: 200);
  static final audioSingleFootstepGrass7 = AudioSingle(name: 'footstep-grass-7', volume: 0.05, maxDistance: 200);
  static final audioSingleFootstepMud6 = AudioSingle(name: 'mud-footstep-6', volume: 0.05, maxDistance: 200);
  static final audioSingleFootstepStone = AudioSingle(name: 'footstep-stone', volume: 0.05, maxDistance: 250);
  static final audioSingleFootstepWood = AudioSingle(name: 'footstep-wood-4', volume: 0.5, maxDistance: 250);
  static final audioSingleBowDraw = AudioSingle(name: 'bow-draw', volume: 0.5, maxDistance: 200);
  static final audioSingleNotificationSound10 = AudioSingle(name: 'notification-sound-10', volume: 0.5, maxDistance: 200);
  static final audioSingleNotificationSound12 = AudioSingle(name: 'notification-sound-12', volume: 0.5, maxDistance: 200);
  static final audioSingleBowRelease = AudioSingle(name: 'bow-release', volume: 0.5, maxDistance: 250);
  static final audioSingleArrowFlying = AudioSingle(name: 'arrow-flying-past-6', volume: 0.5, maxDistance: 250);
  static final audioSingleSciFiBlaster = AudioSingle(name: 'sci-fi-blaster-1', volume: 0.5, maxDistance: 400);
  static final audioSingleSciFiBlaster8 = AudioSingle(name: 'sci-fi-blaster-8', volume: 0.5, maxDistance: 400);
  static final audioSingleShotgunShot = AudioSingle(name: 'shotgun-shot', volume: 0.5, maxDistance: 400);
  static final audioSingleShotgunCock = AudioSingle(name: 'cock-shotgun-03', volume: 0.5, maxDistance: 400);
  static final audioSingleMagIn2 = AudioSingle(name: 'mag-in-02', volume: 0.5, maxDistance: 400);
  static final audioSingleSwordUnsheathe = AudioSingle(name: 'sword-unsheathe', volume: 0.5, maxDistance: 400);
  static final audioSingleGunPickup = AudioSingle(name: 'gun-pickup-01', volume: 0.5, maxDistance: 400);
  static final audioSingleAssaultRifle = AudioSingle(name: 'assault-rifle-shot', volume: 0.5, maxDistance: 400);
  static final audioSingleSniperRifleFired = AudioSingle(name: 'sniper-shot-04', volume: 0.5, maxDistance: 400);
  static final audioSingleRevolverFired = AudioSingle(name: 'revolver-shot-02', volume: 0.5, maxDistance: 400);
  static final audioSingleRevolverReload = AudioSingle(name: 'revolver-reload-01', volume: 0.5, maxDistance: 400);
  static final audioSingleReload6 = AudioSingle(name: 'reload_06', volume: 0.5, maxDistance: 400);
  static final audioSingleItemUnlock = AudioSingle(name: 'unlock', volume: 0.5, maxDistance: 400);
  static final audioSingleZombieHurt = AudioSingle(name: 'zombie-hurt-1', volume: 0.5, maxDistance: 400);
  static final audioSingleZombieHit4 = AudioSingle(name: 'zombie-hit-04', volume: 0.5, maxDistance: 400);
  static final audioSingleSplash = AudioSingle(name: 'splash', volume: 0.5, maxDistance: 400);
  static final audioSingleMaterialStruckWood = AudioSingle(name: 'material-struck-wood', volume: 0.5, maxDistance: 400);
  static final audioSingleMaterialStruckStone = AudioSingle(name: 'material-struck-stone', volume: 0.5, maxDistance: 400);
  static final audioSingleRatSqueak = AudioSingle(name: 'rat-squeak', volume: 0.5, maxDistance: 400);
  static final audioSingleCollectStar3 = AudioSingle(name: 'collect-star-3', volume: 0.5, maxDistance: 400);
  static final audioSingleMagicalImpact28 = AudioSingle(name: 'magical-impact-28', volume: 0.5, maxDistance: 400);
  static final audioSingleBloodyPunches1 = AudioSingle(name: 'bloody-punches-1', volume: 1.0, maxDistance: 400);
  static final audioSingleBloodyPunches3 = AudioSingle(name: 'bloody-punches-3', volume: 1.0, maxDistance: 400);
  static final audioSingleBloodyPunches = [audioSingleBloodyPunches1, audioSingleBloodyPunches3];
  static final audioSingleCrateBreaking = AudioSingle(name: 'crate-breaking', volume: 0.5, maxDistance: 400);
  static final audioSingleZombieDeaths = [
    AudioSingle(name: 'zombie-death-02', volume: 1, maxDistance: 400),
    AudioSingle(name: 'zombie-death-09', volume: 1, maxDistance: 400),
    AudioSingle(name: 'zombie-death-15', volume: 1, maxDistance: 400),
  ];

  static final audioSingleMaleHello = AudioSingle(name: 'male-hello-1', volume: 0.5, maxDistance: 400);
  static final audioSingleRooster = AudioSingle(name: 'rooster', volume: 0.5, maxDistance: 400);
  static final audioSingleChanging = AudioSingle(name: 'change-cloths', volume: 0.5, maxDistance: 80);
  static final audioSingleDrawSword = AudioSingle(name: 'draw-sword', volume: 0.5, maxDistance: 250);
  static final audioSingleClickSound = AudioSingle(name: 'click-sound-8', volume: 0.5, maxDistance: 250);
  static final audioSingleSwingArm = AudioSingle(name: 'swing-arm-11', volume: 0.4, maxDistance: 250);
  static final audioSingleSwingSword = AudioSingle(name: 'swing-sword', volume: 0.4, maxDistance: 250);
  static final audioSingleArmSwing = AudioSingle(name: 'arm-swing-whoosh-11', volume: 0.4, maxDistance: 250);
  static final audioSingleHeavyPunch13 = AudioSingle(name: 'heavy-punch-13', volume: 1, maxDistance: 250);
  static final audioSinglePistolShot20 = AudioSingle(name: 'pistol-shot-20', volume: 0.4, maxDistance: 250);
  static final audioSingleGrassCut = AudioSingle(name: 'grass-cut', volume: 0.4, maxDistance: 250);
  static final audioSingleSwitchSounds4 = AudioSingle(name: 'switch-sounds-4', volume: 0.4, maxDistance: 250);
  static final audioSingleZombieBits = [
    AudioSingle(name: 'zombie-bite-04', volume: 0.4, maxDistance: 250),
    AudioSingle(name: 'zombie-bite-05', volume: 0.4, maxDistance: 250),
  ];
  static final audioSingleZombieTalking = [
    AudioSingle(name: 'zombie-talking-03', volume: 0.4, maxDistance: 350),
    AudioSingle(name: 'zombie-talking-04', volume: 0.4, maxDistance: 350),
    AudioSingle(name: 'zombie-talking-05', volume: 0.4, maxDistance: 350),
  ];

  static final audioSingleTeleport = AudioSingle(name: 'teleport-1', volume: 0.5, maxDistance: 250);
  static final audioSingleHoverOverButton30 = AudioSingle(name: 'hover-over-button-sound-30', volume: 0.5, maxDistance: 250);
  static final audioSingleHoverOverButton43 = AudioSingle(name: 'hover-over-button-sound-43', volume: 0.5, maxDistance: 250);


  static double getVolumeTargetDayAmbience() {
    if (Game.ambientShade.value == Shade.Very_Bright) return 0.2;
    return 0;
  }

  static void updateAudioLoops(){
    for (final audioSource in audioLoops){
      audioSource.update();
    }
  }
}