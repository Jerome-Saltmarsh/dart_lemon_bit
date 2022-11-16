import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_page.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';

import 'editor_enums.dart';

class EditorUI {
  static Widget buildRowWeatherControls() => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildControlTime(),
          width2,
          buildRowRainIcons(),
          width2,
          buildRowLightningIcons(),
          width2,
          buildRowWindIcons(),
          width2,
          text("Save", onPressed: ServerActions.saveScene),
          width2,
        ],
      );

  static Widget buildIconWeatherControl({
    required String tooltip,
    required Function action,
    required Widget icon,
    required bool isActive,
  }) =>
      Tooltip(
        message: tooltip,
        child: Stack(
          children: [
            onPressed(
              action: isActive ? null : action,
              child: icon,
            ),
            if (isActive)
              Container(
                width: 64,
                height: 64,
                decoration: GameUI.buildDecorationBorder(
                  colorBorder: Colors.white,
                  colorFill: Colors.transparent,
                  width: 2,
                  borderRadius: 0,
                ),
              ),
          ],
        ),
      );

  static Widget buildIconRain(Rain rain) => watch(
      ServerState.rain,
      (Rain activeRain) => buildIconWeatherControl(
            tooltip: '${rain.name} Rain',
            action: () => GameNetwork.sendClientRequestWeatherSetRain(rain),
            icon: GameUI.buildAtlasIconType(convertRainToIconType(rain),
                size: 64),
            isActive: rain == activeRain,
          ));

  static Widget buildIconLightning(Lightning lightning) => watch(
      ServerState.lightning,
      (Lightning activeLightning) => buildIconWeatherControl(
            tooltip: '${lightning.name} Lightning',
            action: () =>
                GameNetwork.sendClientRequestWeatherSetLightning(lightning),
            icon: GameUI.buildAtlasIconType(
                convertLightningToIconType(lightning),
                size: 64),
            isActive: lightning == activeLightning,
          ));

  static Widget buildIconWind(Wind wind) => watch(
      ServerState.windAmbient,
      (Wind active) => buildIconWeatherControl(
            tooltip: '${wind.name} Wind',
            action: () => GameNetwork.sendClientRequestWeatherSetWind(wind),
            icon: GameUI.buildAtlasIconType(convertWindToIconType(wind),
                size: 64),
            isActive: wind == active,
          ));

  static int convertRainToIconType(Rain rain) {
    switch (rain) {
      case Rain.None:
        return IconType.Rain_None;
      case Rain.Light:
        return IconType.Rain_Light;
      case Rain.Heavy:
        return IconType.Rain_Heavy;
    }
  }

  static int convertLightningToIconType(Lightning lightning) {
    switch (lightning) {
      case Lightning.Off:
        return IconType.Lightning_Off;
      case Lightning.Nearby:
        return IconType.Lightning_Nearby;
      case Lightning.On:
        return IconType.Lightning_On;
    }
  }

  static int convertWindToIconType(Wind wind) {
    switch (wind) {
      case Wind.Calm:
        return IconType.Wind_Calm;
      case Wind.Gentle:
        return IconType.Wind_Gentle;
      case Wind.Strong:
        return IconType.Wind_Strong;
    }
  }

  static Widget buildRowRainIcons() =>
      Row(children: Rain.values.map(buildIconRain).toList());

  static Widget buildRowLightningIcons() =>
      Row(children: Lightning.values.map(buildIconLightning).toList());

  static Widget buildRowWindIcons() =>
      Row(children: Wind.values.map(buildIconWind).toList());

  static String convertHourToString(int hour) {
    if (hour < 0) return 'invalid time';
    if (hour == 0) return 'midnight';
    if (hour < 3) return 'night';
    if (hour < 6) return 'early morning';
    if (hour < 10) return 'morning';
    if (hour < 12) return 'late morning';
    if (hour == 12) return 'midday';
    if (hour < 15) return 'afternoon';
    if (hour < 17) return 'late afternoon';
    if (hour < 19) return 'evening';
    return 'night';
  }

  static Widget buildControlTime() {
    const totalWidth = 300.0;
    const buttonWidth = totalWidth / 24.0;
    final buttons = watch(ServerState.hours, (int hours) {
      final buttons1 = <Widget>[];
      final buttons2 = <Widget>[];

      for (var i = 0; i <= hours; i++) {
        buttons1.add(
          Tooltip(
            message: '$i - ${convertHourToString(i)}',
            child: container(
              width: buttonWidth,
              color: purple4,
              action: () => GameNetwork.sendClientRequestTimeSetHour(i),
            ),
          ),
        );
      }
      for (var i = hours + 1; i < 24; i++) {
        buttons2.add(
          Tooltip(
            message: '$i - ${convertHourToString(i)}',
            child: container(
              width: buttonWidth,
              color: purple3,
              action: () => GameNetwork.sendClientRequestTimeSetHour(i),
            ),
          ),
        );
      }

      return Row(
        children: [
          ...buttons1,
          ...buttons2,
        ],
      );
    });

    final timeText = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        watch(ServerState.hours, (num hour) => text(padZero(hour))),
        text(":"),
        watch(ServerState.minutes, (num hour) => text(padZero(hour))),
      ],
    );
    return Container(
      child: Row(
        children: [
          Container(
              color: brownLight,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  timeText,
                ],
              )),
          buttons,
        ],
      ),
    );
  }

  // static Widget buildIconNodeType(int nodeType) =>
  //     Engine.buildAtlasImage(
  //       image: GameImages.atlasNodes,
  //       srcX: AtlasNodeX.mapNodeType(nodeType),
  //       srcY: AtlasNodeY.mapNodeType(nodeType),
  //       srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
  //       srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
  //     );

  static Widget buildButtonSelectNodeType(int nodeType) {
    final canvas = Engine.buildAtlasImage(
      image: GameImages.atlasNodes,
      srcX: AtlasNodeX.mapNodeType(nodeType),
      srcY: AtlasNodeY.mapNodeType(nodeType),
      srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
      srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
    );
    return WatchBuilder(GameEditor.nodeSelectedType, (int selectedNodeType) {
      return container(
          height: 78,
          width: 78,
          alignment: Alignment.center,
          child: Tooltip(
            child: canvas,
            message: NodeType.getName(nodeType),
          ),
          action: () {
            if (GameState.playMode) {
              GameActions.actionSetModePlay();
              return;
            }
            GameEditor.paint(nodeType: nodeType);
          },
          color: selectedNodeType == nodeType ? greyDark : grey);
    });
  }

  static Widget buildStackEdit(EditTab activeEditTab) => buildPage(
        children: [
          watch(GameEditor.editorDialog, buildWatchEditorDialog),
          if (activeEditTab == EditTab.Objects)
            Positioned(
              left: 0,
              bottom: 6,
              child: buildColumnSelectedGameObject(),
            ),
          buildWindowAIControls(),
          if (activeEditTab == EditTab.Objects)
            Positioned(
              left: 0,
              top: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  container(
                      child: 'Spawn Zombie',
                      action: () {
                        GameNetwork.sendClientRequestEdit(
                            EditRequest.Spawn_Zombie,
                            GameEditor.nodeSelectedIndex.value);
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
                            )),
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
                  watch(
                      GameEditor.nodeSelectedType,
                      (int selectedNodeType) => Row(
                            children: [
                              if (NodeType.supportsOrientationEmpty(
                                  selectedNodeType))
                                buildOrientationIcon(NodeOrientation.None),
                              if (NodeType.supportsOrientationSolid(
                                  selectedNodeType))
                                buildOrientationIcon(NodeOrientation.Solid),
                              if (NodeType.supportsOrientationHalf(
                                  selectedNodeType))
                                buildOrientationIcon(NodeOrientation.Half_East),
                              if (NodeType.supportsOrientationCorner(
                                  selectedNodeType))
                                buildOrientationIcon(
                                    NodeOrientation.Corner_Top),
                              if (NodeType.supportsOrientationSlopeSymmetric(
                                  selectedNodeType))
                                buildOrientationIcon(
                                    NodeOrientation.Slope_East),
                              if (NodeType.supportsOrientationSlopeCornerInner(
                                  selectedNodeType))
                                buildOrientationIcon(
                                  NodeOrientation.Slope_Inner_North_East,
                                ),
                              if (NodeType.supportsOrientationSlopeCornerOuter(
                                  selectedNodeType))
                                buildOrientationIcon(
                                  NodeOrientation.Slope_Outer_North_East,
                                ),
                            ],
                          )),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEditorSelectedNode(),
                      watch(GameEditor.nodeSelectedOrientation,
                          buildColumnEditNodeOrientation),
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
                      container(
                          child: "SAVE",
                          action: GameEditor.actionGameDialogShowSceneSave),
                      container(
                          child: "LOAD", action: GameEditor.editorLoadScene),
                      height16,
                      text("MAP SIZE"),
                      ...RequestModifyCanvasSize.values
                          .map((e) => container(
                              child: e.name,
                              action: () =>
                                  GameNetwork.sendClientRequestModifyCanvasSize(
                                      e)))
                          .toList(),
                    ],
                  ),
                )),
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

  static Widget buildColumnEditNodeOrientation(int selectedNodeOrientation) =>
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

  static Positioned buildWindowAIControls() {
    return Positioned(
      top: 70,
      right: 70,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: GameColors.brown02,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text("Spawn AI", onPressed: ServerActions.editSceneSpawnAI),
            text("Clear Spawned AI",
                onPressed: ServerActions.editSceneClearSpawnedAI),
            text("Pause AI", onPressed: ServerActions.editSceneClearSpawnedAI),
          ],
        ),
      ),
    );
  }

  static Widget buildColumnNodeOrientationSolid() =>
      buildOrientationIcon(NodeOrientation.Solid);

  static Widget buildOrientationIcon(int orientation) {
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
      action: () {
        GameEditor.paintOrientation.value = orientation;
        GameNetwork.sendClientRequestSetBlock(
          index: GameEditor.nodeSelectedIndex.value,
          type: GameEditor.nodeSelectedType.value,
          orientation: orientation,
        );
      },
      child: watch(GameEditor.nodeSelectedOrientation,
          (int selectedNodeOrientation) {
        return Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            color: selectedNodeOrientation == orientation ? purple3 : brownDark,
            child: canvas);
      }),
    );
  }

  static Widget buildColumnNodeOrientationSlopeSymmetric() => Row(
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

  static Widget buildColumnNodeOrientationCorner() => Column(
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

  static Widget buildColumnNodeOrientationHalf() => Row(
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

  static Widget buildColumnNodeOrientationSlopeCornerInner() => Row(
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

  static Widget buildColumnNodeOrientationSlopeCornerOuter() => Row(
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

  static Widget buildColumnSelectedGameObject() {
    return watch(GameEditor.gameObjectSelected, (bool gameObjectSelected) {
      return Container(
        color: brownLight,
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            watch(GameEditor.gameObjectSelectedType, (int type) {
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

  static Widget buildColumnEditParticleEmitter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        watch(GameEditor.gameObjectSelectedParticleType,
            (int particleType) => text("Particle Type: $particleType")),
        watch(GameEditor.gameObjectSelectedParticleSpawnRate,
            (int rate) => text("Rate: $rate")),
      ],
    );
  }

  static Column buildControlPaint() {
    return Column(
      children: [
        watch(GameEditor.paintType, buildPaintType),
      ],
    );
  }

  static Widget buildPaintType(int type) =>
      container(child: NodeType.getName(type));

  static Row buildEditorMenu(EditTab activeEditTab) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: EditTab.values
            .map((editTab) => container(
                  child: editTab.name,
                  width: 150,
                  color: activeEditTab == editTab
                      ? GameColors.brownDark
                      : GameColors.brownLight,
                  action: () => GameEditor.editTab.value = editTab,
                ))
            .toList(),
      );

  static Widget buildMenu(
      {required String text, required List<Widget> children}) {
    final child = container(child: text, color: brownLight);
    return onMouseOver(builder: (context, over) {
      if (over) {
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
    });
  }
}
