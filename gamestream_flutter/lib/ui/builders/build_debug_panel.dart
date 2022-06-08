import 'package:bleed_common/version.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/ui/builders/build_row_tech_type.dart';
import 'package:gamestream_flutter/ui/builders/build_time.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

Widget buildPanelDebug(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildVersion(),
      buildTime(),
      buildTotalZombies(),
      buildTotalPlayers(),
      mouseRowColumn(),
      mouseRowColumnPercentage(),
      buildTotalParticles,
      buildActiveParticles,
      tileAtMouse,
      mousePositionWorld,
      mousePositionGrid,
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
    return text("Mouse Row: $mouseRow, Column: $mouseColumn");
  });
}

Widget mouseRowColumnPercentage(){
  return Refresh((){
    return text("Mouse Row Perc: $mouseRowPercentage(), Column: $mouseColumn");
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
    return text("Player Screen: x: ${worldToScreenX(state.player.x).toInt()}, y: ${worldToScreenY(state.player.y).toInt()}");
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
    return text("Player Position: X: ${character.x}, Y: ${character.y}, Z: ${character.z}");
  });
}

Widget get mousePositionWorld {
  return Refresh((){
    return text("Mouse World: x: ${mouseWorldX.toInt()}, y: ${mouseWorldY.toInt()}");
  });
}

Widget get mousePositionGrid {
  return Refresh((){
    return text("Mouse Grid: x: ${mouseGridX.toInt()}, y: ${mouseGridY.toInt()}");
  });
}


Widget get mousePositionScreen {
  return Refresh((){
    return text("Mouse Screen: x: ${engine.mousePosition.x.toInt()}, y: ${engine.mousePosition.y.toInt()}");
  });
}

Widget get cameraZoom {
  return Refresh((){
    return text("Zoom: ${engine.zoom.toStringAsFixed(4)}");
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

