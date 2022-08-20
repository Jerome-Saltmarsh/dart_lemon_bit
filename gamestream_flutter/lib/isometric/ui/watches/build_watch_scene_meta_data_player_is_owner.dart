import 'package:bleed_common/library.dart';
import 'package:bleed_common/node_orientation.dart';
import 'package:bleed_common/spawn_type.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/action_show_game_dialog_canvas_size.dart';
import 'package:gamestream_flutter/isometric/classes/node.dart';
import 'package:gamestream_flutter/isometric/edit_state.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_button.dart';
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
        child: buildColumnEditNode(),
      ),
      Positioned(
          bottom: 6,
          left: 0,
          child: buildControlsEnvironment()
      ),
      Positioned(
        left: 0,
        top: 0,
        child: buildTopLeftMenu(),
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
        height8,
        buildColumnNodeOrientationSlopeSymmetric(),
        height8,
        buildColumnNodeOrientationCorner(),
        height8,
        buildColumnNodeOrientationHalf(),
        height8,
        buildColumnNodeOrientationSlopeCornerInner(),
        height8,
        buildColumnNodeOrientationSlopeCornerOuter(),
      ],
    );
  });
}

Widget buildColumnNodeOrientationSolid() =>
    visibleBuilder(
      edit.nodeSupportsSolid,
      onPressed(
        callback: (){
          edit.paintOrientation.value = NodeOrientation.Solid;
          sendNodeRequestOrient(NodeOrientation.Solid);
        },
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          color: brownLight,
          child: buildCanvasImage(
            srcX: 7207,
            srcY: 0,
            srcWidth: 48,
            srcHeight: 72,
          )
        ),
      ),
    );


Widget buildColumnNodeOrientationSlopeSymmetric() =>
    visibleBuilder(
      edit.nodeSupportsSlopeSymmetric,
      buildColumnButtonsNodeOrientations(NodeOrientation.valuesSlopeSymmetric),
    );

Widget buildColumnNodeOrientationCorner() =>
    visibleBuilder(
      edit.nodeSupportsCorner,
      buildColumnButtonsNodeOrientations(NodeOrientation.valuesCorners),
    );

Widget buildColumnNodeOrientationHalf() =>
    visibleBuilder(
      edit.nodeSupportsHalf,
      buildColumnButtonsNodeOrientations(NodeOrientation.valuesHalf),
    );

Widget buildColumnNodeOrientationSlopeCornerInner() =>
    visibleBuilder(
      edit.nodeSupportsSlopeCornerInner,
      buildColumnButtonsNodeOrientations(NodeOrientation.valuesSlopeCornerInner),
    );

Widget buildColumnNodeOrientationSlopeCornerOuter() =>
    visibleBuilder(
      edit.nodeSupportsSlopeCornerOuter,
      buildColumnButtonsNodeOrientations(NodeOrientation.valuesSlopeCornerOuter),
    );

Widget buildColumnButtonsNodeOrientations(List<int> orientations) =>
  Column(children: orientations.map(buildButtonSelectNodeOrientation).toList());

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



Widget buildColumnEditNode() {

  return watch(edit.gameObjectSelected, (bool gameObjectSelected){

    if (!gameObjectSelected){
      return Column(
        children: [
          buildColumnSelected(),
          buildControlPaint(),
          buildWatchEditorTab(),
        ],
      );
    }

    return Container(
      color: brownLight,
      padding: const EdgeInsets.all(6),
      child: watch(edit.gameObjectSelectedType, (int type){
        return Column(
          children: [
            text(GameObjectType.getName(type)),
            if (type == GameObjectType.Spawn)
              watch(edit.gameObjectSelectedSpawnType, (int spawnType){
                return container(
                  child: "Spawns: ${SpawnType.getName(spawnType)}",
                  action: sendGameObjectRequestSpawnTypeIncrement,
                );
              }),
          ],
        );
      }),
    );
  });
}

Column buildColumnSelected() {
  return Column(
            children: [
              container(child: "Selected", color: brownLight),
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
              container(child: "Paint", color: brownLight, toolTip: "Press F to paint. Press R to copy selected type"),
              watch(edit.paintType, buildPaintType),
            ],
          );
}

Widget buildPaintType(int type) =>
  container(child: NodeType.getName(type));

Row buildTopLeftMenu() {
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
                        container(child: "Save", color: brownLight, action: actionGameDialogShowSceneSave, hoverColor: brownDark),
                        container(child: "Load", color: brownLight, action: actionGameDialogShowSceneLoad, hoverColor: brownDark),
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
            onMouseOver(
              builder: (context, over) {
                if (over){
                  return Column(
                    children: [
                      container(child: "View", color: brownLight),
                      container(child: "Weather", color: brownLight, hoverColor: brownDark, action: edit.actionToggleControlsVisibleWeather),
                      container(child: "Grid", color: brownLight, hoverColor: brownDark),
                    ],
                  );
                }
                return container(child: "View", color: brownLight);
              }
            ),
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
        sendClientRequestAddGameObject(
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

