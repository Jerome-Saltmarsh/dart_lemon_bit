
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';

import 'library.dart';

class GameDebug {

  static final paths = Float32List(10000);
  static final targets = Float32List(10000);
  static var targetsTotal = 0;

  static Widget buildStackDebug() =>
      Stack(
        children: [
          Positioned(
              top: 6,
              left: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  watch(serverResponseReader.byteLength, (int bytes) => text('network-bytes: $bytes')),
                  watch(serverResponseReader.bufferSize, (int bufferSize) => text('network-buffer: $bufferSize')),
                  Refresh(() =>  text(
                      "mouse-world: x: ${Engine.mouseWorldX.toInt()}, y: ${Engine.mouseWorldY.toInt()}\n"
                      "mouse-grid: x: ${GameIO.mouseGridX.toInt()}, y: ${GameIO.mouseGridY.toInt()}\n"
                      'mouse-screen: x: ${Engine.mousePosition.x.toInt()}, y: ${Engine.mousePosition.y.toInt()}\n'
                      "player-position: x: ${GamePlayer.position.x}, y: ${GamePlayer.position.y}, z: ${GamePlayer.position.z}\n"
                      "player-index: z: ${GamePlayer.position.indexZ}, row: ${GamePlayer.position.indexRow}, column: ${GamePlayer.position.indexColumn}\n"
                      "player-render: x: ${GamePlayer.position.renderX}, y: ${GamePlayer.position.renderY}\n"
                      "player-screen: x: ${Engine.worldToScreenX(GamePlayer.position.renderX).toInt()}, y: ${Engine.worldToScreenY(GamePlayer.position.renderY).toInt()}"
                  )),
                  Refresh(() => text('touch-screen: x: ${GameIO.touchScreenX.toInt()}, y: ${GameIO.touchScreenY.toInt()}')),
                  Refresh(() => text('characters-total: ${GameState.characters.length}')),
                  Refresh(() => text('characters-active: ${GameState.totalCharacters}')),
                  Refresh(() => text('particles-total: ${GameState.particles.length}')),
                  Refresh(() => text('particles-active: ${GameState.totalActiveParticles}')),
                  Refresh(() => text('nodes-rendered: ${GameRender.onscreenNodes}')),
                  Refresh(() => text('engine-frame: ${Engine.paintFrame}')),
                  Refresh(() => text('engine-render-batches: ${Engine.batchesRendered}')),
                  Refresh(() => text('engine-render-batch-1: ${Engine.batches1Rendered}')),
                  Refresh(() => text('engine-render-batch-2: ${Engine.batches2Rendered}')),
                  Refresh(() => text('engine-render-batch-4: ${Engine.batches4Rendered}')),
                  Refresh(() => text('engine-render-batch-8: ${Engine.batches8Rendered}')),
                  Refresh(() => text('engine-render-batch-16: ${Engine.batches16Rendered}')),
                  Refresh(() => text('engine-render-batch-32: ${Engine.batches32Rendered}')),
                  Refresh(() => text('engine-render-batch-64: ${Engine.batches64Rendered}')),
                  Refresh(() => text('engine-render-batch-128: ${Engine.batches128Rendered}')),
                  watch(GameState.renderFrame, (t) => text("render-frame: $t")),
                  watch(serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
                  watch(GameState.player.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => GameState.player.interpolating.value = !GameState.player.interpolating.value)),
                  watch(GameState.ambientShade, (int shade) => text("ambient-shade: ${Shade.getName(shade)}")),
                  watch(GameState.gameType, (int? value) => text("game-type: ${value == null ? 'None' : GameType.getName(value)}")),
                  watch(Engine.deviceType, (int deviceType) => text("device-type: ${DeviceType.getName(deviceType)}", onPressed: Engine.toggleDeviceType)),
                  watch(GameIO.inputMode, (int inputMode) => text("input-mode: ${InputMode.getName(inputMode)}", onPressed: GameIO.actionToggleInputMode)),
                  height24,
                  text("close x", onPressed: () => GameState.debugVisible.value = false),
                ],
              )),
        ],
      );
}