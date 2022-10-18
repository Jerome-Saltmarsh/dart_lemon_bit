import 'package:bleed_common/GameType.dart';
import 'package:bleed_common/Shade.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';
import 'package:gamestream_flutter/game_render.dart';
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
                  "mouseGridX: ${mouseGridX.toInt()}, mouseGridY: ${mouseGridY.toInt()}, mousePlayerAngle: ${mousePlayerAngle.toStringAsFixed(1)}, mouseWorldX: ${Engine.mouseWorldX.toInt()}, mouseWorldY: ${Engine.mouseWorldY.toInt()}"
                )),
                Refresh(() =>  text(
                  "player-position: x: ${Game.player.x}, y: ${Game.player.y}, z: ${Game.player.z}\n"
                  "player-index: z: ${Game.player.indexZ}, row: ${Game.player.indexRow}, column: ${Game.player.indexColumn}\n"
                  "player-render: renderX: ${Game.player.renderX}, renderY: ${Game.player.renderY}, angle: ${Game.player.angle}, mouseAngle: ${Game.player.mouseAngle}"
                )),
              watch(serverResponseReader.byteLength, (int bytes) => text('network-bytes: $bytes')),
              watch(serverResponseReader.bufferSize, (int bufferSize) => text('network-buffer: $bufferSize')),
              Refresh(() => text('characters: active: ${Game.totalCharacters}, total: ${Game.characters.length}')),
              Refresh(() => text('particles: active: $Game.totalActiveParticles, total: ${Game.particles.length}')),
              Refresh(() => text('nodes-rendered: ${GameRender.onscreenNodes}')),
              Refresh(() => text('engine-frame: ${Engine.paintFrame}')),
              onPressed(
                action: () => Engine.bufferBlendMode = BlendMode.values[(BlendMode.values.indexOf(Engine.bufferBlendMode) + 1) % BlendMode.values.length],
                  child: Refresh(() => text('render-blend-mode: ${Engine.bufferBlendMode}'))
              ),
              watch(Game.renderFrame, (t) => text("render-frame: $t")),
              watch(serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
              watch(Game.player.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => Game.player.interpolating.value = !Game.player.interpolating.value)),
              watch(Game.ambientShade, (int shade) => text("ambient-shade: ${Shade.getName(shade)}")),
              watch(Game.gameType, (int? value) => text("game-type: ${value == null ? 'None' : GameType.getName(value)}")),
              watch(Engine.deviceType, (int deviceType) => text("device-type: ${DeviceType.getName(deviceType)}", onPressed: Engine.toggleDeviceType)),
              height24,
              text("close x", onPressed: () => debugVisible.value = false),
            ],
          )),
    ],
  );
