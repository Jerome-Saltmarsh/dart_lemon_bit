
import 'package:gamestream_flutter/library.dart';

class GameIsometricActions {

  static const Zoom_Far = 1.0;
  static const Zoom_Very_Far = 0.75;
  static const Zoom_Default = Zoom_Close;
  static const Zoom_Spawn = Zoom_Very_Far;
  static const Zoom_Close = 1.5;

  void loadSelectedSceneName(){
    final sceneName = GameEditor.selectedSceneName.value;
    if (sceneName == null) throw Exception("loadSelectedSceneNameException: selected scene name is null");
    gamestream.network.sendClientRequestEditorLoadGame(sceneName);
    GameEditor.actionGameDialogClose();
  }

  void rainStart(){
    final nodes = gamestream.games.isometric.nodes;
    final rows = nodes.totalRows;
    final columns = nodes.totalColumns;
    final zs = nodes.totalZ - 1;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        for (var z = zs; z >= 0; z--) {
          final index = gamestream.games.isometric.clientState.getNodeIndexZRC(z, row, column);
          final type = nodes.nodeTypes[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || nodes.nodeOrientations[index] == NodeOrientation.Solid) {
              gamestream.games.isometric.clientState.setNodeType(z + 1, row, column, NodeType.Rain_Landing);
            }
            gamestream.games.isometric.clientState.setNodeType(z + 2, row, column, NodeType.Rain_Falling);
            break;
          }
          if (
              column == 0 ||
              row == 0 ||
              !nodes.gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
              !nodes.gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
          ){
            gamestream.games.isometric.clientState.setNodeType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }

  void rainStop() {
    final nodes = gamestream.games.isometric.nodes;
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
    ClientState.edit.value = false;
  }

  void actionSetModeEdit(){
    ClientState.edit.value = true;
  }

  void actionToggleEdit() {
    ClientState.edit.value = !ClientState.edit.value;
  }

  void messageBoxToggle(){
    GameUI.messageBoxVisible.value = !GameUI.messageBoxVisible.value;
  }

  void messageBoxShow(){
    GameUI.messageBoxVisible.value = true;
  }

  void messageBoxHide(){
    GameUI.messageBoxVisible.value = false;
  }

  void toggleDebugMode(){
    ClientState.debugMode.value = !ClientState.debugMode.value;;
  }

  void setTarget() {
    gamestream.io.touchscreenCursorAction = CursorAction.Set_Target;
  }

  void attackAuto() {
    gamestream.io.touchscreenCursorAction = CursorAction.Stationary_Attack_Auto;
  }

  void playerStop() {
    gamestream.io.recenterCursor();
    setTarget();
  }

  void toggleZoom(){
    gamestream.audio.weaponSwap2();
    if (engine.targetZoom != Zoom_Far){
      engine.targetZoom = Zoom_Far;
    } else {
      engine.targetZoom = Zoom_Close;
    }
  }

  void toggleWindowSettings(){
      ClientState.window_visible_light_settings.toggle();
  }

  void createExplosion(double x, double y, double z){
    gamestream.games.isometric.clientState.spawnParticleLightEmissionAmbient(x: x, y: y, z: z);
    gamestream.audio.explosion_grenade_04.playXYZ(x, y, z);

    for (var i = 0; i <= 8; i++){
      final angle = piQuarter * i;
      final speed = randomBetween(0.5, 3.5);

      gamestream.games.isometric.clientState.spawnParticleFire(
          x: x,
          y: y,
          z: z,
      )
      ..xv = adj(angle, speed)
      ..yv = opp(angle, speed)
      ;
    }

    gamestream.games.isometric.clientState.spawnParticleFire(x: x, y: y, z: z)..delay = 0;
    gamestream.games.isometric.clientState.spawnParticleFire(x: x, y: y, z: z)..delay = 2;
    gamestream.games.isometric.clientState.spawnParticleFire(x: x, y: y, z: z)..delay = 4;
    gamestream.games.isometric.clientState.spawnParticleFire(x: x, y: y, z: z)..delay = 6;

    for (var i = 0; i < 7; i++) {
      gamestream.games.isometric.clientState.spawnParticle(
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
      gamestream.games.isometric.clientState.spawnParticleSmoke(
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

  void selectAttributeHealth() =>
      gamestream.network.sendClientRequest(
          ClientRequest.Select_Attribute,
          CharacterAttribute.Health,
      );

  void selectAttributeDamage() =>
      gamestream.network.sendClientRequest(
        ClientRequest.Select_Attribute,
        CharacterAttribute.Damage,
      );

  void selectAttributeMagic() =>
      gamestream.network.sendClientRequest(
        ClientRequest.Select_Attribute,
        CharacterAttribute.Magic,
      );
}

