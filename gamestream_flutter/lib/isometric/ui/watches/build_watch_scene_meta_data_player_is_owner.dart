import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_map_editor.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_atlas_image.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/library.dart';

import '../stacks/build_page.dart';
import '../widgets/build_container.dart';

Widget buildPlayMode(bool edit) =>
  edit ? watch(GameEditor.editTab, buildStackEdit) : buildStackPlay();

Widget buildStackEdit(EditTab activeEditTab) =>
    buildPage(
    children: [
      watch(GameEditor.editorDialog, buildWatchEditorDialog),
      if (activeEditTab == EditTab.Grid)
      Positioned(
        right: 6,
        top: 80,
        child: buildWatchBool(
            GameEditor.nodeOrientationVisible,
            buildColumnEditNodeOrientation
        ),
      ),
      if (activeEditTab == EditTab.Objects)
        Positioned(
          left: 0,
          bottom: 6,
          child: buildColumnSelectedGameObject(),
        ),
      if (activeEditTab == EditTab.Objects)
        Positioned(
          left: 0,
          top: 50,
          child: container(child: 'Spawn Zombie', action: (){
            GameNetwork.sendClientRequestEdit(EditRequest.Spawn_Zombie, GameEditor.nodeIndex.value);
          }),
        ),
      if (activeEditTab == EditTab.Grid)
        Positioned(
          left: 0,
          top: 50,
          child: buildColumnSelectNodeType(),
        ),
      if (activeEditTab == EditTab.Grid)
        Positioned(
          left: 200,
          top: 56,
          child: buildEditorSelectedNode(),
        ),
      if (activeEditTab == EditTab.Weather)
        Positioned(
            bottom: 6,
            left: 0,
            child: Container(
              width: Engine.screen.width,
              alignment: Alignment.center,
              child: buildWatchBool(
                GameEditor.controlsVisibleWeather,
                  buildControlsWeather,
              ),
            )
        ),
      if (activeEditTab == EditTab.File)
        Positioned(
            top: 50,
            left: 0,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   container(child: "SAVE", action: GameEditor.actionGameDialogShowSceneSave),
                   container(child: "LOAD", action: GameEditor.editorLoadScene),
                   height16,
                   text("MAP SIZE"),
                  ...RequestModifyCanvasSize.values.map((e) => container(
                     child: e.name, action: () => GameNetwork.sendClientRequestModifyCanvasSize(e)
                  )).toList(),
                ],
              ),
            )
        ),
      // Positioned(
      //   left: 0,
      //   top: 0,
      //   child: Container(
      //       child: watch(game.editTab, buildEditorMenu),
      //       width: screen.width,
      //       height: screen.height,
      //   ),
      // ),
      Positioned(
        left: 0,
        top: 0,
        child: buildEditorMenu(activeEditTab),
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

Widget buildColumnNodeOrientationSolid() =>
    visibleBuilder(
      GameEditor.nodeSupportsSolid,
      buildOrientationIcon(NodeOrientation.Solid),
    );

Widget buildOrientationIcon(int orientation){
  final canvas = buildAtlasImage(
    image: GameImages.atlasNodes,
    srcX: mapOrientationToSrcX(orientation),
    srcY: AtlasNodeY.mapOrientation(orientation),
    srcWidth: 48,
    srcHeight: 72,
    scale: 0.75,
  );

  return onPressed(
    hint: NodeOrientation.getName(orientation),
    action: (){
      GameEditor.paintOrientation.value = orientation;
      GameNetwork.sendClientRequestSetBlock(
          index: GameEditor.nodeIndex.value,
          type: GameEditor.nodeSelectedType.value,
          orientation: orientation,
      );
    },
    child: watch(GameEditor.nodeSelectedOrientation, (int selectedNodeOrientation) {
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

double mapOrientationToSrcX(int orientation) {
  if (NodeOrientation.isCorner(orientation)){
    return AtlasNodeX.Orientation_Corner;
  }
  if (NodeOrientation.isSlopeCornerOuter(orientation)){
    return AtlasNodeX.Orientation_Slope_Outer;
  }
  if (NodeOrientation.isSlopeCornerInner(orientation)){
    return AtlasNodeX.Orientation_Slope_Inner;
  }
  if (NodeOrientation.isHalf(orientation)){
    return AtlasNodeX.Orientation_Half;
  }
  if (NodeOrientation.isSlopeSymmetric(orientation)){
    return AtlasNodeX.Orientation_Slope_Symmetric;
  }
  throw Exception('mapOrientationToSrcX(${NodeOrientation.getName(orientation)}');
}


Widget buildColumnNodeOrientationSlopeSymmetric() =>
    visibleBuilder(
      GameEditor.nodeSupportsSlopeSymmetric,
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
        GameEditor.nodeSupportsCorner,
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
        GameEditor.nodeSupportsHalf,
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
        GameEditor.nodeSupportsSlopeCornerInner,
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
        GameEditor.nodeSupportsSlopeCornerOuter,
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

  return watch(GameEditor.gameObjectSelected, (bool gameObjectSelected){

    return Container(
      color: brownLight,
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          watch(GameEditor.gameObjectSelectedType, (int type){
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
      watch(GameEditor.gameObjectSelectedParticleType, (int particleType) => text("Particle Type: $particleType")),
      watch(GameEditor.gameObjectSelectedParticleSpawnRate, (int rate) => text("Rate: $rate")),
    ],
  );
}

Column buildControlPaint() {
  return Column(
            children: [
              watch(GameEditor.paintType, buildPaintType),
            ],
          );
}

Widget buildPaintType(int type) =>
  container(child: NodeType.getName(type));


enum EditTab {
  File,
  Grid,
  Objects,
  Player,
  Weather,
}

Row buildEditorMenu(EditTab activeEditTab) =>
  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: EditTab.values.map(
                  (editTab) => container(
                            child: editTab.name,
                            width: 150,
                            color: activeEditTab == editTab
                                ? GameColors.brownDark
                                : GameColors.brownLight,
                            action: () => GameEditor.editTab.value = editTab,
                         )
          ).toList(),
        );

Widget buildButtonAddGameObject(int type) {
  return container(
      child: GameObjectType.getName(type),
      color: brownLight,
      action: (){
        GameNetwork.sendClientRequestAddGameObjectXYZ(
          x: GameEditor.posX,
          y: GameEditor.posY,
          z: GameEditor.posZ,
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
                height: Engine.screen.height - 100,
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

