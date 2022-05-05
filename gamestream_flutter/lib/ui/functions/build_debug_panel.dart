import 'package:bleed_common/version.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/bytestream_parser.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/ui/functions/build_row_tech_type.dart';
import 'package:gamestream_flutter/ui/functions/build_time.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildDebugPanel(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildTime(),
      buildTotalZombies(),
      buildTotalPlayers(),
      mouseRowColumn(),
      buildVersion(),
      buildTotalParticles,
      buildActiveParticles,
      tileAtMouse,
      mousePositionWorld,
      mousePositionScreen,
      byteCountWatcher,
      bufferLengthWatcher,
      playerPosition,
      cameraZoom,
      buildFramesSinceUpdate(),
      playerScreen,
    ],
  );
}

Widget buildTotalZombies() {
  return WatchBuilder(game.totalZombies, (int value) {
    return text('Zombies: $value');
  });
}

Widget buildTotalPlayers() {
  return WatchBuilder(game.totalPlayers, (int value) {
    return text('Players: $value');
  });
}

Widget mouseRowColumn(){
  return Refresh((){
    return text("Mouse Row:$mouseRow, Column: $mouseColumn");
  });
}

Widget buildFramesSinceUpdate(){
  return WatchBuilder(framesSinceUpdateReceived, (int frames){
    return text("Frames Since Update: $frames");
  });
}

Widget buildVersion(){
  return text(version, color: colours.white618);
}


Widget get buildTotalParticles {
  return Refresh((){
    return text("Particles: ${isometric.particles.length}");
  });
}

Widget get playerScreen {
  return Refresh(() {
    return text("Player Screen: x: ${worldToScreenX(state.player.x)}, y: ${worldToScreenY(state.player.y)}");
  });
}

Widget get buildActiveParticles {
  return Refresh((){
    return text("Active Particles: ${isometric.totalActiveParticles}");
  });
}

Widget get tileAtMouse {
  return Refresh((){
    return text("Tile: ${isometric.tileAtMouse}");
  });
}

Widget get playerPosition {
  final character = modules.game.state.player;
  return Refresh((){
    return text("Player Position: X: ${character.x}, Y: ${character.y}");
  });
}

Widget get playerId {
  final character = modules.game.state.player;
  return Refresh((){
    return text("Player Id: ${character.id}");
  });
}

Widget get mousePositionWorld {
  return Refresh((){
    return text("Mouse World: x: ${mouseWorldX.toInt()}, y: ${mouseWorldY.toInt()}");
  });
}

Widget get mousePositionScreen {
  return Refresh((){
    return text("Mouse Screen: x: ${engine.mousePosition.x.toInt()}, y: ${engine.mousePosition.y.toInt()}");
  });
}

Widget get cameraZoom {
  return Refresh((){
    return text("Zoom: ${engine.zoom}");
  });
}

Widget get byteCountWatcher {
  return WatchBuilder(byteLength, (int count){
    return text("Bytes: $count");
  });
}

Widget get bufferLengthWatcher {
  return WatchBuilder(bufferSize, (int count){
    return text("Buffer Size: $count");
  });
}

Widget toggleDebugMode(){
  return WatchBuilder(state.compilePaths, (bool compilePaths){
    return button("Debug Mode: $compilePaths", modules.game.actions.toggleDebugPaths);
  });
}
