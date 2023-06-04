

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_client_state.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/library.dart';

import 'render/renderer_nodes.dart';


class GameIsometricDebug {

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
                      height: engine.screen.height - 100,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            watch(gamestream.serverResponseReader.bufferSize, (int bytes) => text('network-bytes: $bytes')),
                            watch(gamestream.serverResponseReader.bufferSizeTotal, (int bytes) => text('network-bytes-total: ${GameIsometricClientState.formatBytes(bytes)}')),
                            watch(gamestream.serverResponseReader.bufferSizeTotal, (int bytes) => text('network-bytes-per-second: ${gamestream.games.isometric.clientState.formatAverageBytePerSecond(bytes)}')),
                            watch(gamestream.serverResponseReader.bufferSizeTotal, (int bytes) => text('network-bytes-per-minute: ${gamestream.games.isometric.clientState.formatAverageBytePerMinute(bytes)}')),
                            watch(gamestream.serverResponseReader.bufferSizeTotal, (int bytes) => text('network-bytes-per-hour: ${gamestream.games.isometric.clientState.formatAverageBytePerHour(bytes)}')),
                            Refresh(() =>  text(
                                "connection-duration: ${gamestream.games.isometric.clientState.formattedConnectionDuration}\n"
                                // "offscreen-nodes: ${gamestream.games.isometric.nodes.offscreenNodes}\n"
                                // "onscreen-nodes: ${gamestream.games.isometric.nodes.onscreenNodes}\n"
                                    "touches: ${engine.touches}\n"
                                    "touch down id: ${engine.touchDownId}\n"
                                    "touch update id: ${engine.touchDownId}\n"
                                    "mouse-grid: x: ${gamestream.io.mouseGridX.toInt()}, y: ${gamestream.io.mouseGridY.toInt()}\n"
                                    "mouse-world: x: ${engine.mouseWorldX.toInt()}, y: ${engine.mouseWorldY.toInt()}\n"
                                    'mouse-screen: x: ${engine.mousePositionX.toInt()}, y: ${engine.mousePositionY.toInt()}\n'
                                    'mouse-player-angle: ${ClientQuery.getMousePlayerAngle().toStringAsFixed(4)}\n'
                                    "player-alive: ${gamestream.games.isometric.player.alive.value}\n"
                                    "player-respawn-timer: ${gamestream.games.isometric.player.respawnTimer.value}\n"
                                    "player-position: x: ${gamestream.games.isometric.player.position.x}, y: ${gamestream.games.isometric.player.position.y}, z: ${gamestream.games.isometric.player.position.z}\n"
                                    "player-render: x: ${gamestream.games.isometric.player.position.renderX}, y: ${gamestream.games.isometric.player.position.renderY}\n"
                                    "player-screen: x: ${gamestream.games.isometric.player.positionScreenX.toInt()}, y: ${gamestream.games.isometric.player.positionScreenY.toInt()}\n"
                                    "player-index: z: ${gamestream.games.isometric.player.position.indexZ}, row: ${gamestream.games.isometric.player.position.indexRow}, column: ${gamestream.games.isometric.player.position.indexColumn}\n"
                                    "player-inside-island: ${RendererNodes.playerInsideIsland}\n"
                                    "player-legs: ${ItemType.getName(gamestream.games.isometric.player.legs.value)}\n"
                                    "player-body: ${ItemType.getName(gamestream.games.isometric.player.body.value)}\n"
                                    "player-head: ${ItemType.getName(gamestream.games.isometric.player.head.value)}\n"
                                    "player-weapon: ${ItemType.getName(gamestream.games.isometric.player.weapon.value)}\n"
                                    "player-interact-mode: ${InteractMode.getName(gamestream.games.isometric.serverState.interactMode.value)}\n"
                                    "aim-target-category: ${TargetCategory.getName(gamestream.games.isometric.player.aimTargetCategory)}\n"
                                    "aim-target-type: ${gamestream.games.isometric.player.aimTargetType}\n"
                                    "aim-target-name: ${gamestream.games.isometric.player.aimTargetName}\n"
                                    "aim-target-position: ${gamestream.games.isometric.player.aimTargetPosition}\n"
                                    "target-category: ${TargetCategory.getName(gamestream.games.isometric.player.targetCategory)}\n"
                                    "target-position: ${gamestream.games.isometric.player.targetPosition}\n"
                                    "dialog-type: ${DialogType.getName(gamestream.games.isometric.clientState.hoverDialogType.value)}\n"
                                    "scene-light-sources: ${gamestream.games.isometric.clientState.nodesLightSourcesTotal}\n"
                                    "scene-light-active: ${gamestream.games.isometric.clientState.lights_active}\n"
                                    "total-gameobjects: ${gamestream.games.isometric.serverState.gameObjects.length}\n"
                                    "total-characters: ${gamestream.games.isometric.serverState.totalCharacters}\n"
                                    'total-particles: ${gamestream.games.isometric.clientState.particles.length}\n'
                                    'total-particles-active: ${gamestream.games.isometric.clientState.totalActiveParticles}\n'
                                    "offscreen-nodes: left: ${RendererNodes.offscreenNodesLeft}, top: ${RendererNodes.offscreenNodesTop}, right: ${RendererNodes.offscreenNodesRight}, bottom: ${RendererNodes.offscreenNodesBottom}"
                            )),
                            Refresh(() => text('touch-world: x: ${gamestream.io.touchCursorWorldX.toInt()}, y: ${gamestream.io.touchCursorWorldY.toInt()}')),
                            Refresh(() => text('engine-render-batches: ${engine.batchesRendered}')),
                            Refresh(() => text('engine-render-batch-1: ${engine.batches1Rendered}')),
                            Refresh(() => text('engine-render-batch-2: ${engine.batches2Rendered}')),
                            Refresh(() => text('engine-render-batch-4: ${engine.batches4Rendered}')),
                            Refresh(() => text('engine-render-batch-8: ${engine.batches8Rendered}')),
                            Refresh(() => text('engine-render-batch-16: ${engine.batches16Rendered}')),
                            Refresh(() => text('engine-render-batch-32: ${engine.batches32Rendered}')),
                            Refresh(() => text('engine-render-batch-64: ${engine.batches64Rendered}')),
                            Refresh(() => text('engine-render-batch-128: ${engine.batches128Rendered}')),
                            Refresh(() => text('camera-zoom: ${engine.targetZoom.toStringAsFixed(3)}')),
                            Refresh(() => text('engine-frame: ${engine.paintFrame}')),
                            watch(gamestream.serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
                            watch(gamestream.games.isometric.player.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => gamestream.games.isometric.player.interpolating.value = !gamestream.games.isometric.player.interpolating.value)),
                            watch(gamestream.gameType, (GameType value) => text("game-type: ${value.name}")),
                            watch(engine.deviceType, (int deviceType) => text("device-type: ${DeviceType.getName(deviceType)}", onPressed: engine.toggleDeviceType)),
                            watch(gamestream.io.inputMode, (int inputMode) => text("input-mode: ${InputMode.getName(inputMode)}", onPressed: gamestream.io.actionToggleInputMode)),
                            watch(engine.watchMouseLeftDown, (bool mouseLeftDown) => text("mouse-left-down: $mouseLeftDown")),
                            watch(engine.mouseRightDown, (bool rightDown) => text("mouse-right-down: $rightDown")),
                            // watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
                          ],
                        ),
                      ),
                    ),
                    height24,
                    text("close x", onPressed: () => gamestream.games.isometric.clientState.debugMode.value = false, bold: true),
                  ],
                ),
              )),
        ],
      );
}

