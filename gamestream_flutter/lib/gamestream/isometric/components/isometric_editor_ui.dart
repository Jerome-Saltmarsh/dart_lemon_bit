
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_colors.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/games/isometric/game_isometric_ui.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_items.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_editor.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/isometric/ui/columns/build_column_selected_node.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/language_utils.dart';
import 'package:gamestream_flutter/library.dart';

extension IsometricEditorUI on IsometricEditor {

  static const editorGridTypesColumn1 = [
    NodeType.Water,
    NodeType.Brick,
    NodeType.Bricks_Red,
    NodeType.Bricks_Brown,
    NodeType.Soil,
    NodeType.Wood,
    NodeType.Wooden_Plank,
    NodeType.Bau_Haus,
    NodeType.Concrete,
    NodeType.Torch,
    NodeType.Tree_Top,
    NodeType.Tree_Bottom,
    NodeType.Road,
    NodeType.Road_2,
    NodeType.Scaffold,
  ];

  static const editorGridTypesColumn2 = [
    NodeType.Spawn,
    NodeType.Spawn_Player,
    NodeType.Grass,
    NodeType.Grass_Long,
    NodeType.Metal,
    NodeType.Sunflower,
    NodeType.Window,
    NodeType.Sandbag,
    NodeType.Boulder,
    NodeType.Shopping_Shelf,
    NodeType.Bookshelf,
    NodeType.Tile,
    NodeType.Glass,
  ];


  Widget buildEditor(){
    return watch(gamestream.isometric.editor.editTab, buildUI);
  }

  Widget buildPage({required List<Widget> children}) =>
      Container(
          width: engine.screen.width,
          height: engine.screen.height,
          child: Stack(children: children)
      );

  Widget buildUI(EditTab activeEditTab) => buildPage(
    children: [
      watch(gamestream.isometric.editor.editorDialog, buildWatchEditorDialog),
      Positioned(
          bottom: 10,
          child: Container(
              alignment: Alignment.center,
              width: engine.screen.width,
              child: buildRowWeatherControls()
          )
      ),
      buildWindowAIControls(),
      if (activeEditTab == EditTab.Objects)
        Positioned(
          left: 0,
          top: 50,
          child: Container(
              height: engine.screen.height - 100,
              child: buildEditorTabGameObjects()),
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
                  gamestream.isometric.editor.nodeSelectedType,
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
                      if (NodeType.supportsOrientationRadial(
                          selectedNodeType))
                        buildOrientationIcon(
                          NodeOrientation.Radial,
                        ),

                      if (NodeType.supportsOrientationHalfVertical(
                          selectedNodeType
                      ))
                        buildOrientationIcon(NodeOrientation.Half_Vertical_Top),
                      if (NodeType.supportsOrientationColumn(selectedNodeType))
                        buildOrientationIcon(NodeOrientation.Column_Center_Center),
                    ],
                  )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildEditorSelectedNode(),
                  watch(gamestream.isometric.editor.nodeSelectedOrientation,
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
      buildWatchBool(gamestream.isometric.editor.windowEnabledScene, buildWindowEditScene),
      buildWatchBool(gamestream.isometric.editor.windowEnabledCanvasSize, buildWindowEditCanvasSize),
      buildWatchBool(gamestream.isometric.editor.windowEnabledGenerate, buildWindowGenerateScene),
    ],
  );

