
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

import '../ui/game_isometric_ui.dart';

extension IsometricActions on Isometric {
  static const Zoom_Far = 1.0;
  static const Zoom_Very_Far = 0.75;
  static const Zoom_Default = Zoom_Close;
  static const Zoom_Spawn = Zoom_Very_Far;
  static const Zoom_Close = 1.5;
  
  void loadSelectedSceneName(){
    final sceneName = editor.selectedSceneName.value;
    if (sceneName == null) throw Exception('loadSelectedSceneNameException: selected scene name is null');
    editorLoadGame(sceneName);
    editor.actionGameDialogClose();
  }

  void rainStart(){
    final rows = scene.totalRows;
    final columns = scene.totalColumns;
    final zs = scene.totalZ - 1;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        for (var z = zs; z >= 0; z--) {
          final index = scene.getIndexZRC(z, row, column);
          final type = scene.nodeTypes[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || scene.nodeOrientations[index] == NodeOrientation.Solid) {
              scene.setNodeType(z + 1, row, column, NodeType.Rain_Landing);
            }
            scene.setNodeType(z + 2, row, column, NodeType.Rain_Falling);
            break;
          }
          if (
              column == 0 ||
              row == 0 ||
              !scene.gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
              !scene.gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
          ){
            scene.setNodeType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }

  void rainStop() {
    for (var i = 0; i < scene.total; i++) {
      if (!NodeType.isRain(scene.nodeTypes[i])) continue;
      scene.nodeTypes[i] = NodeType.Empty;
      scene.nodeOrientations[i] = NodeOrientation.None;
    }
  }

  ///
  void rainFixBug(){

  }

  void actionSetModePlay(){
    client.edit.value = false;
  }

  void actionSetModeEdit(){
    client.edit.value = true;
  }

  void actionToggleEdit() {
    client.edit.value = !client.edit.value;
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

  void toggleDebugMode(){
    client.debugMode.value = !client.debugMode.value;;
  }

  void toggleZoom(){
    gamestream.audio.weaponSwap2();
    if (engine.targetZoom != Zoom_Far){
      engine.targetZoom = Zoom_Far;
    } else {
      engine.targetZoom = Zoom_Close;
    }
  }

  void createExplosion(double x, double y, double z){
    particles.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
    gamestream.audio.explosion_grenade_04.playXYZ(x, y, z);

    for (var i = 0; i <= 8; i++){
      final angle = piQuarter * i;
      final speed = randomBetween(0.5, 3.5);

      particles.spawnParticleFire(
          x: x,
          y: y,
          z: z,
      )
      ..xv = adj(angle, speed)
      ..yv = opp(angle, speed)
      ;
    }

    particles.spawnParticleFire(x: x, y: y, z: z)..delay = 0;
    particles.spawnParticleFire(x: x, y: y, z: z)..delay = 2;
    particles.spawnParticleFire(x: x, y: y, z: z)..delay = 4;
    particles.spawnParticleFire(x: x, y: y, z: z)..delay = 6;

    for (var i = 0; i < 7; i++) {
      particles.spawnParticle(
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
      particles.spawnParticleSmoke(
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
    camera.followTarget.value = true;
  }
}

