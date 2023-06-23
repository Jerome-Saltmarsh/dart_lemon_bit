
import 'package:gamestream_flutter/library.dart';

import '../ui/game_isometric_ui.dart';
import '../isometric.dart';

class IsometricActions {
  static const Zoom_Far = 1.0;
  static const Zoom_Very_Far = 0.75;
  static const Zoom_Default = Zoom_Close;
  static const Zoom_Spawn = Zoom_Very_Far;
  static const Zoom_Close = 1.5;
  
  final Isometric isometric;

  IsometricActions(this.isometric);

  void loadSelectedSceneName(){
    final sceneName = isometric.editor.selectedSceneName.value;
    if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
    gamestream.isometric.editorLoadGame(sceneName);
    isometric.editor.actionGameDialogClose();
  }

  void rainStart(){
    final nodes = isometric.nodes;
    final rows = nodes.totalRows;
    final columns = nodes.totalColumns;
    final zs = nodes.totalZ - 1;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        for (var z = zs; z >= 0; z--) {
          final index = nodes.getNodeIndexZRC(z, row, column);
          final type = nodes.nodeTypes[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || nodes.nodeOrientations[index] == NodeOrientation.Solid) {
              nodes.setNodeType(z + 1, row, column, NodeType.Rain_Landing);
            }
            nodes.setNodeType(z + 2, row, column, NodeType.Rain_Falling);
            break;
          }
          if (
              column == 0 ||
              row == 0 ||
              !nodes.gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
              !nodes.gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
          ){
            nodes.setNodeType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }

  void rainStop() {
    final nodes = isometric.nodes;
    for (var i = 0; i < nodes.total; i++) {
      if (!NodeType.isRain(nodes.nodeTypes[i])) continue;
      nodes.nodeTypes[i] = NodeType.Empty;
      nodes.nodeOrientations[i] = NodeOrientation.None;
    }
  }

  ///
  void rainFixBug(){

  }

  void actionSetModePlay(){
    isometric.clientState.edit.value = false;
  }

  void actionSetModeEdit(){
    isometric.clientState.edit.value = true;
  }

  void actionToggleEdit() {
    isometric.clientState.edit.value = !isometric.clientState.edit.value;
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
    isometric.clientState.debugMode.value = !isometric.clientState.debugMode.value;;
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
    isometric.particles.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
    gamestream.audio.explosion_grenade_04.playXYZ(x, y, z);

    for (var i = 0; i <= 8; i++){
      final angle = piQuarter * i;
      final speed = randomBetween(0.5, 3.5);

      isometric.particles.spawnParticleFire(
          x: x,
          y: y,
          z: z,
      )
      ..xv = adj(angle, speed)
      ..yv = opp(angle, speed)
      ;
    }

    isometric.particles.spawnParticleFire(x: x, y: y, z: z)..delay = 0;
    isometric.particles.spawnParticleFire(x: x, y: y, z: z)..delay = 2;
    isometric.particles.spawnParticleFire(x: x, y: y, z: z)..delay = 4;
    isometric.particles.spawnParticleFire(x: x, y: y, z: z)..delay = 6;

    for (var i = 0; i < 7; i++) {
      gamestream.isometric.particles.spawnParticle(
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
      gamestream.isometric.particles.spawnParticleSmoke(
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


}

