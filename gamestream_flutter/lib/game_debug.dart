
import 'package:flutter/material.dart';

import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

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
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: brownDark,
                child: Column(
                  children: [
                    Container(
                      height: Engine.screen.height - 100,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            watch(serverResponseReader.byteLength, (int bytes) => text('network-bytes: $bytes')),
                            watch(serverResponseReader.bufferSize, (int bufferSize) => text('network-buffer: $bufferSize')),
                            Refresh(() =>  text(
                                "mouse-grid: x: ${GameIO.mouseGridX.toInt()}, y: ${GameIO.mouseGridY.toInt()}\n"
                                "mouse-world: x: ${Engine.mouseWorldX.toInt()}, y: ${Engine.mouseWorldY.toInt()}\n"
                                'mouse-screen: x: ${Engine.mousePosition.x.toInt()}, y: ${Engine.mousePosition.y.toInt()}\n'
                                "player-position: x: ${GamePlayer.position.x}, y: ${GamePlayer.position.y}, z: ${GamePlayer.position.z}\n"
                                "player-render: x: ${GamePlayer.position.renderX}, y: ${GamePlayer.position.renderY}\n"
                                "player-screen: x: ${Engine.worldToScreenX(GamePlayer.position.renderX).toInt()}, y: ${Engine.worldToScreenY(GamePlayer.position.renderY).toInt()}\n"
                                "player-index: z: ${GamePlayer.position.indexZ}, row: ${GamePlayer.position.indexRow}, column: ${GamePlayer.position.indexColumn}\n"
                                "aim-target-category: ${TargetCategory.getName(GamePlayer.aimTargetCategory)}\n"
                                "aim-target-type: ${GamePlayer.aimTargetType}\n"
                                "aim-target-name: ${GamePlayer.aimTargetName}\n"
                                "aim-target-position: ${GamePlayer.aimTargetPosition}\n"
                                "target-category: ${TargetCategory.getName(GamePlayer.targetCategory)}\n"
                                "target-position: ${GamePlayer.targetPosition}\n"
                                "dialog-type: ${DialogType.getName(ClientState.hoverDialogType.value)}\n"
                                "player-legs: ${ItemType.getName(GamePlayer.legs.value)}\n"
                                "player-body: ${ItemType.getName(GamePlayer.body.value)}\n"
                                "player-head: ${ItemType.getName(GamePlayer.head.value)}\n"
                                "player-weapon: ${ItemType.getName(GamePlayer.weapon.value)}\n"
                                "player-interact-mode: ${InteractMode.getName(ServerState.interactMode.value)}"
                            )),
                            Refresh(() => text('touch-world: x: ${GameIO.touchCursorWorldX.toInt()}, y: ${GameIO.touchCursorWorldY.toInt()}')),
                            Refresh(() => text('characters-total: ${GameState.characters.length}')),
                            Refresh(() => text('characters-active: ${GameState.totalCharacters}')),
                            Refresh(() => text('particles-total: ${GameState.particles.length}')),
                            Refresh(() => text('particles-active: ${GameState.totalActiveParticles}')),
                            Refresh(() => text('nodes-rendered: ${GameRender.onscreenNodes}')),
                            Refresh(() => text('engine-render-batches: ${Engine.batchesRendered}')),
                            Refresh(() => text('engine-render-batch-1: ${Engine.batches1Rendered}')),
                            Refresh(() => text('engine-render-batch-2: ${Engine.batches2Rendered}')),
                            Refresh(() => text('engine-render-batch-4: ${Engine.batches4Rendered}')),
                            Refresh(() => text('engine-render-batch-8: ${Engine.batches8Rendered}')),
                            Refresh(() => text('engine-render-batch-16: ${Engine.batches16Rendered}')),
                            Refresh(() => text('engine-render-batch-32: ${Engine.batches32Rendered}')),
                            Refresh(() => text('engine-render-batch-64: ${Engine.batches64Rendered}')),
                            Refresh(() => text('engine-render-batch-128: ${Engine.batches128Rendered}')),
                            Refresh(() => text('camera-zoom: ${Engine.targetZoom.toStringAsFixed(3)}')),
                            Refresh(() => text('engine-frame: ${Engine.paintFrame}')),
                            watch(serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
                            watch(GameState.renderFrame, (t) => text("render-frame: $t")),
                            watch(GameState.player.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => GameState.player.interpolating.value = !GameState.player.interpolating.value)),
                            watch(ServerState.ambientShade, (int shade) => text("ambient-shade: ${Shade.getName(shade)}")),
                            watch(GameState.gameType, (int? value) => text("game-type: ${value == null ? 'None' : GameType.getName(value)}")),
                            watch(Engine.deviceType, (int deviceType) => text("device-type: ${DeviceType.getName(deviceType)}", onPressed: Engine.toggleDeviceType)),
                            watch(GameIO.inputMode, (int inputMode) => text("input-mode: ${InputMode.getName(inputMode)}", onPressed: GameIO.actionToggleInputMode)),
                            watch(Engine.watchMouseLeftDown, (bool mouseLeftDown) => text("mouse-left-down: $mouseLeftDown")),
                            watch(Engine.mouseRightDown, (bool rightDown) => text("mouse-right-down: $rightDown")),
                          ],
                        ),
                      ),
                    ),
                    height24,
                    text("close x", onPressed: () => GameState.debugVisible.value = false),
                  ],
                ),
              )),
        ],
      );
}