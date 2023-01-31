
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/server_response_reader.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';

import 'library.dart';
import 'render/renderer_nodes.dart';

class GameDebug {

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
                            Refresh(() =>  text(
                                "mouse-grid: x: ${GameIO.mouseGridX.toInt()}, y: ${GameIO.mouseGridY.toInt()}\n"
                                "mouse-world: x: ${Engine.mouseWorldX.toInt()}, y: ${Engine.mouseWorldY.toInt()}\n"
                                'mouse-screen: x: ${Engine.mousePosition.x.toInt()}, y: ${Engine.mousePosition.y.toInt()}\n'
                                'mouse-player-angle: ${ClientQuery.getMousePlayerAngle().toStringAsFixed(4)}\n'
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
                                "player-interact-mode: ${InteractMode.getName(ServerState.interactMode.value)}\n"
                                "scene-light-sources: ${ClientState.nodesLightSourcesTotal}\n"
                                "total-gameobjects: ${ServerState.gameObjects.length}\n"
                                "total-characters: ${ServerState.totalCharacters}\n"
                                'total-particles: ${ClientState.particles.length}\n'
                                'total-particles-active: ${ClientState.totalActiveParticles}\n'
                                "offscreen-nodes: left: ${RendererNodes.offscreenNodesLeft}, top: ${RendererNodes.offscreenNodesTop}, right: ${RendererNodes.offscreenNodesRight}, bottom: ${RendererNodes.offscreenNodesBottom}"
                            )),
                            Refresh(() => text('touch-world: x: ${GameIO.touchCursorWorldX.toInt()}, y: ${GameIO.touchCursorWorldY.toInt()}')),
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
                            onPressed(
                                child: Refresh(() => text('engine-render-blend-mode: ${Engine.bufferBlendMode.name}')),
                                action: (){
                                   final currentIndex = BlendMode.values.indexOf(Engine.bufferBlendMode);
                                   final nextIndex = currentIndex + 1 >= BlendMode.values.length ? 0 : currentIndex + 1;
                                   Engine.bufferBlendMode = BlendMode.values[nextIndex];
                                }
                            ),
                            watch(serverResponseReader.updateFrame, (t) => text("update-frame: $t")),
                            watch(GamePlayer.interpolating, (bool interpolating) => text("interpolating: $interpolating", onPressed: () => GamePlayer.interpolating.value = !GamePlayer.interpolating.value)),
                            watch(ServerState.gameType, (int? value) => text("game-type: ${value == null ? 'None' : GameType.getName(value)}")),
                            watch(Engine.deviceType, (int deviceType) => text("device-type: ${DeviceType.getName(deviceType)}", onPressed: Engine.toggleDeviceType)),
                            watch(GameIO.inputMode, (int inputMode) => text("input-mode: ${InputMode.getName(inputMode)}", onPressed: GameIO.actionToggleInputMode)),
                            watch(Engine.watchMouseLeftDown, (bool mouseLeftDown) => text("mouse-left-down: $mouseLeftDown")),
                            watch(Engine.mouseRightDown, (bool rightDown) => text("mouse-right-down: $rightDown")),
                            watch(GameEditor.nodeSelectedIndex, (int index) => text("edit-state-node-index: $index")),
                            buildColumnLightingControls(),
                          ],
                        ),
                      ),
                    ),
                    height24,
                    text("close x", onPressed: () => ClientState.debugMode.value = false, bold: true),
                  ],
                ),
              )),
        ],
      );
}

Future<double> getFutureDouble01(double initial) async =>
    clamp01(await getFutureDouble(initial));


Future<double> getFutureDouble(double initial) async =>
  await showDialog<double>(context: Engine.buildContext, builder: (context){
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
          watch(ClientState.overrideColor, (bool overrideColor){
            return Checkbox(value: overrideColor, onChanged: (bool? value){
               if (value == null) return;
               ClientState.overrideColor.value = value;
            });
          })
        ],
      ),
      // ColorPicker(
      //   pickerColor: HSVColor.fromAHSV(
      //       GameNodes.ambient_alp,
      //       GameNodes.ambient_hue,
      //       GameNodes.ambient_sat,
      //       GameNodes.ambient_val,
      //   ).toColor(),
      //   onColorChanged: (color){
      //     ClientState.overrideColor.value = true;
      //     final hsvColor = HSVColor.fromColor(color);
      //     GameNodes.ambient_alp = hsvColor.alpha;
      //     GameNodes.ambient_hue = hsvColor.hue;
      //     GameNodes.ambient_sat = hsvColor.saturation;
      //     GameNodes.ambient_val = hsvColor.value;
      //     GameNodes.resetNodeColorsToAmbient();
      //   },
      // ),
    ],
  );
}