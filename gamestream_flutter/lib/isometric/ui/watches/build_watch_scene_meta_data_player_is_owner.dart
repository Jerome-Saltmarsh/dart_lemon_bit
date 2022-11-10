import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/library.dart';

import '../stacks/build_page.dart';
import '../widgets/build_container.dart';



Widget buildStackEdit(EditTab activeEditTab) =>
    buildPage(
    children: [
      watch(GameEditor.editorDialog, buildWatchEditorDialog),
      // if (activeEditTab == EditTab.Grid)
      // Positioned(
      //   right: 6,
      //   top: 50,
      //   child: watch(GameEditor.nodeSelectedOrientation, buildColumnEditNodeOrientation),
      // ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              container(child: 'Spawn Zombie', action: (){
                GameNetwork.sendClientRequestEdit(EditRequest.Spawn_Zombie, GameEditor.nodeSelectedIndex.value);
              }),
              Container(
                width: 100,
                height: 100,
                color: Colors.white,
                child: Engine.buildAtlasImageButton(
                    image: GameImages.gameobjects,
                    srcX: AtlasGameObjects.Crystal_Large_X,
                    srcY: AtlasGameObjects.Crystal_Large_Y,
                    srcWidth: AtlasGameObjects.Crystal_Large_Width,
                    srcHeight: AtlasGameObjects.Crystal_Large_Height,
                    action: () =>
                        GameNetwork.sendClientRequestAddGameObject(
                            index: GameEditor.nodeSelectedIndex.value,
                            type: ItemType.GameObjects_Crystal,
                        )
                ),
              ),
            ],
          ),
        ),
      if (activeEditTab == EditTab.Grid)
        Positioned(
          left: 0,
          top: 50,
          child: buildColumnSelectNodeType(),
        ),
      if (activeEditTab == EditTab.Grid)
        Positioned(
          left: 160,
          top: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              watch(GameEditor.nodeSelectedType, (int selectedNodeType) => Row(
                children: [
                  if (NodeType.supportsOrientationEmpty(selectedNodeType))
                    buildOrientationIcon(NodeOrientation.None),
                  if (NodeType.supportsOrientationSolid(selectedNodeType))
                    buildOrientationIcon(NodeOrientation.Solid),
                  if (NodeType.supportsOrientationHalf(selectedNodeType))
                    buildOrientationIcon(NodeOrientation.Half_East),
                  if (NodeType.supportsOrientationCorner(selectedNodeType))
                    buildOrientationIcon(NodeOrientation.Corner_Top),
                  if (NodeType.supportsOrientationSlopeSymmetric(selectedNodeType))
                    buildOrientationIcon(NodeOrientation.Slope_East),
                  if (NodeType.supportsOrientationSlopeCornerInner(selectedNodeType))
                    buildOrientationIcon(
                      NodeOrientation.Slope_Inner_North_East,
                    ),
                  if (NodeType.supportsOrientationSlopeCornerOuter(selectedNodeType))
                    buildOrientationIcon(
                      NodeOrientation.Slope_Outer_North_East,
                    ),
                ],
              )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildEditorSelectedNode(),
                  watch(GameEditor.nodeSelectedOrientation, buildColumnEditNodeOrientation),
                ],
              ),
              // height8,
              // watch(GameEditor.nodeSelectedOrientation, buildColumnEditNodeOrientation),
              ],
            ),
        ),
      // if (activeEditTab == EditTab.Weather)
      //   Positioned(
      //       bottom: 6,
      //       left: 0,
      //       child: Container(
      //         width: Engine.screen.width,
      //         alignment: Alignment.center,
      //         child: buildWatchBool(
      //           GameEditor.controlsVisibleWeather,
      //           EditorUI.buildControlsWeather,
      //         ),
      //       )
      //   ),
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

Widget buildColumnEditNodeOrientation(int selectedNodeOrientation) =>
    Column(
      children: [
        if (NodeOrientation.isSlopeSymmetric(selectedNodeOrientation))
          buildColumnNodeOrientationSlopeSymmetric(),
        if (NodeOrientation.isCorner(selectedNodeOrientation))
          buildColumnNodeOrientationCorner(),
        if (NodeOrientation.isHalf(selectedNodeOrientation))
          buildColumnNodeOrientationHalf(),
        if (NodeOrientation.isSlopeCornerInner(selectedNodeOrientation))
          buildColumnNodeOrientationSlopeCornerInner(),
        if (NodeOrientation.isSlopeCornerOuter(selectedNodeOrientation))
          buildColumnNodeOrientationSlopeCornerOuter(),
      ],
    );

Widget buildColumnNodeOrientationSolid() =>
    buildOrientationIcon(NodeOrientation.Solid);

Widget buildOrientationIcon(int orientation){
  final canvas = Engine.buildAtlasImage(
    image: GameImages.atlasNodes,
    srcX: AtlasNodeX.mapOrientation(orientation),
    srcY: AtlasNodeY.mapOrientation(orientation),
    srcWidth: GameConstants.Sprite_Width,
    srcHeight: GameConstants.Sprite_Height,
    scale: 0.75,
  );

  return onPressed(
    hint: NodeOrientation.getName(orientation),
    action: (){
      GameEditor.paintOrientation.value = orientation;
      GameNetwork.sendClientRequestSetBlock(
          index: GameEditor.nodeSelectedIndex.value,
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

Widget buildColumnNodeOrientationSlopeSymmetric() =>
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
    );

Widget buildColumnNodeOrientationCorner() =>
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
    );


Widget buildColumnNodeOrientationHalf() =>
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
    );


Widget buildColumnNodeOrientationSlopeCornerInner() =>
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
    );

Widget buildColumnNodeOrientationSlopeCornerOuter() =>
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
    );


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
                text(ItemType.getName(type)),
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
  // Player,
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

