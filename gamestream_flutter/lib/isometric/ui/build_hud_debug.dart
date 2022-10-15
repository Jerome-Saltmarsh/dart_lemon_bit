import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/Shade.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/gamestream.dart';
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:gamestream_flutter/modules/game/render.dart';
import 'package:lemon_engine/engine.dart';

import '../server_response_reader.dart';

Widget buildHudDebug() =>
  Stack(
    children: [
      Positioned(
          top: 6,
          left: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _buildContainerMouseInfo(),
                Refresh(() => text(
                  "mouseGridX: ${mouseGridX.toInt()}, mouseGridY: ${mouseGridY.toInt()}, mousePlayerAngle: ${mousePlayerAngle.toStringAsFixed(1)}, mouseWorldX: ${mouseWorldX.toInt()}, mouseWorldY: ${mouseWorldY.toInt()}"
                )),
                Refresh(() =>  text(
                  "player-position: x: ${GameState.player.x}, y: ${GameState.player.y}, z: ${GameState.player.z}\n"
                  "player-index: z: ${GameState.player.indexZ}, row: ${GameState.player.indexRow}, column: ${GameState.player.indexColumn}\n"
                  "player-render: renderX: ${GameState.player.renderX}, renderY: ${GameState.player.renderY}, angle: ${GameState.player.angle}, mouseAngle: ${GameState.player.mouseAngle}"
                )),
              watch(serverResponseReader.byteLength, (int bytes) => text('network-bytes: $bytes')),
              watch(serverResponseReader.bufferSize, (int bufferSize) => text('network-buffer: $bufferSize')),
              Refresh(() => text('characters: active: ${GameState.totalCharacters}, total: ${GameState.characters.length}')),
              Refresh(() => text('particles: active: $GameState.totalActiveParticles, total: ${GameState.particles.length}')),
              Refresh(() => text('nodes-rendered: $onscreenNodes')),
              Refresh(() => text('engine-frame: ${Engine.paintFrame}')),
              watch(renderFrame, (t) => text("render-frame: $t")),
              watch(serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
              watch(GameState.player.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => GameState.player.interpolating.value = !GameState.player.interpolating.value)),
              watch(GameState.ambientShade, (int shade) => text("ambient-shade: ${Shade.getName(shade)}")),
              watch(gamestream.gameType, (int? value) => text("game-type: ${value == null ? 'None' : GameType.getName(value)}")),
              watch(Engine.deviceType, (int deviceType) => text("device-type: ${DeviceType.getName(deviceType)}", onPressed: Engine.toggleDeviceType)),
              height24,
              text("close x", onPressed: () => debugVisible.value = false),
            ],
          )),
    ],
  );
