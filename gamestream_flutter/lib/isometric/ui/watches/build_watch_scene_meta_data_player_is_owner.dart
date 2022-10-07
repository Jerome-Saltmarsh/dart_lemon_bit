import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/spawn_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_show_game_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/edit.dart';
import 'package:gamestream_flutter/isometric/editor/actions/editor_action_modify_spawn_node.dart';
import 'package:gamestream_flutter/isometric/editor/actions/save_scene.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/modules/core/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/screen.dart';

import '../../../styles.dart';
import '../stacks/build_page.dart';
import '../widgets/build_container.dart';

Widget buildPlayMode(bool edit) =>
  edit ? buildStackEdit() : buildStackPlay();

Widget buildStackEdit() =>
    buildPage(
    children: [
      watch(editorDialog, buildWatchEditorDialog),
      Positioned(
        right: 6,
        top: 80,
        child: buildWatchBool(
            edit.nodeOrientationVisible,
            buildColumnEditNodeOrientation
        ),
      ),
      Positioned(
        right: 6,
        top: 80,
        child: buildColumnEditNodeSpawn(),
      ),
      Positioned(
        left: 0,
        bottom: 6,
        child: buildColumnSelectedGameObject(),
      ),
      Positioned(
        left: 200,
        top: 56,
        child: buildEditorSelectedNode(),
      ),
      Positioned(
          bottom: 6,
          left: 0,
          child: Container(
            width: screen.width,
            alignment: Alignment.center,
            child: buildWatchBool(
                edit.controlsVisibleWeather,
                buildControlsWeather,
            ),
          )
      ),
      Positioned(
        left: 0,
        top: 0,
        child: buildEditorMenu(),
      ),
    ],
  );

Widget buildColumnEditNodeOrientation() =>
    Column(
      children: [
        buildColumnNodeOrientationSolid(),
        buildColumnNodeOrientationSlopeSymmetric(),
        buildColumnNodeOrientationCorner(),
        buildColumnNodeOrientationHalf(),
        buildColumnNodeOrientationSlopeCornerInner(),
        buildColumnNodeOrientationSlopeCornerOuter(),
      ],
    );

