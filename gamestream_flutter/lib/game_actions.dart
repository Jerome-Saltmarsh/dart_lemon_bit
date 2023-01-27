
import 'package:gamestream_flutter/library.dart';

class GameActions {

  static void loadSelectedSceneName(){
    final sceneName = GameEditor.selectedSceneName.value;
    if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
    GameNetwork.sendClientRequestEditorLoadGame(sceneName);
    GameEditor.actionGameDialogClose();
  }

  static void rainStart(){
    final rows = GameNodes.totalRows;
    final columns = GameNodes.totalColumns;
    final zs = GameNodes.totalZ - 1;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        for (var z = zs; z >= 0; z--) {
          final index = GameState.getNodeIndexZRC(z, row, column);
          final type = GameNodes.nodeTypes[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || GameNodes.nodeOrientations[index] == NodeOrientation.Solid) {
              GameState.setNodeType(z + 1, row, column, NodeType.Rain_Landing);
            }
            GameState.setNodeType(z + 2, row, column, NodeType.Rain_Falling);
            break;
          }
          if (
              column == 0 ||
              row == 0 ||
              !GameQueries.gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
              !GameQueries.gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
          ){
            GameState.setNodeType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }

  static void rainStop() {
    for (var i = 0; i < GameNodes.total; i++) {
      if (!NodeType.isRain(GameNodes.nodeTypes[i])) continue;
      GameNodes.nodeTypes[i] = NodeType.Empty;
      GameNodes.nodeOrientations[i] = NodeOrientation.None;
    }
  }

  ///
  static void rainFixBug(){

  }

  static void actionSetModePlay(){
    ClientState.edit.value = false;
  }

  static void actionSetModeEdit(){
    ClientState.edit.value = true;
  }

  static void actionToggleEdit() {
    ClientState.edit.value = !ClientState.edit.value;
  }

  static void messageBoxToggle(){
    GameUI.messageBoxVisible.value = !GameUI.messageBoxVisible.value;
  }

  static void messageBoxShow(){
    GameUI.messageBoxVisible.value = true;
  }

  static void messageBoxHide(){
    GameUI.messageBoxVisible.value = false;
  }

  static void toggleDebugMode(){
    ClientState.debugVisible.value = !ClientState.debugVisible.value;;
  }

  static void setTarget() {
    GameIO.touchscreenCursorAction = CursorAction.Set_Target;
  }

  static void attackAuto() {
    GameIO.touchscreenCursorAction = CursorAction.Stationary_Attack_Auto;
  }

  static void playerStop() {
    GameIO.recenterCursor();
    setTarget();
  }

  static void toggleZoom(){
    GameAudio.weaponSwap2();
    if (Engine.targetZoom != GameConfig.Zoom_Far){
      Engine.targetZoom = GameConfig.Zoom_Far;
    } else {
      Engine.targetZoom = GameConfig.Zoom_Close;
    }
  }

  static void createExplosion(double x, double y, double z){
    print('createExplosion()');
    GameState.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
    GameAudio.explosion_grenade_04.playXYZ(x, y, z);
    const flameSpeed = 1.0;
    GameState.spawnParticleFire(x: x, y: y, z: z)
      ..delay = 0
      ..xv = flameSpeed
      ..yv = flameSpeed;
    GameState.spawnParticleFire(x: x, y: y, z: z)
      ..delay = 0
      ..xv = -flameSpeed
      ..yv = flameSpeed;
    GameState.spawnParticleFire(x: x, y: y, z: z)
      ..delay = 0
      ..xv = flameSpeed
      ..yv = -flameSpeed;
    GameState.spawnParticleFire(x: x, y: y, z: z)
      ..delay = 0
      ..xv = -flameSpeed
      ..yv = -flameSpeed;
    GameState.spawnParticleFire(x: x, y: y, z: z)..delay = 0;
    GameState.spawnParticleFire(x: x, y: y, z: z)..delay = 2;
    GameState.spawnParticleFire(x: x, y: y, z: z)..delay = 4;
    GameState.spawnParticleFire(x: x, y: y, z: z)..delay = 6;

    for (var i = 0; i < 5; i++) {
      GameState.spawnParticle(
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

    for (var i = 0; i < 6; i++) {
      const r = 5.0;
      GameState.spawnParticleSmoke(
          x: x + giveOrTake(r),
          y: y + giveOrTake(r),
          z: z+ giveOrTake(r),
      )
        ..delay = i
        ..zv = 1.0
        ..setSpeed(randomAngle(), giveOrTake(3));
    }
  }
}

