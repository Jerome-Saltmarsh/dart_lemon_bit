import 'package:bleed_common/version.dart';
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/ui/builders/build_time.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch_builder.dart';

import '../../isometric/player.dart';

Widget buildPanelDebug(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildVersion(),
      buildTime(),
      mouseRowColumn(),
      mouseRowColumnPercentage(),
      buildTotalParticles,
      buildActiveParticles,
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
    return text("Particles: ${particles.length}");
  });
}

Widget get playerScreen {
  return Refresh(() {
    return text("Player Screen: x: ${worldToScreenX(player.x).toInt()}, y: ${worldToScreenY(player.y).toInt()}");
  });
}

Widget get buildActiveParticles {
  return Refresh((){
    return text("Active Particles: ${totalActiveParticles}");
  });
}

Widget get playerPosition {
  return Refresh((){
    return text("Player Position: X: ${player.x}, Y: ${player.y}, Z: ${player.z}");
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