  Column buildColumnFile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        container(child: "DOWNLOAD", action: gamestream.isometric.editor.downloadScene),
        container(child: "LOAD", action: gamestream.isometric.editor.uploadScene),
        container(child: "EDIT", action: gamestream.isometric.editor.toggleWindowEnabledScene),
        container(child: "MAP SIZE", action: gamestream.isometric.editor.toggleWindowEnabledCanvasSize),
        container(child: "GENERATE", action: gamestream.isometric.editor.windowEnabledGenerate.toggle),
        if (engine.isLocalHost)
          container(child: "SAVE", action: gamestream.isometric.editor.saveScene),
      ],
    );
  }

  Widget buildWindowEditCanvasSize() => Center(
    child: GameIsometricUI.buildDialogUIControl(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 520,
        color: GameIsometricColors.brownLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("CANVAS SIZE"),
                text("Close", onPressed: gamestream.isometric.editor.toggleWindowEnabledCanvasSize),
              ],
            ),
            // watch(GameNodes.totalRows)
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    engine.buildAtlasImage(
                      image: GameImages.atlas_icons,
                      srcX: 193,
                      srcY: 32,
                      srcWidth: 96,
                      srcHeight: 96,
                      scale: 2.0,
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 0,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Row_Start),
                      iconType: IconType.Plus,
                      hint: "Add Row",
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 40,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Row_Start),
                      iconType: IconType.Minus,
                      hint: "Remove Row",
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 150,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Column_Start),
                      iconType: IconType.Plus,
                      hint: "Add Column",
                    ),
                    buildPositionedIconButton(
                      top: 20,
                      left: 160,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Column_Start),
                      iconType: IconType.Minus,
                      hint: "Remove Column",
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 120,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Row_End),
                      iconType: IconType.Minus,
                      hint: "Remove Row",
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 160,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Row_End),
                      iconType: IconType.Plus,
                      hint: "Add Row",
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 0,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Column_End),
                      iconType: IconType.Plus,
                      hint: "Add Column",
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 40,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Column_End),
                      iconType: IconType.Minus,
                      hint: "Remove Column",
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 60,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Z),
                      iconType: IconType.Plus,
                      hint: "Add Z",
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 100,
                      action: () => gamestream.isometric.editor.sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Z),
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

  Widget buildWindowGenerateScene() => Center(
    child: GameIsometricUI.buildDialogUIControl(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 520,
        color: GameIsometricColors.brownLight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("Generate"),
                text("Close", onPressed: gamestream.isometric.editor.windowEnabledGenerate.toggle),
              ],
            ),
            height32,
            buildRowGenerate(gamestream.isometric.editor.generateRows, "Rows"),
            buildRowGenerate(gamestream.isometric.editor.generateColumns, "Columns"),
            buildRowGenerate(gamestream.isometric.editor.generateHeight, "Height"),
            buildRowGenerate(gamestream.isometric.editor.generateOctaves, "Octaves"),
            buildRowGenerate(gamestream.isometric.editor.generateFrequency, "Frequency"),
            height16,
            container(child: "Generate", action: gamestream.isometric.editor.generateScene, color: GameIsometricColors.blue, alignment: Alignment.center),
          ],
        ),
      ),
    ),
  );

  Widget buildRowGenerate(WatchInt value, String name) => Row(
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


  Widget buildWindowEditScene()=> Center(
    child: GameIsometricUI.buildDialogUIControl(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 300,
        color: GameIsometricColors.brownLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                text("Edit Scene"),
                text("Close", onPressed: gamestream.isometric.editor.toggleWindowEnabledScene),
              ],
            ),
            height16,
            onPressed(
              action: gamestream.isometric.editor.sendClientRequestEditSceneToggleUnderground,
              child: Container(
                color: Colors.white12,
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text("Underground"),
                    watch(gamestream.isometric.server.sceneUnderground, text),
                  ],
                ),
              ),
            ),
            height8,
            onPressed(
              action: gamestream.isometric.editor.sendClientRequestEditSceneSetFloorTypeStone,
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

  Widget buildEditorTabGameObjects() =>

      watch(gamestream.isometric.editor.gameObjectSelected, (bool objectSelected){
        if (objectSelected){
          return buildColumnSelectedGameObject();
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ItemType.GameObjectTypes
                    .map(buildRowAddGameObject)
                    .toList(),
              )
            ],
          ),
        );
      });

  Widget buildRowAddGameObject(int gameObjectType, {int color = 1}) =>
      Tooltip(
        message: ItemType.getName(gameObjectType),
        child: Container(
          width: 70,
          height: 70,
          color: Colors.white,
          child: FittedBox(
            child: engine.buildAtlasImageButton(
                image: ItemType.isTypeGameObject(gameObjectType)
                    ? GameImages.atlas_gameobjects
                    : GameImages.atlas_items,
                srcX: AtlasItems.getSrcX(gameObjectType),
                srcY: AtlasItems.getSrcY(gameObjectType),
                srcWidth: AtlasItems.getSrcWidth(gameObjectType),
                srcHeight: AtlasItems.getSrcHeight(gameObjectType),
                color: color,
                action: () =>
                    gamestream.isometric.editor.actionAddGameObject(gameObjectType)
            ),
          ),
        ),
      );



  Widget buildRowWeatherControls() => Row(
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

  Widget buildIconWeatherControl({
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
                decoration: GameIsometricUI.buildDecorationBorder(
                  colorBorder: Colors.white,
                  colorFill: Colors.transparent,
                  width: 2,
                  borderRadius: 0,
                ),
              ),
          ],
        ),
      );

  Widget buildIconRain(int rain) => watch(
      gamestream.isometric.server.rainType,
          (int activeRain) => buildIconWeatherControl(
        tooltip: '${RainType.getName(rain)} Rain',
        action: () => gamestream.isometric.setRain(rain),
        icon: GameIsometricUI.buildAtlasIconType(convertRainToIconType(rain)),
        isActive: rain == activeRain,
      ));

  Widget buildIconLightning(int lightning) => watch(
      gamestream.isometric.server.lightningType,
          (int activeLightning) => buildIconWeatherControl(
        tooltip: '${LightningType.getName(lightning)} Lightning',
        action: () =>
            gamestream.isometric.setLightning(lightning),
        icon: GameIsometricUI.buildAtlasIconType(
            convertLightningToIconType(lightning)),
        isActive: lightning == activeLightning,
      ));

  Widget buildIconWind(int windType) => watch(
      gamestream.isometric.server.windTypeAmbient,
          (int activeWindType) => buildIconWeatherControl(
        tooltip: '${WindType.getName(windType)} Wind',
        action: () => gamestream.isometric.setWind(windType),
        icon: GameIsometricUI.buildAtlasIconType(convertWindToIconType(windType)),
        isActive: windType == activeWindType,
      ));

  int convertRainToIconType(int rain) {
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

  int convertLightningToIconType(int lightning) {
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

  int convertWindToIconType(int windType) {
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

  Widget buildRowRainIcons() =>
      Row(children: RainType.values.map(buildIconRain).toList());

  Widget buildRowLightningIcons() =>
      Row(children: LightningType.values.map(buildIconLightning).toList());

  Widget buildRowWindIcons() =>
      Row(children: WindType.values.map(buildIconWind).toList());

  String convertHourToString(int hour) {
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

  Widget buildControlTime() {
    const totalWidth = 300.0;
    const buttonWidth = totalWidth / 24.0;
    final buttons = watch(gamestream.isometric.server.hours, (int hours) {
      final buttons1 = <Widget>[];
      final buttons2 = <Widget>[];

      for (var i = 0; i <= hours; i++) {
        buttons1.add(
          Tooltip(
            message: '$i - ${convertHourToString(i)}',
            child: container(
              width: buttonWidth,
              color: purple4,
              action: () => gamestream.isometric.setHour(i),
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
              action: () => gamestream.isometric.setHour(i),
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
        watch(gamestream.isometric.server.hours, (num hour) => text(padZero(hour))),
        text(":"),
        watch(gamestream.isometric.server.minutes, (num hour) => text(padZero(hour))),
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

  Widget buildButtonSelectNodeType(int nodeType) {
    final canvas = engine.buildAtlasImage(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.mapNodeType(nodeType),
      srcY: AtlasNodeY.mapNodeType(nodeType),
      srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
      srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
    );

    return WatchBuilder(gamestream.isometric.editor.nodeSelectedType, (int selectedNodeType) {
      return container(
          height: 78,
          width: 78,
          alignment: Alignment.center,
          child: Tooltip(
            child: canvas,
            message: NodeType.getName(nodeType),
          ),
          action: () {
            if (gamestream.isometric.clientState.playMode) {
              gamestream.isometric.actions.actionSetModePlay();
              return;
            }
            gamestream.isometric.editor.paint(nodeType: nodeType);
          },
          color: selectedNodeType == nodeType ? greyDark : grey);
    });
  }

  Widget buildColumnEditNodeOrientation(int nodeOrientation) =>
      Column(
        children: [
          if (NodeOrientation.isSlopeSymmetric(nodeOrientation))
            buildColumnNodeOrientationSlopeSymmetric(),
          if (NodeOrientation.isCorner(nodeOrientation))
            buildColumnNodeOrientationCorner(),
          if (NodeOrientation.isHalf(nodeOrientation))
            buildColumnNodeOrientationHalf(),
          if (NodeOrientation.isSlopeCornerInner(nodeOrientation))
            buildColumnNodeOrientationSlopeCornerInner(),
          if (NodeOrientation.isSlopeCornerOuter(nodeOrientation))
            buildColumnNodeOrientationSlopeCornerOuter(),
          if (NodeOrientation.isHalfVertical(nodeOrientation))
            buildColumnHalfVertical(),
          if (NodeOrientation.isColumn(nodeOrientation))
            buildColumnColumns(),
        ],
      );

  Positioned buildWindowAIControls() {
    return Positioned(
      top: 70,
      right: 70,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: GameIsometricColors.brown02,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            watch(gamestream.isometric.server.gameRunning, (gameRunning) {
              return text("Game Running: $gameRunning", onPressed: () => gamestream.isometric.editor.toggleGameRunning);
            }),
            text ("Reset", onPressed: gamestream.isometric.editor.editSceneReset),
            text("Spawn AI", onPressed: gamestream.isometric.editor.editSceneSpawnAI),
            text("Clear Spawned AI",
                onPressed: gamestream.isometric.editor.editSceneClearSpawnedAI),
          ],
        ),
      ),
    );
  }


  Widget buildOrientationIcon(int orientation) {

    final canvas = engine.buildAtlasImage(
      image: GameImages.atlas_nodes,
      srcX: orientation == NodeOrientation.None ? 1442.0 : 0,
      srcY: AtlasNodeY.mapOrientation(orientation),
      srcWidth: GameIsometricConstants.Sprite_Width,
      srcHeight: GameIsometricConstants.Sprite_Height,
      scale: 0.75,
    );

    return onPressed(
      hint: NodeOrientation.getName(orientation),
      action: () {
        gamestream.isometric.editor.paintOrientation.value = orientation;
        gamestream.isometric.editor.sendClientRequestSetBlock(
          index: gamestream.isometric.editor.nodeSelectedIndex.value,
          type: gamestream.isometric.editor.nodeSelectedType.value,
          orientation: orientation,
        );
      },
      child: watch(gamestream.isometric.editor.nodeSelectedOrientation,
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

  Widget buildColumnNodeOrientationSlopeSymmetric() => Row(
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

  Widget buildColumnNodeOrientationCorner() => Column(
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

  Widget buildColumnNodeOrientationHalf() => Row(
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

  Widget buildColumnNodeOrientationSlopeCornerInner() => Row(
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

  Widget buildColumnNodeOrientationSlopeCornerOuter() => Row(
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

  Widget buildColumnHalfVertical(){
    return Column(
      children: [
        buildOrientationIcon(NodeOrientation.Half_Vertical_Top),
        buildOrientationIcon(NodeOrientation.Half_Vertical_Center),
        buildOrientationIcon(NodeOrientation.Half_Vertical_Bottom),
      ],
    );
  }

  void renderIconSquareEmpty({
    required Canvas canvas,
    required double x,
    required double y,
  }) =>
      engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: 304,
        srcY: 32,
        srcWidth: 48,
        srcHeight: 48,
        dstX: x,
        dstY: y,
      );

  void renderIconSquareFull({
    required Canvas canvas,
    required double x,
    required double y,
  }) =>
      engine.renderExternalCanvas(
        canvas: canvas,
        image: GameImages.atlas_icons,
        srcX: 352,
        srcY: 32,
        srcWidth: 48,
        srcHeight: 48,
        dstX: x,
        dstY: y,
      );


  double projectX(num x, num y){
    return ((x - y) * 0.5 * 48) + 72;
  }

  double projectY(num x, num y){
    return ((y + x) * 0.5 * 48) + 24;
  }

  Widget buildColumnColumns(){
    return watch(gamestream.isometric.editor.nodeSelectedOrientation, (int nodeOrientation){
      var mousePosX = 0.0;
      var mousePosY = 0.0;
      var indexX = 0;
      var indexY = 0;

      switch(nodeOrientation){
        case NodeOrientation.Column_Top_Left:
          indexX = 0;
          indexY = 2;
          break;
        case NodeOrientation.Column_Top_Center:
          indexX = 0;
          indexY = 1;
          break;
        case NodeOrientation.Column_Top_Right:
          indexX = 0;
          indexY = 0;
          break;
        case NodeOrientation.Column_Center_Left:
          indexX = 1;
          indexY = 2;
          break;
        case NodeOrientation.Column_Center_Center:
          indexX = 1;
          indexY = 1;
          break;
        case NodeOrientation.Column_Center_Right:
          indexX = 1;
          indexY = 0;
          break;
        case NodeOrientation.Column_Bottom_Left:
          indexX = 2;
          indexY = 2;
          break;
        case NodeOrientation.Column_Bottom_Center:
          indexX = 2;
          indexY = 1;
          break;
        case NodeOrientation.Column_Bottom_Right:
          indexX = 2;
          indexY = 0;
          break;
      }

      return MouseRegion(
        onHover: (event){
          mousePosX = event.localPosition.dx;
          mousePosY = event.localPosition.dy;
        },
        child: GestureDetector(
          onTap: (){
            final row = ((mousePosX + mousePosY - 24) ~/ Node_Size) - 1;
            final column = ((mousePosY - mousePosX - 72) ~/ Node_Size) + 2;
            print("row: $row, column: $column");
            if (row < 0) return;
            if (column < 0) return;
            if (row > 2) return;
            if (column > 2) return;
            indexX = row;
            indexY = column;
            if (row == 0 && column == 2){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Left,
              );
              return;
            }
            if (row == 0 && column == 1){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Center,
              );
              return;
            }
            if (row == 0 && column == 0){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Right,
              );
              return;
            }

            if (row == 1 && column == 2){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Left,
              );
              return;
            }
            if (row == 1 && column == 1){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Center,
              );
              return;
            }
            if (row == 1 && column == 0){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Right,
              );
              return;
            }

            if (row == 2 && column == 2){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Left,
              );
              return;
            }
            if (row == 2 && column == 1){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Center,
              );
              return;
            }
            if (row == 2 && column == 0){
              gamestream.isometric.editor.sendClientRequestSetBlock(
                index: gamestream.isometric.editor.nodeSelectedIndex.value,
                type: gamestream.isometric.editor.nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Right,
              );
              return;
            }
          },
          child: Container(
            width: 200,
            height: 200,
            color: GameIsometricColors.brownDark,
            child: engine.buildCanvas(paint: (Canvas canvas, Size size){
              for (var x = 0; x < 3; x++){
                for (var y = 0; y < 3; y++){
                  renderIconSquareEmpty(
                    canvas: canvas,
                    x: projectX(x, y),
                    y: projectY(x, y),
                  );
                }
              }
              renderIconSquareFull(
                canvas: canvas,
                x: projectX(indexX, indexY),
                y: projectY(indexX, indexY),
              );            },
            ),
          ),
        ),
      );
    });
  }

  Widget buildColumnSelectedGameObject() => GameIsometricUI.buildDialogUIControl(
    child: Container(
      color: brownLight,
      width: 220,
      padding: GameStyle.Padding_10,
      child: SingleChildScrollView(
        child: Column(
          children: [
            watch(gamestream.isometric.editor.gameObjectSelectedType, (int type) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: text("X", onPressed: gamestream.isometric.editor.sendGameObjectRequestDeselect),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 80,
                      maxHeight: 80,
                    ),
                    child: GameIsometricUI.buildAtlasItemType(type),
                  ),
                  height8,
                  Row(
                    children: [
                      text(ItemType.getName(type), size: 22),
                      width8,
                      text("Duplicate", onPressed: gamestream.isometric.editor.sendGameObjectRequestDuplicate)
                    ],
                  ),
                  height8,
                  watch(gamestream.isometric.editor.gameObjectSelectedCollidable, (bool enabled) =>
                      onPressed(
                        action: () => gamestream.isometric.editor.sendGameObjectRequestToggleStrikable,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Strikable"),
                            text(enabled),
                          ],
                        ),
                      )
                  ),
                  watch(gamestream.isometric.editor.gameObjectSelectedGravity, (bool enabled) =>
                      onPressed(
                        action: () => gamestream.isometric.editor.sendGameObjectRequestToggleGravity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Gravity"),
                            text(enabled),
                          ],
                        ),
                      )
                  ),
                  watch(gamestream.isometric.editor.gameObjectSelectedFixed, (bool enabled) =>
                      onPressed(
                        action: gamestream.isometric.editor.sendGameObjectRequestToggleFixed,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Fixed"),
                            text(enabled),
                          ],
                        ),
                      )
                  ),
                  watch(gamestream.isometric.editor.gameObjectSelectedCollectable, (bool enabled) =>
                      onPressed(
                        action: gamestream.isometric.editor.sendGameObjectRequestToggleCollectable,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Collectable"),
                            text(enabled),
                          ],
                        ),
                      )
                  ),
                  watch(gamestream.isometric.editor.gameObjectSelectedPhysical, (bool enabled) =>
                      onPressed(
                        action: gamestream.isometric.editor.selectedGameObjectTogglePhysical,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Physical"),
                            text(enabled),
                          ],
                        ),
                      )
                  ),
                  watch(gamestream.isometric.editor.gameObjectSelectedPersistable, (bool enabled) =>
                      onPressed(
                        action: gamestream.isometric.editor.selectedGameObjectTogglePersistable,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            text("Persistable"),
                            text(enabled),
                          ],
                        ),
                      )
                  ),
                  watch(gamestream.isometric.editor.gameObjectSelectedEmission, (int emissionType) =>
                      onPressed(
                        action: () => gamestream.isometric.editor.gameObject.value!.emission_type = ((gamestream.isometric.editor.gameObject.value!.emission_type + 1) % 3),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text("Emission"),
                                text(emissionType),
                              ],
                            ),
                            text("Intensity"),
                            watch(gamestream.isometric.editor.gameObjectSelectedEmissionIntensity, (double value) => Slider(
                              value: gamestream.isometric.editor.gameObject.value?.emission_intensity ?? 0,
                              onChanged: gamestream.isometric.editor.setSelectedObjectedIntensity,
                            )),
                            if (emissionType == IsometricEmissionType.Color)
                              ColorPicker(
                                portraitOnly: true,
                                pickerColor: Color(gamestream.isometric.editor.gameObject.value!.emission_col),
                                onColorChanged: (color){
                                  final gameObject = gamestream.isometric.editor.gameObject.value!;
                                  final hsv = HSVColor.fromColor(color);
                                  gameObject.emission_alp = (hsv.alpha * 255).round();
                                  gameObject.emission_hue = (hsv.hue).round();
                                  gameObject.emission_sat = (hsv.saturation * 100).round();
                                  gameObject.emission_val = (hsv.value * 100).round();
                                  gameObject.refreshEmissionColor();
                                },
                              )
                          ],
                        ),
                      )
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    ),
  );

  Widget buildColumnEditParticleEmitter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        watch(gamestream.isometric.editor.gameObjectSelectedParticleType,
                (int particleType) => text("Particle Type: $particleType")),
        watch(gamestream.isometric.editor.gameObjectSelectedParticleSpawnRate,
                (int rate) => text("Rate: $rate")),
      ],
    );
  }

  Column buildControlPaint() {
    return Column(
      children: [
        watch(gamestream.isometric.editor.paintType, buildPaintType),
      ],
    );
  }

  Widget buildPaintType(int type) =>
      container(child: NodeType.getName(type));

  Row buildEditorMenu(EditTab activeEditTab) => Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: EditTab.values
        .map((editTab) => container(
      child: editTab.name,
      width: 150,
      color: activeEditTab == editTab
          ? GameIsometricColors.brownDark
          : GameIsometricColors.brownLight,
      action: () => gamestream.isometric.editor.editTab.value = editTab,
    ))
        .toList(),
  );

  Widget buildMenu(
      {required String text, required List<Widget> children}) {
    final child = container(child: text, color: brownLight);
    return MouseOver(builder: (over) {
      if (over) {
        return Column(
          children: [
            child,
            Container(
              height: engine.screen.height - 100,
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

  Widget buildColumnSelectNodeType() =>
      Container(
        height: engine.screen.height - 70,
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: editorGridTypesColumn1.map(buildButtonSelectNodeType).toList(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: editorGridTypesColumn2.map(buildButtonSelectNodeType).toList(),
              ),
            ],
          ),
        ),
      );

  Widget buildColumnSelectObjectType(){
    return Column();
  }
}