Future<double> getFutureDouble01(double initial) async =>
    clamp01(await getFutureDouble(initial));


Future<double> getFutureDouble(double initial) async =>
    await showDialog<double>(context: engine.buildContext, builder: (context){
      final controller = TextEditingController(text: initial.toString());
      return AlertDialog(
        content: Container(
          width: 100,
          padding: const EdgeInsets.all(16),
          color: Colors.blue,
          child: Row(
            children: [
              Container(
                width: 60,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                ),
              ),
              text("Enter", onPressed: () =>
                  Navigator.pop(
                      context,
                      double.tryParse(controller.text) ?? initial
                  )
              ),
            ],
          ),
        ),
      );
    }) ?? initial;


Widget buildColumnLightingControls(){
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text("Override Color"),
          watch(gamestream.games.isometric.clientState.overrideColor, (bool overrideColor){
            return Checkbox(value: overrideColor, onChanged: (bool? value){
              if (value == null) return;
              gamestream.games.isometric.clientState.overrideColor.value = value;
            });
          })
        ],
      ),
      // ColorPicker(
      //   pickerColor: HSVColor.fromAHSV(
      //       gamestream.games.isometric.nodes.ambient_alp,
      //       gamestream.games.isometric.nodes.ambient_hue,
      //       gamestream.games.isometric.nodes.ambient_sat,
      //       gamestream.games.isometric.nodes.ambient_val,
      //   ).toColor(),
      //   onColorChanged: (color){
      //     gamestream.games.isometric.clientState.overrideColor.value = true;
      //     final hsvColor = HSVColor.fromColor(color);
      //     gamestream.games.isometric.nodes.ambient_alp = hsvColor.alpha;
      //     gamestream.games.isometric.nodes.ambient_hue = hsvColor.hue;
      //     gamestream.games.isometric.nodes.ambient_sat = hsvColor.saturation;
      //     gamestream.games.isometric.nodes.ambient_val = hsvColor.value;
      //     gamestream.games.isometric.nodes.resetNodeColorsToAmbient();
      //   },
      // ),
    ],
  );
}
