import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_page.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_tab.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';

class EditorUI {

  static Widget buildUI(EditTab activeEditTab) => buildPage(
    children: [
      watch(GameEditor.editorDialog, buildWatchEditorDialog),
      Positioned(
          bottom: 10,
          child: Container(
              alignment: Alignment.center,
              width: Engine.screen.width,
              child: EditorUI.buildRowWeatherControls()
          )
      ),
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
          child: buildColumnObjects(),
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
            ],
          ),
        ),
      if (activeEditTab == EditTab.File)
        Positioned(
            top: 50,
            left: 0,
            child: Container(
              alignment: Alignment.center,
              child: buildColumnFile(),
            )),
      Positioned(
        left: 0,
        top: 0,
        child: buildEditorMenu(activeEditTab),
      ),
      buildWatchBool(EditorState.windowEnabledScene, buildWindowEditScene),
      buildWatchBool(EditorState.windowEnabledCanvasSize, buildWindowEditCanvasSize),
      buildWatchBool(EditorState.windowEnabledGenerate, buildWindowGenerateScene),
    ],
  );

  static Column buildColumnFile() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                container(child: "DOWNLOAD", action: EditorActions.downloadScene),
                container(child: "UPLOAD", action: EditorActions.uploadScene),
                container(child: "EDIT", action: EditorActions.toggleWindowEnabledScene),
                container(child: "MAP SIZE", action: EditorActions.toggleWindowEnabledCanvasSize),
                container(child: "GENERATE", action: EditorState.windowEnabledGenerate.toggle),
                container(child: "SAVE", action: ServerActions.saveScene),
              ],
            );
  }

  static Widget buildWindowEditCanvasSize() => Center(
    child: GameUI.buildDialogUIControl(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 520,
        color: GameColors.brownLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 text("CANVAS SIZE"),
                 text("Close", onPressed: EditorActions.toggleWindowEnabledCanvasSize),
               ],
            ),
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    Engine.buildAtlasImage(
                      image: GameImages.atlasIcons,
                      srcX: 193,
                      srcY: 32,
                      srcWidth: 96,
                      srcHeight: 96,
                      scale: 2.0,
                    ),
                    buildPositionedIconButton(
                       top: 0,
                       left: 0,
                       action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Row_Start),
                       iconType: IconType.Plus,
                       hint: "Add Row",
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 40,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Row_Start),
                      iconType: IconType.Minus,
                      hint: "Remove Row",
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 150,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Column_Start),
                      iconType: IconType.Plus,
                      hint: "Add Column",
                    ),
                    buildPositionedIconButton(
                      top: 20,
                      left: 160,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Column_Start),
                      iconType: IconType.Minus,
                      hint: "Remove Column",
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 120,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Row_End),
                      iconType: IconType.Minus,
                      hint: "Remove Row",
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 160,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Row_End),
                      iconType: IconType.Plus,
                      hint: "Add Row",
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 0,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Column_End),
                      iconType: IconType.Plus,
                      hint: "Add Column",
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 40,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Column_End),
                      iconType: IconType.Minus,
                      hint: "Remove Column",
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 60,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Z),
                      iconType: IconType.Plus,
                      hint: "Add Z",
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 100,
                      action: () => GameNetwork.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Z),
                      iconType: IconType.Minus,
                      hint: "Remove Z",
                    ),
                  ],
                ),
              ),
            ),
            // Container(
            //   height: 450,
            //   child: SingleChildScrollView(
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: RequestModifyCanvasSize.values
            //         .map((e) => container(
            //                         child: e.name,
            //                         action: () => GameNetwork.sendClientRequestModifyCanvasSize(e)
            //                     )
            //         )
            //     .toList(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    ),
  );

  static Widget buildWindowGenerateScene() => Center(
    child: GameUI.buildDialogUIControl(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 520,
        color: GameColors.brownLight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("Generate"),
                text("Close", onPressed: EditorState.windowEnabledGenerate.toggle),
              ],
            ),
            height32,
            buildRowGenerate(EditorState.generateRows, "Rows"),
            buildRowGenerate(EditorState.generateColumns, "Columns"),
            buildRowGenerate(EditorState.generateHeight, "Height"),
            buildRowGenerate(EditorState.generateOctaves, "Octaves"),
            buildRowGenerate(EditorState.generateFrequency, "Frequency"),
            height16,
            container(child: "Generate", action: EditorActions.generateScene, color: GameColors.blue, alignment: Alignment.center),
          ],
        ),
      ),
    ),
  );

  static Widget buildRowGenerate(WatchInt value, String name) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(child: text(name), alignment: Alignment.centerLeft, width: 100),
            watch(value, text),
          ],
        ),
        Row(
          children: [
            container(child: "-", width: 50, action: value.decrement, alignment: Alignment.center),
            width6,
            container(child: "+", width: 50, action: value.increment, alignment: Alignment.center),
          ],
        ),
      ],
    );


  static Widget buildWindowEditScene()=> Center(
       child: GameUI.buildDialogUIControl(
         child: Container(
            padding: const EdgeInsets.all(10),
            width: 400,
            height: 300,
            color: GameColors.brownLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Edit Scene"),
                    text("Close", onPressed: EditorActions.toggleWindowEnabledScene),
                  ],
                ),
                height16,
                onPressed(
                  action: GameNetwork.sendClientRequestEditSceneToggleUnderground,
                  child: Container(
                    color: Colors.white12,
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        text("Underground"),
                        watch(ServerState.sceneUnderground, text),
                      ],
                    ),
                  ),
                ),
                height8,
                onPressed(
                  action: GameNetwork.sendClientRequestEditSceneSetFloorTypeStone,
                  child: Container(
                    color: Colors.white12,
                    padding: const EdgeInsets.all(5),
                    child: text("Set Floor Stone"),
                  ),
                ),
              ],
            ),
         ),
       ),
     );

  static Widget buildColumnObjects() => Column(
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
        );


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

  static Widget buildIconRain(int rain) => watch(
      ServerState.rainType,
      (int activeRain) => buildIconWeatherControl(
            tooltip: '${RainType.getName(rain)} Rain',
            action: () => GameNetwork.sendClientRequestWeatherSetRain(rain),
            icon: GameUI.buildAtlasIconType(convertRainToIconType(rain),
                size: 64),
            isActive: rain == activeRain,
          ));

  static Widget buildIconLightning(int lightning) => watch(
      ServerState.lightningType,
      (int activeLightning) => buildIconWeatherControl(
            tooltip: '${LightningType.getName(lightning)} Lightning',
            action: () =>
                GameNetwork.sendClientRequestWeatherSetLightning(lightning),
            icon: GameUI.buildAtlasIconType(
                convertLightningToIconType(lightning),
                size: 64),
            isActive: lightning == activeLightning,
          ));

  static Widget buildIconWind(int windType) => watch(
      ServerState.windTypeAmbient,
      (int activeWindType) => buildIconWeatherControl(
            tooltip: '${WindType.getName(windType)} Wind',
            action: () => GameNetwork.sendClientRequestWeatherSetWind(windType),
            icon: GameUI.buildAtlasIconType(convertWindToIconType(windType),
                size: 64),
            isActive: windType == activeWindType,
          ));

  static int convertRainToIconType(int rain) {
    switch (rain) {
      case RainType.None:
        return IconType.Rain_None;
      case RainType.Light:
        return IconType.Rain_Light;
      case RainType.Heavy:
        return IconType.Rain_Heavy;
      default:
        throw Exception('EditorUi.convertRainToIconType($rain)');
    }
  }

  static int convertLightningToIconType(int lightning) {
    switch (lightning) {
      case LightningType.Off:
        return IconType.Lightning_Off;
      case LightningType.Nearby:
        return IconType.Lightning_Nearby;
      case LightningType.On:
        return IconType.Lightning_On;
      default:
        throw Exception("EditorUI.convertLightningToIconType($lightning)");
    }
  }

  static int convertWindToIconType(int windType) {
    switch (windType) {
      case WindType.Calm:
        return IconType.Wind_Calm;
      case WindType.Gentle:
        return IconType.Wind_Gentle;
      case WindType.Strong:
        return IconType.Wind_Strong;
      default:
        throw Exception('EditorUI.convertWindToIconType($windType)');
    }
  }

  static Widget buildRowRainIcons() =>
      Row(children: RainType.values.map(buildIconRain).toList());

  static Widget buildRowLightningIcons() =>
      Row(children: LightningType.values.map(buildIconLightning).toList());

  static Widget buildRowWindIcons() =>
      Row(children: WindType.values.map(buildIconWind).toList());

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
