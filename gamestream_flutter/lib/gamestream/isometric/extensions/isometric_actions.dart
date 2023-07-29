
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';


extension IsometricActions on Isometric {
  static const Zoom_Far = 0.4;
  static const Zoom_Close = 1.3;
  
  void loadSelectedSceneName(){
    final sceneName = editor.selectedSceneName.value;
    if (sceneName == null) throw Exception('loadSelectedSceneNameException: selected scene name is null');
    editorLoadGame(sceneName);
    editor.actionGameDialogClose();
  }

  void actionSetModePlay(){
    edit.value = false;
  }

  void actionSetModeEdit(){
    edit.value = true;
  }

  void actionToggleEdit() {
    edit.value = !edit.value;
  }

  void messageBoxToggle(){
    messageBoxVisible.value = !messageBoxVisible.value;
  }

  void messageBoxShow(){
    messageBoxVisible.value = true;
  }

  void messageBoxHide(){
    messageBoxVisible.value = false;
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
    playAudioXYZ(audio.explosion_grenade_04, x, y, z);

    for (var i = 0; i <= 8; i++){
      final angle = piQuarter * i;
      final speed = randomBetween(0.5, 3.5);

      spawnParticleFire(
          x: x,
          y: y,
          z: z,
      )
      ..xv = adj(angle, speed)
      ..yv = opp(angle, speed)
      ;
    }

    spawnParticleFire(x: x, y: y, z: z)..delay = 0;
    spawnParticleFire(x: x, y: y, z: z)..delay = 2;
    spawnParticleFire(x: x, y: y, z: z)..delay = 4;
    spawnParticleFire(x: x, y: y, z: z)..delay = 6;

    for (var i = 0; i < 7; i++) {
      particles.spawnParticle(
        type: ParticleType.Fire,
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
        ..zv = 0.75
        ..setSpeed(randomAngle(), giveOrTake(3));
    }
  }

  void cameraTargetPlayer(){
    camera.target = player.position;
  }
}

