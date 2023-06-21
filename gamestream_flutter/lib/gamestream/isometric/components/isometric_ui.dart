import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/format_bytes.dart';
import 'isometric_mouse.dart';

class IsometricUI {
  final menuOpen = WatchBool(false);
  final mouseOverDialog = WatchBool(false);

  Widget buildStackDebug() =>
      Stack(
        children: [
          Positioned(
              top: 6,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: gamestream.isometric.editor.style.brownLight,
                child: Column(
                  children: [
                    Container(
                      height: engine.screen.height - 100,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            watch(gamestream.bufferSize, (int bytes) => buildText('network-bytes: $bytes')),
                            watch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-total: ${formatBytes(bytes)}')),
                            watch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-per-second: ${gamestream.isometric.clientState.formatAverageBytePerSecond(bytes)}')),
                            watch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-per-minute: ${gamestream.isometric.clientState.formatAverageBytePerMinute(bytes)}')),
                            watch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-per-hour: ${gamestream.isometric.clientState.formatAverageBytePerHour(bytes)}')),
                            Refresh(() =>  buildText(
                                "connection-duration: ${gamestream.isometric..clientState.formattedConnectionDuration}\n"
                                // "offscreen-nodes: ${gamestream.isometricEngine.nodes.offscreenNodes}\n"
                                // "onscreen-nodes: ${gamestream.isometricEngine.nodes.onscreenNodes}\n"
                                    "touches: ${engine.touches}\n"
                                    "touch down id: ${engine.touchDownId}\n"
                                    "touch update id: ${engine.touchDownId}\n"
                                    "isometric-mouse-position: x: ${IsometricMouse.positionX.toInt()}, y: ${IsometricMouse.positionY.toInt()}\n"
                                    "mouse-world: x: ${engine.mouseWorldX.toInt()}, y: ${engine.mouseWorldY.toInt()}\n"
                                    'mouse-screen: x: ${engine.mousePositionX.toInt()}, y: ${engine.mousePositionY.toInt()}\n'
                                    "player-alive: ${gamestream.isometric.player.alive.value}\n"
                                    "player-respawn-timer: ${gamestream.isometric.player.respawnTimer.value}\n"
                                    "player-position: x: ${gamestream.isometric.player.position.x}, y: ${gamestream.isometric.player.position.y}, z: ${gamestream.isometric.player.position.z}\n"
                                    "player-render: x: ${gamestream.isometric.player.position.renderX}, y: ${gamestream.isometric.player.position.renderY}\n"
                                    "player-screen: x: ${gamestream.isometric.player.positionScreenX.toInt()}, y: ${gamestream.isometric.player.positionScreenY.toInt()}\n"
                                    "player-index: z: ${gamestream.isometric.player.position.indexZ}, row: ${gamestream.isometric.player.position.indexRow}, column: ${gamestream.isometric.player.position.indexColumn}\n"
                                    "player-inside-island: ${RendererNodes.playerInsideIsland}\n"
                                    "player-legs: ${ItemType.getName(gamestream.isometric.player.legs.value)}\n"
                                    "player-body: ${ItemType.getName(gamestream.isometric.player.body.value)}\n"
                                    "player-head: ${ItemType.getName(gamestream.isometric.player.head.value)}\n"
                                    "player-weapon: ${ItemType.getName(gamestream.isometric.player.weapon.value)}\n"
                                    "player-interact-mode: ${InteractMode.getName(gamestream.isometric.server.interactMode.value)}\n"
                                    "aim-target-category: ${TargetCategory.getName(gamestream.isometric.player.aimTargetCategory)}\n"
                                    "aim-target-type: ${gamestream.isometric.player.aimTargetType}\n"
                                    "aim-target-name: ${gamestream.isometric.player.aimTargetName}\n"
                                    "aim-target-position: ${gamestream.isometric.player.aimTargetPosition}\n"
                                    "target-category: ${TargetCategory.getName(gamestream.isometric.player.targetCategory)}\n"
                                    "target-position: ${gamestream.isometric.player.targetPosition}\n"
                                    "scene-light-sources: ${gamestream.isometric.nodes.nodesLightSourcesTotal}\n"
                                    "scene-light-active: ${gamestream.isometric.clientState.lights_active}\n"
                                    "total-gameobjects: ${gamestream.isometric.server.gameObjects.length}\n"
                                    "total-characters: ${gamestream.isometric.server.totalCharacters}\n"
                                    'total-particles: ${gamestream.isometric.particles.particles.length}\n'
                                    'total-particles-active: ${gamestream.isometric.particles.totalActiveParticles}\n'
                                    "offscreen-nodes: left: ${RendererNodes.offscreenNodesLeft}, top: ${RendererNodes.offscreenNodesTop}, right: ${RendererNodes.offscreenNodesRight}, bottom: ${RendererNodes.offscreenNodesBottom}"
                            )),
                            Refresh(() => buildText('touch-world: x: ${gamestream.io.touchCursorWorldX.toInt()}, y: ${gamestream.io.touchCursorWorldY.toInt()}')),
                            Refresh(() => buildText('engine-render-batches: ${engine.batchesRendered}')),
                            Refresh(() => buildText('engine-render-batch-1: ${engine.batches1Rendered}')),
                            Refresh(() => buildText('engine-render-batch-2: ${engine.batches2Rendered}')),
                            Refresh(() => buildText('engine-render-batch-4: ${engine.batches4Rendered}')),
                            Refresh(() => buildText('engine-render-batch-8: ${engine.batches8Rendered}')),
                            Refresh(() => buildText('engine-render-batch-16: ${engine.batches16Rendered}')),
                            Refresh(() => buildText('engine-render-batch-32: ${engine.batches32Rendered}')),
                            Refresh(() => buildText('engine-render-batch-64: ${engine.batches64Rendered}')),
                            Refresh(() => buildText('engine-render-batch-128: ${engine.batches128Rendered}')),
                            Refresh(() => buildText('camera-zoom: ${engine.targetZoom.toStringAsFixed(3)}')),
                            Refresh(() => buildText('engine-frame: ${engine.paintFrame}')),
                            watch(gamestream.updateFrame, (t) => buildText("update-frame: $t")),
                            watch(gamestream.isometric.player.interpolating, (bool interpolating) => buildText("interpolating: $interpolating", onPressed: () => gamestream.isometric.player.interpolating.value = !gamestream.isometric.player.interpolating.value)),
                            watch(gamestream.gameType, (GameType value) => buildText("game-type: ${value.name}")),
                            watch(engine.deviceType, (int deviceType) => buildText("device-type: ${DeviceType.getName(deviceType)}", onPressed: engine.toggleDeviceType)),
                            watch(gamestream.io.inputMode, (int inputMode) => buildText("input-mode: ${InputMode.getName(inputMode)}", onPressed: gamestream.io.actionToggleInputMode)),
                            watch(engine.watchMouseLeftDown, (bool mouseLeftDown) => buildText("mouse-left-down: $mouseLeftDown")),
                            watch(engine.mouseRightDown, (bool rightDown) => buildText("mouse-right-down: $rightDown")),
                            // watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
                          ],
                        ),
                      ),
                    ),
                    height24,
                    buildText("close x", onPressed: () => gamestream.isometric.clientState.debugMode.value = false, bold: true),
                  ],
                ),
              )),
        ],
      );
}