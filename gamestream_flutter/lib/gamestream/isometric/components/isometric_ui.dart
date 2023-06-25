import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/ui/src.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/format_bytes.dart';
import 'isometric_mouse.dart';

class IsometricUI {
  final windowOpenMenu = WatchBool(false);
  final windowOpenDebug = WatchBool(false);
  final windowOpenLightSettings = WatchBool(false);
  final mouseOverDialog = WatchBool(false);

  Widget buildStackDebug() =>
      buildWatchBool(windowOpenDebug, () => Stack(
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
                              buildWatch(gamestream.bufferSize, (int bytes) => buildText('network-bytes: $bytes')),
                              buildWatch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-total: ${formatBytes(bytes)}')),
                              buildWatch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-per-second: ${gamestream.isometric.clientState.formatAverageBytePerSecond(bytes)}')),
                              buildWatch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-per-minute: ${gamestream.isometric.clientState.formatAverageBytePerMinute(bytes)}')),
                              buildWatch(gamestream.bufferSizeTotal, (int bytes) => buildText('network-bytes-per-hour: ${gamestream.isometric.clientState.formatAverageBytePerHour(bytes)}')),
                              GSRefresh(() =>  buildText(
                                  'connection-duration: ${gamestream.isometric..clientState.formattedConnectionDuration}\n'
                                  // "offscreen-nodes: ${gamestream.isometricEngine.nodes.offscreenNodes}\n"
                                  // "onscreen-nodes: ${gamestream.isometricEngine.nodes.onscreenNodes}\n"
                                      'touches: ${engine.touches}\n'
                                      'touch down id: ${engine.touchDownId}\n'
                                      'touch update id: ${engine.touchDownId}\n'
                                      'isometric-mouse-position: x: ${IsometricMouse.positionX.toInt()}, y: ${IsometricMouse.positionY.toInt()}\n'
                                      'mouse-world: x: ${engine.mouseWorldX.toInt()}, y: ${engine.mouseWorldY.toInt()}\n'
                                      'mouse-screen: x: ${engine.mousePositionX.toInt()}, y: ${engine.mousePositionY.toInt()}\n'
                                      'player-alive: ${gamestream.isometric.player.alive.value}\n'
                                      'player-respawn-timer: ${gamestream.isometric.player.respawnTimer.value}\n'
                                      'player-position: x: ${gamestream.isometric.player.position.x}, y: ${gamestream.isometric.player.position.y}, z: ${gamestream.isometric.player.position.z}\n'
                                      'player-render: x: ${gamestream.isometric.player.position.renderX}, y: ${gamestream.isometric.player.position.renderY}\n'
                                      'player-screen: x: ${gamestream.isometric.player.positionScreenX.toInt()}, y: ${gamestream.isometric.player.positionScreenY.toInt()}\n'
                                      'player-index: z: ${gamestream.isometric.player.position.indexZ}, row: ${gamestream.isometric.player.position.indexRow}, column: ${gamestream.isometric.player.position.indexColumn}\n'
                                      'player-inside-island: ${RendererNodes.playerInsideIsland}\n'
                                      'player-legs: ${ItemType.getName(gamestream.isometric.player.legs.value)}\n'
                                      'player-body: ${ItemType.getName(gamestream.isometric.player.body.value)}\n'
                                      'player-head: ${ItemType.getName(gamestream.isometric.player.head.value)}\n'
                                      'player-weapon: ${ItemType.getName(gamestream.isometric.player.weapon.value)}\n'
                                      'player-interact-mode: ${InteractMode.getName(gamestream.isometric.server.interactMode.value)}\n'
                                      'aim-target-category: ${TargetCategory.getName(gamestream.isometric.player.aimTargetCategory)}\n'
                                      'aim-target-type: ${gamestream.isometric.player.aimTargetType}\n'
                                      'aim-target-name: ${gamestream.isometric.player.aimTargetName}\n'
                                      'aim-target-position: ${gamestream.isometric.player.aimTargetPosition}\n'
                                      'target-category: ${TargetCategory.getName(gamestream.isometric.player.targetCategory)}\n'
                                      'target-position: ${gamestream.isometric.player.targetPosition}\n'
                                      'scene-light-sources: ${gamestream.isometric.nodes.nodesLightSourcesTotal}\n'
                                      'scene-light-active: ${gamestream.isometric.clientState.lights_active}\n'
                                      'total-gameobjects: ${gamestream.isometric.server.gameObjects.length}\n'
                                      'total-characters: ${gamestream.isometric.server.totalCharacters}\n'
                                      'total-particles: ${gamestream.isometric.particles.particles.length}\n'
                                      'total-particles-active: ${gamestream.isometric.particles.totalActiveParticles}\n'
                                      'offscreen-nodes: left: ${RendererNodes.offscreenNodesLeft}, top: ${RendererNodes.offscreenNodesTop}, right: ${RendererNodes.offscreenNodesRight}, bottom: ${RendererNodes.offscreenNodesBottom}'
                              )),
                              GSRefresh(() => buildText('touch-world: x: ${gamestream.io.touchCursorWorldX.toInt()}, y: ${gamestream.io.touchCursorWorldY.toInt()}')),
                              GSRefresh(() => buildText('engine-render-batches: ${engine.batchesRendered}')),
                              GSRefresh(() => buildText('engine-render-batch-1: ${engine.batches1Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-2: ${engine.batches2Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-4: ${engine.batches4Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-8: ${engine.batches8Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-16: ${engine.batches16Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-32: ${engine.batches32Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-64: ${engine.batches64Rendered}')),
                              GSRefresh(() => buildText('engine-render-batch-128: ${engine.batches128Rendered}')),
                              GSRefresh(() => buildText('camera-zoom: ${engine.targetZoom.toStringAsFixed(3)}')),
                              GSRefresh(() => buildText('engine-frame: ${engine.paintFrame}')),
                              buildWatch(gamestream.updateFrame, (t) => buildText('update-frame: $t')),
                              buildWatch(gamestream.isometric.player.interpolating, (bool interpolating) => buildText('interpolating: $interpolating', onPressed: () => gamestream.isometric.player.interpolating.value = !gamestream.isometric.player.interpolating.value)),
                              buildWatch(gamestream.gameType, (GameType value) => buildText('game-type: ${value.name}')),
                              buildWatch(engine.deviceType, (int deviceType) => buildText('device-type: ${DeviceType.getName(deviceType)}', onPressed: engine.toggleDeviceType)),
                              buildWatch(gamestream.io.inputMode, (int inputMode) => buildText('input-mode: ${InputMode.getName(inputMode)}', onPressed: gamestream.io.actionToggleInputMode)),
                              buildWatch(engine.watchMouseLeftDown, (bool mouseLeftDown) => buildText('mouse-left-down: $mouseLeftDown')),
                              buildWatch(engine.mouseRightDown, (bool rightDown) => buildText('mouse-right-down: $rightDown')),
                              // watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
                            ],
                          ),
                        ),
                      ),
                      height24,
                      buildText('close x', onPressed: () => gamestream.isometric.clientState.debugMode.value = false, bold: true),
                    ],
                  ),
                )),
          ],
        ));


  Widget buildWindowLightSettings() =>
    buildWatch(windowOpenLightSettings, (t) => !t ? nothing :
      Container(
        padding: GameStyle.Padding_6,
        color: GameIsometricColors.brownDark,
        width: 300,
        child: Column(
          children: [
            buildText('Light-Settings', bold: true),
            height8,
            onPressed(
                action: gamestream.isometric.clientState.toggleDynamicShadows,
                child: GSRefresh(() => buildText('dynamic-shadows-enabled: ${gamestream.isometric.clientState.dynamicShadows}'))
            ),
            onPressed(
                child: GSRefresh(() => buildText('blend-mode: ${engine.bufferBlendMode.name}')),
                action: (){
                  final currentIndex = BlendMode.values.indexOf(engine.bufferBlendMode);
                  final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                  engine.bufferBlendMode = BlendMode.values[nextIndex];
                }
            ),
            height8,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText('<-', onPressed: (){
                  gamestream.isometric.nodes.setInterpolationLength(gamestream.isometric.nodes.interpolation_length - 1);
                }),
                GSRefresh(() => buildText('light-size: ${gamestream.isometric.nodes.interpolation_length}')),
                buildText('->', onPressed: (){
                  gamestream.isometric.nodes.setInterpolationLength(gamestream.isometric.nodes.interpolation_length + 1);
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText('<-', onPressed: (){
                  final indexCurrent = EaseType.values.indexOf(gamestream.isometric.nodes.interpolation_ease_type.value);
                  final indexNext = indexCurrent - 1 >= 0 ? indexCurrent - 1 : EaseType.values.length - 1;
                  gamestream.isometric.nodes.interpolation_ease_type.value = EaseType.values[indexNext];
                }),
                buildWatch(gamestream.isometric.nodes.interpolation_ease_type, buildText),
                buildText('->', onPressed: (){
                  final indexCurrent = EaseType.values.indexOf(gamestream.isometric.nodes.interpolation_ease_type.value);
                  final indexNext = indexCurrent + 1 >= EaseType.values.length ? 0 : indexCurrent + 1;
                  gamestream.isometric.nodes.interpolation_ease_type.value = EaseType.values[indexNext];
                }),
              ],
            ),

            height16,
            buildText('ambient-color'),
            ColorPicker(
              portraitOnly: true,
              pickerColor: HSVColor.fromAHSV(
                gamestream.isometric.nodes.ambient_alp / 255,
                gamestream.isometric.nodes.ambient_hue.toDouble(),
                gamestream.isometric.nodes.ambient_sat / 100,
                gamestream.isometric.nodes.ambient_val / 100,
              ).toColor(),
              onColorChanged: (color){
                gamestream.isometric.clientState.overrideColor.value = true;
                final hsvColor = HSVColor.fromColor(color);
                gamestream.isometric.nodes.ambient_alp = (hsvColor.alpha * 255).round();
                gamestream.isometric.nodes.ambient_hue = hsvColor.hue.round();
                gamestream.isometric.nodes.ambient_sat = (hsvColor.saturation * 100).round();
                gamestream.isometric.nodes.ambient_val = (hsvColor.value * 100).round();
                gamestream.isometric.nodes.resetNodeColorsToAmbient();
              },
            ),
          ],
        ),
      )
    );


}