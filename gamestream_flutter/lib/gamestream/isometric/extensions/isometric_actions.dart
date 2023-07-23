
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/game_isometric_ui.dart';

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
    GameIsometricUI.messageBoxVisible.value = !GameIsometricUI.messageBoxVisible.value;
  }

  void messageBoxShow(){
    GameIsometricUI.messageBoxVisible.value = true;
  }

  void messageBoxHide(){
    GameIsometricUI.messageBoxVisible.value = false;
  }

  void toggleZoom(){
    gamestream.audio.weaponSwap2();
    if (gamestream.engine.targetZoom != Zoom_Far){
      gamestream.engine.targetZoom = Zoom_Far;
    } else {
      gamestream.engine.targetZoom = Zoom_Close;
    }
  }

  void createExplosion(double x, double y, double z){
    spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
    gamestream.audio.explosion_grenade_04.playXYZ(x, y, z);

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
      spawnParticle(
        type: ParticleType.Fire,
        x: x,
        y: y,
        z: z,
        angle: randomAngle(),
        speed: 4.5,
        zv: randomBetween(2, 3),
        weight: 10,
        duration: 15,
        scale: 0.5,
        scaleV: 0,
        rotation: 0,
        bounciness: 0,
        checkCollision: false,
      );
    }

    for (var i = 0; i < 7; i++) {
      const r = 5.0;
      spawnParticleSmoke(
          x: x + giveOrTake(r),
          y: y + giveOrTake(r),
          z: z+ giveOrTake(r),
          duration: 60,
      )
        ..checkNodeCollision = false
        ..delay = i
        ..zv = 0.75
        ..setSpeed(randomAngle(), giveOrTake(3));
    }
  }

  void cameraTargetPlayer(){
    camera.target = player.position;
  }
}