Widget buildColumnEditNodeSpawn() =>
    watch(
        edit.selectedNodeData,
        (SpawnNodeData? value){
          if (value == null) return const SizedBox();
          return Container(
            padding: padding8,
            color: brownLight,
            width: 200,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: text("Amount")),
                    text("-", onPressed: () =>
                        editorActionModifySpawnNode(
                          spawnType: value.spawnType,
                          spawnRadius: value.spawnRadius,
                          spawnAmount: value.spawnAmount - 1,
                        )
                    ),
                    width2,
                    Container(
                      alignment: Alignment.center,
                        width: 60,
                        child: text(value.spawnAmount)),
                    width2,
                    text("+", onPressed: () =>
                        editorActionModifySpawnNode(
                          spawnType: value.spawnType,
                          spawnRadius: value.spawnRadius,
                          spawnAmount: value.spawnAmount + 1,
                        )
                    ),
                  ],
                ),
                height8,
                Row(
                  children: [
                    Expanded(child: text("Radius")),
                    text("-", onPressed: () =>
                        editorActionModifySpawnNode(
                          spawnType: value.spawnType,
                          spawnRadius: value.spawnRadius - 10,
                          spawnAmount: value.spawnAmount,
                        )
                    ),
                    width2,
                    Container(
                        alignment: Alignment.center,
                        width: 60,
                        child: text(value.spawnRadius)),
                    width2,
                    text("+", onPressed: () =>
                        editorActionModifySpawnNode(
                          spawnType: value.spawnType,
                          spawnRadius: value.spawnRadius + 10,
                          spawnAmount: value.spawnAmount,
                        )
                    ),
                  ],
                ),
                height16,
                Container(
                  height: screen.height - 200,
                  child: SingleChildScrollView(
                    child: Column(
                      children: SpawnType.values.map((int spawnType) =>
                          container(
                            color: spawnType == value.spawnType ? colours.blue : Colors.grey,
                            child: SpawnType.getName(spawnType),
                            action: () => editorActionModifySpawnNode(
                               spawnType: spawnType,
                               spawnAmount: value.spawnAmount,
                               spawnRadius: value.spawnRadius,
                            )
                          ),
                      ).toList(),
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );

Widget buildColumnNodeOrientationSolid() =>
    visibleBuilder(
      edit.nodeSupportsSolid,
      buildOrientationIcon(NodeOrientation.Solid),
    );

Widget buildOrientationIcon(int orientation){

  final canvas = buildAtlasImage(
    srcX: mapOrientationToSrcX(orientation),
    srcY: mapOrientationToSrcY(orientation),
    srcWidth: 48,
    srcHeight: 72,
    scale: 0.75,
  );

  return onPressed(
    hint: NodeOrientation.getName(orientation),
    action: (){
      edit.paintOrientation.value = orientation;
      sendClientRequestSetBlock(
          index: edit.nodeIndex.value,
          type: edit.nodeSelectedType.value,
          orientation: orientation,
      );
    },
    child: watch(edit.nodeSelectedOrientation, (int selectedNodeOrientation) {
      return Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          color: selectedNodeOrientation == orientation ? purple3 : brownDark,
          child: canvas
      );
    }),
  );
}

double mapOrientationToSrcX(int orientation){
  if (NodeOrientation.isCorner(orientation)){
    return 7256;
  }
  if (NodeOrientation.isSlopeCornerOuter(orientation)){
    return 7256;
  }
  if (NodeOrientation.isSlopeCornerInner(orientation)){
    return 7256;
  }
 return 7207;
}

double mapOrientationToSrcY(int orientation){
  if (orientation == NodeOrientation.Solid)
    return 0 * 73;
  if (orientation == NodeOrientation.Slope_North)
    return 5 * 73;
  if (orientation == NodeOrientation.Slope_East)
    return 6 * 73;
  if (orientation == NodeOrientation.Slope_South)
    return 7 * 73;
  if (orientation == NodeOrientation.Slope_West)
    return 8 * 73;
  if (orientation == NodeOrientation.Half_North)
    return 1 * 73;
  if (orientation == NodeOrientation.Half_East)
    return 2 * 73;
  if (orientation == NodeOrientation.Half_South)
    return 3 * 73;
  if (orientation == NodeOrientation.Half_West)
    return 4 * 73;
  if (orientation == NodeOrientation.Corner_Top)
    return 0 * 73;
  if (orientation == NodeOrientation.Corner_Right)
    return 1 * 73;
  if (orientation == NodeOrientation.Corner_Bottom)
    return 2 * 73;
  if (orientation == NodeOrientation.Corner_Left)
    return 3 * 73;
  if (orientation == NodeOrientation.Slope_Outer_South_West)
    return 4 * 73;
  if (orientation == NodeOrientation.Slope_Outer_North_West)
    return 5 * 73;
  if (orientation == NodeOrientation.Slope_Outer_North_East)
    return 6 * 73;
  if (orientation == NodeOrientation.Slope_Outer_South_East)
    return 7 * 73;
  if (orientation == NodeOrientation.Slope_Inner_South_East)
    return 8 * 73;
  if (orientation == NodeOrientation.Slope_Inner_North_East)
    return 9 * 73;
  if (orientation == NodeOrientation.Slope_Inner_North_West)
    return 10 * 73;
  if (orientation == NodeOrientation.Slope_Inner_South_West)
    return 11 * 73;
  return 0;
}

Widget buildColumnNodeOrientationSlopeSymmetric() =>
    visibleBuilder(
      edit.nodeSupportsSlopeSymmetric,
      // buildColumnButtonsNodeOrientations(NodeOrientation.valuesSlopeSymmetric),
      Row(
        children: [
           Column(
             children: [
               buildOrientationIcon(NodeOrientation.Slope_South),
               buildOrientationIcon(NodeOrientation.Slope_East),
             ],
           ),
          Column(
            children: [
              buildOrientationIcon(NodeOrientation.Slope_West),
              buildOrientationIcon(NodeOrientation.Slope_North),
            ],
          )
        ],
      ),
    );

Widget buildColumnNodeOrientationCorner() =>
    visibleBuilder(
      edit.nodeSupportsCorner,
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildOrientationIcon(NodeOrientation.Corner_Top),
            Row(
              children: [
                buildOrientationIcon(NodeOrientation.Corner_Left),
                width(48),
                buildOrientationIcon(NodeOrientation.Corner_Right),
              ],
            ),
            buildOrientationIcon(NodeOrientation.Corner_Bottom),
          ],
        )
    );

Widget buildColumnNodeOrientationHalf() =>
    visibleBuilder(
      edit.nodeSupportsHalf,
        Row(
          children: [
            Column(
              children: [
                buildOrientationIcon(NodeOrientation.Half_North),
                buildOrientationIcon(NodeOrientation.Half_West),
              ],
            ),
            Column(
              children: [
                buildOrientationIcon(NodeOrientation.Half_East),
                buildOrientationIcon(NodeOrientation.Half_South),
              ],
            )
          ],
        )
    );

