import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/characters.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:lemon_engine/engine.dart';

import '../server_response_reader.dart';
import 'widgets/build_container.dart';

Widget buildHudDebug() {
  return Stack(
    children: [
      // Positioned(top: 0, right: 0, child: buildPanelMenu()),
      Positioned(
          top: 0,
          left: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildContainerMouseInfo(),
              _buildContainerPlayerInfo(),
              Row(
                children: [
                  buildControlBytes(),
                  buildControlBufferSize(),

                ],
              ),
              Refresh(() => text('characters: $totalCharacters')),
              Refresh(() => text('Onscreen: $onscreenNodes, off-left: $offscreenNodesLeft, off-top: $offscreenNodesTop, off-right: $offscreenNodesRight, off-bottom: $offscreenNodesBottom')),
            ],
          )),
    ],
  );
}

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

Widget buildControlBytes() => watch(byteLength, (int bytes) => container(child: 'Bytes: $bytes'));
Widget buildControlBufferSize() => watch(bufferSize, (int bufferSize) => container(child: 'Buffer: $bufferSize'));