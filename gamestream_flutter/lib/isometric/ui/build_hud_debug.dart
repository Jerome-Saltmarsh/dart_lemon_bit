import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/Shade.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/control/state/game_type.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/isometric/watches/ambient_shade.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:lemon_engine/engine.dart';

import '../server_response_reader.dart';
import 'widgets/build_container.dart';

Widget buildHudDebug() =>
  Stack(
    children: [
      Positioned(
          top: 0,
          left: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _buildContainerMouseInfo(),
                Refresh(() => text(
                  "mouseGridX: ${mouseGridX.toInt()}, mouseGridY: ${mouseGridY.toInt()}, mousePlayerAngle: ${mousePlayerAngle.toStringAsFixed(1)}, mouseWorldX: ${mouseWorldX.toInt()}, mouseWorldY: ${mouseWorldY.toInt()}"
                )),
                Refresh(() =>  text(
                  "player-position: x: ${player.x}, y: ${player.y}, z: ${player.z}\n"
                  "player-index: z: ${player.indexZ}, row: ${player.indexRow}, column: ${player.indexColumn}\n"
                  "player-render: renderX: ${player.renderX}, renderY: ${player.renderY}, angle: ${player.angle}, mouseAngle: ${player.mouseAngle}"
                )),
              watch(serverResponseReader.byteLength, (int bytes) => text('network-bytes: $bytes')),
              watch(serverResponseReader.bufferSize, (int bufferSize) => text('network-buffer: $bufferSize')),
              Refresh(() => text('characters: active: $totalCharacters, total: ${characters.length}')),
              Refresh(() => text('particles: active: $totalActiveParticles, total: ${particles.length}')),
              Refresh(() => text('nodes-rendered: $onscreenNodes')),
              Refresh(() => text('engine-frame: ${engine.frame}')),
              watch(renderFrame, (t) => text("render-frame: $t")),
              watch(serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
              watch(player.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => player.interpolating.value = !player.interpolating.value)),
              watch(ambientShade, (int shade) => text("ambient-shade: ${Shade.getName(shade)}")),
              watch(gameType, (int? value) => text("game-type: ${value == null ? 'None' : GameType.getName(value)}")),
            ],
          )),
    ],
  );

Widget _buildContainerMouseInfo() {
  return Refresh(() {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      color: Colors.grey,
      child: text(
          "mouseGridX: ${mouseGridX.toInt()}, mouseGridY: ${mouseGridY.toInt()}, mousePlayerAngle: ${mousePlayerAngle.toStringAsFixed(1)}, mouseWorldX: ${mouseWorldX.toInt()}, mouseWorldY: ${mouseWorldY.toInt()}"),
    );
  });
}

Widget _buildContainerPlayerInfo() {
  return Refresh(() {
    return Container(
        height: 50,
        alignment: Alignment.centerLeft,
        color: Colors.grey,
        child: text(
          "Player zIndex: ${player.indexZ}, row: ${player.indexRow}, column: ${player.indexColumn}, x: ${player.x}, y: ${player.y}, z: ${player.z}, renderX: ${player.renderX}, renderY: ${player.renderY}, angle: ${player.angle}, mouseAngle: ${player.mouseAngle}",
        ));
  });
}

Widget buildControlBytes() => watch(serverResponseReader.byteLength, (int bytes) => container(child: 'Bytes: $bytes'));
Widget buildControlBufferSize() => watch(serverResponseReader.bufferSize, (int bufferSize) => container(child: 'Buffer: $bufferSize'));