Widget buildColumnNodeOrientationSlopeCornerInner() =>
    visibleBuilder(
      edit.nodeSupportsSlopeCornerInner,
        Row(
          children: [
            Column(
              children: [
                buildOrientationIcon(NodeOrientation.Slope_Inner_North_West),
                buildOrientationIcon(NodeOrientation.Slope_Inner_North_East),
              ],
            ),
            Column(
              children: [
                buildOrientationIcon(NodeOrientation.Slope_Inner_South_West),
                buildOrientationIcon(NodeOrientation.Slope_Inner_South_East),
              ],
            )
          ],
        )
    );

Widget buildColumnNodeOrientationSlopeCornerOuter() =>
    visibleBuilder(
      edit.nodeSupportsSlopeCornerOuter,
        Row(
          children: [
            Column(
              children: [
                buildOrientationIcon(NodeOrientation.Slope_Outer_North_West),
                buildOrientationIcon(NodeOrientation.Slope_Outer_North_East),
              ],
            ),
            Column(
              children: [
                buildOrientationIcon(NodeOrientation.Slope_Outer_South_West),
                buildOrientationIcon(NodeOrientation.Slope_Outer_South_East),
              ],
            )
          ],
        )
    );

Widget buildColumnButtonsNodeOrientations(List<int> orientations) =>
  Column(children: orientations.map(buildOrientationIcon).toList());


Widget buildColumnSelectedGameObject() {

  return watch(edit.gameObjectSelected, (bool gameObjectSelected){

    if (!gameObjectSelected){
      return buildColumnSelectNodeType();
    }

    return Container(
      color: brownLight,
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          watch(edit.gameObjectSelectedType, (int type){
            return Column(
              children: [
                text(GameObjectType.getName(type)),
                if (type == GameObjectType.Particle_Emitter)
                  buildColumnEditParticleEmitter(),
              ],
            );
          }),
        ],
      ),
    );
  });
}

Widget buildColumnEditParticleEmitter(){
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      watch(edit.gameObjectSelectedParticleType, (int particleType) => text("Particle Type: $particleType")),
      watch(edit.gameObjectSelectedParticleSpawnRate, (int rate) => text("Rate: $rate")),
    ],
  );
}

Column buildControlPaint() {
  return Column(
            children: [
              watch(edit.paintType, buildPaintType),
            ],
          );
}

Widget buildPaintType(int type) =>
  container(child: NodeType.getName(type));

Row buildEditorMenu() {
  return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            onMouseOver(
                builder: (context, over) {
                  if (over){
                    return Column(
                      children: [
                        container(child: "File", color: brownLight),
                        container(child: "New", color: brownLight, action: (){
                          core.actions.exitGame();
                          connectToGameEditor();
                        }, hoverColor: brownDark),
                        container(child: "Save", color: brownLight, action: requestSaveScene, hoverColor: brownDark),
                        container(child: "Load", color: brownLight, action: editorLoadScene, hoverColor: brownDark),
                        container(child: "Exit", color: brownLight, action: core.actions.exitGame, hoverColor: brownDark),
                      ],
                    );
                  }
                  return container(child: "File", color: brownLight);
                }
            ),
            onMouseOver(
              builder: (context, over) {
                if (over){
                  return Column(
                    children: [
                      container(child: "Edit", color: brownLight),
                      container(child: "Canvas Size", color: brownLight, hoverColor: brownDark, action: actionGameDialogEditCanvasSizeShow),
                    ],
                  );
                }

                return container(child: "Edit", color: brownLight);
              }
            ),
            buildMenu(
                text: "Insert",
                children: const [
                  GameObjectType.Barrel,
                  GameObjectType.Wheel,
                  GameObjectType.Crystal,
                  GameObjectType.Crystal_Small_Blue,
                  GameObjectType.Lantern_Red,
                  GameObjectType.Tavern_Sign,
                  GameObjectType.Book_Purple,
                  GameObjectType.Bottle,
                  GameObjectType.Candle,
                  GameObjectType.Cup,
                  GameObjectType.Wooden_Shelf_Row,
                  GameObjectType.Rock,
                  GameObjectType.Stick,
                ]
                  .map(buildButtonAddGameObject)
                  .toList(),
            )
          ],
        );
}

Widget buildButtonAddGameObject(int type) {
  return container(
      child: GameObjectType.getName(type),
      color: brownLight,
      action: (){
        sendClientRequestAddGameObjectXYZ(
          x: edit.posX,
          y: edit.posY,
          z: edit.posZ,
          type: type,
        );
      });
}

Widget buildMenu({required String text, required List<Widget> children}){
  final child = container(child: text, color: brownLight);
  return onMouseOver(
      builder: (context, over) {
        if (over){
          return Column(
            children: [
              child,
              Container(
                height: screen.height - 100,
                child: SingleChildScrollView(
                  child: Column(
                     children: children,
                  ),
                ),
              )
            ],
          );
        }
        return child;
      }
  );
}

