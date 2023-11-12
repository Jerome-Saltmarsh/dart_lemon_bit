
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/packages/common/src.dart';
import 'package:lemon_math/src.dart';


class IsometricActions with IsometricComponent {
  static const Zoom_Far = 0.4;
  static const Zoom_Close = 1.3;
  
  void loadSelectedSceneName(){
    final sceneName = editor.selectedSceneName.value;
    if (sceneName == null) throw Exception('loadSelectedSceneNameException: selected scene name is null');
    network.sendIsometricRequestEditorLoadGame(sceneName);
    editor.actionGameDialogClose();
  }

  void toggleZoom(){
    audio.weaponSwap2();
    if (engine.targetZoom != Zoom_Far){
      engine.targetZoom = Zoom_Far;
    } else {
      engine.targetZoom = Zoom_Close;
    }
  }

  void createExplosion(double x, double y, double z){
    spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
    audio.play(audio.explosion_grenade_04, x, y, z);

    for (var i = 0; i <= 8; i++){
      final angle = piQuarter * i;
      final speed = randomBetween(0.5, 3.5);

      actions.spawnParticleFire(
          x: x,
          y: y,
          z: z,
      )
      ..vx = adj(angle, speed)
      ..vy = opp(angle, speed)
      ;
    }

    spawnParticleFire(x: x, y: y, z: z)..delay = 0;
    spawnParticleFire(x: x, y: y, z: z)..delay = 2;
    spawnParticleFire(x: x, y: y, z: z)..delay = 4;
    spawnParticleFire(x: x, y: y, z: z)..delay = 6;

    for (var i = 0; i < 7; i++) {
      particles.spawnParticle(
        particleType: ParticleType.Fire,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 4.5,
        zv: randomBetween(2, 3),
        duration: 15,
        scale: 0.5,
        scaleV: 0,
        rotation: 0,
        bounciness: 0,
        // frictionAir: 1.0,
      );
    }

    for (var i = 0; i < 7; i++) {
      const r = 5.0;
      particles.emitSmoke(
          x: x + giveOrTake(r),
          y: y + giveOrTake(r),
          z: z+ giveOrTake(r),
          duration: 60,
      )
        ..deactiveOnNodeCollision = false
        ..delay = i
        ..vz = 0.75
        ..setSpeed(randomAngle(), giveOrTake(3));
    }
  }

  void spawnParticleLightEmissionAmbient({
    required double x,
    required double y,
    required double z,
  }) =>
      particles.spawnParticle(
        particleType: ParticleType.Light_Emission,
        x: x,
        y: y,
        z: z,
        angle: 0,
        speed: 0,
        weight: 0,
        duration: 35,
        // frictionAir: 1.0,
      )
        ..flash = true
        ..emissionColor = scene.ambientColor
        ..emissionIntensity = 0.0
  ;

  Particle spawnParticleFire({
    required double x,
    required double y,
    required double z,
    int duration = 100,
    double scale = 1.0
  }) =>
      particles.spawnParticle(
        particleType: ParticleType.Fire,
        x: x,
        y: y,
        z: z,
        zv: 1,
        angle: 0,
        rotation: 0,
        speed: 0,
        scaleV: 0.01,
        weight: -1,
        duration: duration,
        scale: scale,
        // frictionAir: 1.0,
      )
        ..emitsLight = true
        ..emissionColor = scene.ambientColor
        ..deactiveOnNodeCollision = false
        ..emissionIntensity = 0.5
  ;

  void clean() {
    scene.colorStackIndex = -1;
    scene.ambientStackIndex = -1;
  }

  void clear() {
    player.position.x = 0;
    player.position.y = 0;
    player.position.z = 0;
    player.gameDialog.value = null;
    scene.totalProjectiles = 0;
    particles.activated.clear();
    engine.zoom = 1;
  }

  int get bodyPartDuration =>  randomInt(120, 200);

  // PROPERTIES

  void showMessage(String message){
    options.messageStatus.value = '';
    options.messageStatus.value = message;
  }

  void spawnConfettiPlayer() {
    for (var i = 0; i < 10; i++){
      particles.spawnParticleConfetti(
        player.position.x,
        player.position.y,
        player.position.z,
      );
    }
  }

  void playSoundWindow() =>
      audio.click_sound_8(1);

  void messageClear(){
    writeMessage('');
  }

  void writeMessage(String value){
    options.messageStatus.value = value;
  }

  void startGameByType(GameType gameType){
    options.game.value = options.mapGameTypeToGame(gameType);
  }

  void startGameType(GameType gameType){
    network.connectToGame(gameType);
  }

}

