import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/spawn_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_show_game_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/editor/actions/save_scene.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stacks_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/modules/core/actions.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/screen.dart';

import '../widgets/build_container.dart';

Widget buildPlayMode(Mode mode) {
  return mode == Mode.Play ? buildStackPlay() : buildStackEdit();
}

Stack buildStackEdit() {
  return Stack(
    children: [
      Positioned(
        right: 6,
        top: 80,
        child: buildColumnEditNodeOrientation(),
      ),
      Positioned(
        left: 0,
        bottom: 6,
        child: buildColumnSelectedGameObject(),
      ),
      Positioned(
        left: 200,
        top: 56,
        child: buildColumnSelectedNode(),
      ),
      Positioned(
          bottom: 6,
          left: 0,
          child: buildControlsEnvironment()
      ),
      Positioned(
        left: 0,
        top: 0,
        child: buildEditorMenu(),
      ),
    ],
  );
}

Widget buildColumnEditNodeOrientation() {
  return watch(edit.gameObjectSelected, (bool gameObjectSelected){
    if (gameObjectSelected) return const SizedBox();
    return Column(
      children: [
        buildColumnNodeOrientationSolid(),
        buildColumnNodeOrientationSlopeSymmetric(),
        buildColumnNodeOrientationCorner(),
        buildColumnNodeOrientationHalf(),
        buildColumnNodeOrientationSlopeCornerInner(),
        buildColumnNodeOrientationSlopeCornerOuter(),
      ],
    );
  });
}

Widget buildColumnNodeOrientationSolid() =>
    visibleBuilder(
      edit.nodeSupportsSolid,
      buildOrientationIcon(NodeOrientation.Solid),
    );

Widget buildOrientationIcon(int orientation){

  final canvas = buildCanvasImage(
    srcX: mapOrientationToSrcX(orientation),
    srcY: mapOrientationToSrcY(orientation),
    srcWidth: 48,
    srcHeight: 72,
    scale: 0.75,
  );

  return onPressed(
    hint: NodeOrientation.getName(orientation),
    callback: (){
      edit.paintOrientation.value = orientation;
      sendNodeRequestOrient(orientation);
    },
    child: watch(edit.selectedNode, (Node selectedNode){
      return Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          color: selectedNode.orientation == orientation ? purple3 : brownDark,
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
  // Column(children: orientations.map(buildButtonSelectNodeOrientation).toList());

Widget buildButtonSelectNodeOrientation(int value) {
  return watch(edit.selectedNode, (Node selectedNode) {
    return container(
      color: value == selectedNode.orientation ? brownDark : brownLight,
      child: NodeOrientation.getName(value),
      action: () {
        edit.paintOrientation.value = value;
        sendNodeRequestOrient(value);
      },
    );
  });
}



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
                if (type == GameObjectType.Spawn)
                  watch(edit.gameObjectSelectedSpawnType, (int spawnType){
                    return Column(
                      children: [
                        container (
                          child: "Spawns: ${SpawnType.getName(spawnType)}",
                          action: sendGameObjectRequestSpawnTypeIncrement,
                        ),
                        watch (edit.gameObjectSelectedRadius, (double radius){
                          return Row(
                            children: [
                              container(
                                width: 50,
                                height: 50,
                                child: '-',
                                action: radius <= 1 ? null : () =>
                                    sendGameObjectRequestSetSpawnRadius(
                                        radius - 5
                                    ),
                              ),
                              container(
                                child: "Radius: ${radius.toStringAsFixed(1)}"
                              ),
                              container(
                                width: 50,
                                height: 50,
                                child: '+',
                                action: () => sendGameObjectRequestSetSpawnRadius(
                                          radius + 5
                                ),
                              )
                            ],
                          );
                        }),
                        watch (edit.gameObjectSelectedAmount, (int amount) =>
                          Row(
                            children: [
                              container(
                                width: 50,
                                height: 50,
                                child: '-',
                                action: amount <= 1 ? null : () =>
                                    sendGameObjectRequestSetSpawnAmount(
                                        amount - 1
                                    ),
                              ),
                              container (
                                child: "Amount: $amount",
                                action: sendGameObjectRequestSpawnTypeIncrement,
                              ),
                              container(
                                width: 50,
                                height: 50,
                                child: '+',
                                action: amount >= 256 ? null : () =>
                                    sendGameObjectRequestSetSpawnAmount(
                                        amount + 1
                                    ),
                              ),
                            ],
                          )
                        ),
                      ],
                    );
                  }),
              ],
            );
          }),
        ],
      ),
    );
  });
}

Column buildColumnSelected() {
  return Column(
            children: [
              container(
                 child: Row(
                   children: [
                     container(child: "-", width: 50, action: ()=> edit.z.value--, toolTip: "Shift + Down Arrow"),
                     watch(edit.z, (t) {
                       return container(child: 'Z: $t', width: 92);
                     }),
                     container(child: "+", width: 50, action: ()=> edit.z.value++, toolTip: "Shift + Up Arrow"),
                   ],
                 )
              ),
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
                      container(child: "Floor Bricks", color: brownLight, hoverColor: brownDark, action: edit.paintFloorBricks),
                    ],
                  );
                }

                return container(child: "Edit", color: brownLight);
              }
            ),
            // onMouseOver(
            //   builder: (context, over) {
            //     if (over){
            //       return Column(
            //         children: [
            //           container(child: "View", color: brownLight),
            //           container(child: "Weather", color: brownLight, hoverColor: brownDark, action: edit.actionToggleControlsVisibleWeather),
            //           container(child: "Grid", color: brownLight, hoverColor: brownDark),
            //         ],
            //       );
            //     }
            //     return container(child: "View", color: brownLight);
            //   }
            // ),
            buildMenu(
                text: "Insert",
                children: GameObjectType.staticValues
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

