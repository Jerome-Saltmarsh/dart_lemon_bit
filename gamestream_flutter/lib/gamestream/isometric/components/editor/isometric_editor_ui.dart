
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch.dart';
import 'package:gamestream_flutter/gamestream/ui/builders/build_watch_bool.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/height.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/width.dart';
import 'package:gamestream_flutter/gamestream/ui/enums/icon_type.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_button.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/packages/utils.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'editor_tab.dart';
import 'isometric_editor.dart';

extension IsometricEditorUI on IsometricEditor {

  static const gameObjects = const [
    ObjectType.Barrel,
    ObjectType.Barrel_Explosive,
    ObjectType.Crate_Wooden,
    ObjectType.Sphere,
    ObjectType.Rock1,
    ObjectType.Tree1,
    ObjectType.Crystal_Glowing_False,
    ObjectType.Crystal_Glowing_True,
  ];

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
    NodeType.Torch_Blue,
    NodeType.Torch_Red,
    NodeType.Fireplace,
  ];


  Widget buildEditor(){
    return buildWatch(editorTab, buildUI);
  }

  Widget buildPage({required List<Widget> children}) =>
      IsometricBuilder(
        builder: (context, isometric) {
          return Container(
              width: engine.screen.width,
              height: engine.screen.height,
              child: Stack(children: children)
          );
        }
      );

  Widget buildUI(EditorTab activeEditTab) => buildPage(
    children: [
      buildWatch(editorDialog, buildWatchEditorDialog),
      Positioned(
          bottom: 10,
          child: Container(
              alignment: Alignment.center,
              width: engine.screen.width,
              child: buildRowWeatherControls()
          )
      ),
      buildWindowAIControls(),
      if (activeEditTab == EditorTab.Objects)
        Positioned(
          left: 0,
          top: 80,
          child: Container(
              height: engine.screen.height - 100,
              child: buildEditorTabGameObjects()),
        ),
      if (activeEditTab == EditorTab.Marks)
        Positioned(
          left: 0,
          top: 80,
          child: buildEditorTabMarks(),
        ),
      if (activeEditTab == EditorTab.Nodes)
        Positioned(
          left: 0,
          top: 80,
          child: buildEditorTabNodes(),
        ),
      if (activeEditTab == EditorTab.Nodes)
        Positioned(
          left: 160,
          top: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildWatch(
                  nodeSelectedType,
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
                            NodeOrientation.Corner_North_East),
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
                  buildWatch(nodeSelectedOrientation,
                      buildColumnEditNodeOrientation),
                ],
              ),
            ],
          ),
        ),
      if (activeEditTab == EditorTab.File)
        Positioned(
            top: 100,
            left: 0,
            child: Container(
              alignment: Alignment.center,
              child: buildColumnFile(),
            ),
        ),
      if (activeEditTab == EditorTab.Keys)
        buildEditorTabKeys(),
      Positioned(
        left: 0,
        top: 0,
        child: buildEditorMenu(activeEditTab),
      ),
      buildWatchBool(windowEnabledScene, buildWindowEditScene),
      buildWatchBool(windowEnabledCanvasSize, buildWindowEditCanvasSize),
      buildWatchBool(windowEnabledGenerate, buildWindowGenerateScene),
    ],
  );

  Widget buildColumnFile() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildButton(child: 'DOWNLOAD', action: downloadScene),
        buildButton(child: 'NEW', action: newScene),
        buildButton(child: 'LOAD', action: uploadScene),
        buildButton(child: 'EDIT', action: toggleWindowEnabledScene),
        buildButton(child: 'MAP SIZE', action: toggleWindowEnabledCanvasSize),
        buildButton(child: 'GENERATE', action: windowEnabledGenerate.toggle),
        if (engine.isLocalHost)
          buildButton(child: 'SAVE', action: saveScene),
      ],
    );

  Widget buildWindowEditCanvasSize() => Center(
    child: GSContainer(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 520,
        color: colors.brownLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText('CANVAS SIZE'),
                onPressed(
                    action: toggleWindowEnabledCanvasSize,
                    child: buildText('Close'),
                ),
              ],
            ),
            // watch(GameNodes.totalRows)
            Expanded(
              child: Center(
                child: Stack(
                  children: [
                    engine.buildAtlasImage(
                      image: amulet.images.atlas_icons,
                      srcX: 193,
                      srcY: 32,
                      srcWidth: 96,
                      srcHeight: 96,
                      scale: 2.0,
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 0,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Add_Row_Start),
                      iconType: IconType.Plus,
                      hint: 'Add Row',
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 40,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Remove_Row_Start),
                      iconType: IconType.Minus,
                      hint: 'Remove Row',
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 150,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Add_Column_Start),
                      iconType: IconType.Plus,
                      hint: 'Add Column',
                    ),
                    buildPositionedIconButton(
                      top: 20,
                      left: 160,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Remove_Column_Start),
                      iconType: IconType.Minus,
                      hint: 'Remove Column',
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 120,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Remove_Row_End),
                      iconType: IconType.Minus,
                      hint: 'Remove Row',
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 160,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Add_Row_End),
                      iconType: IconType.Plus,
                      hint: 'Add Row',
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 0,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Add_Column_End),
                      iconType: IconType.Plus,
                      hint: 'Add Column',
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 40,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Remove_Column_End),
                      iconType: IconType.Minus,
                      hint: 'Remove Column',
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 60,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Add_Z),
                      iconType: IconType.Plus,
                      hint: 'Add Z',
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 100,
                      action: () => sendClientRequestModifyCanvasSize(NetworkRequestModifyCanvasSize.Remove_Z),
                      iconType: IconType.Minus,
                      hint: 'Remove Z',
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
    child: GSContainer(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 520,
        color: colors.brownLight,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText('Generate'),
                    onPressed(
                      action: windowEnabledGenerate.toggle,
                      child: buildText('Close'),
                    ),
                  ],
            ),
            height32,
            buildRowGenerate(generateRows, 'Rows'),
            buildRowGenerate(generateColumns, 'Columns'),
            buildRowGenerate(generateHeight, 'Height'),
            buildRowGenerate(generateOctaves, 'Octaves'),
            buildRowGenerate(generateFrequency, 'Frequency'),
            height16,
            buildButton(child: 'Generate', action: generateScene, color: Colors.blue, alignment: Alignment.center),
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
          Container(child: buildText(name), alignment: Alignment.centerLeft, width: 100),
          buildWatch(value, buildText),
        ],
      ),
      Row(
        children: [
          buildButton(child: '-', width: 50, action: value.decrement, alignment: Alignment.center),
          width6,
          buildButton(child: '+', width: 50, action: value.increment, alignment: Alignment.center),
        ],
      ),
    ],
  );


  Widget buildWindowEditScene()=> Center(
    child: GSContainer(
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 400,
        height: 300,
        color: colors.brownLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText('Edit Scene'),
                onPressed(
                  action: toggleWindowEnabledScene,
                  child: buildText('Close')),
              ],
            ),
            height8,
            onPressed(
              action: sendClientRequestEditSceneSetFloorTypeStone,
              child: Container(
                color: Colors.white12,
                padding: const EdgeInsets.all(5),
                child: buildText('Set Floor Stone'),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget buildEditorTabGameObjects() =>
      GSContainer(
        child: buildWatch(gameObjectSelected, (bool objectSelected){
          if (objectSelected){
            return buildColumnSelectedGameObject();
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: gameObjects.map(buildButtonAddGameObject).toList(),
            ),
          );
        }),
      );

  Widget buildButtonAddGameObject(int objectType) =>
      onPressed(
        action: () => actionAddGameObject(objectType),
        child: Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(4),
          color: style.containerColor,
          child: FittedBox(
            // child: amulet.ui.buildImageGameObject(objectType),
            child: buildText(ObjectType.getName(objectType)),
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
                // decoration: IsometricUI.buildDecorationBorder(
                //   colorBorder: Colors.white,
                //   colorFill: Colors.transparent,
                //   width: 2,
                //   borderRadius: 0,
                // ),
              ),
          ],
        ),
      );

  Widget buildIconRain(int rain) => buildWatch(
      environment.rainType,
          (int activeRain) => buildIconWeatherControl(
        tooltip: '${RainType.getName(rain)} Rain',
        action: () => network.sendIsometricRequestWeatherSetRain(rain),
        icon: amulet.ui.buildAtlasIconType(convertRainToIconType(rain)),
        isActive: rain == activeRain,
      ));

  Widget buildIconLightning(int lightning) => buildWatch(
      environment.lightningType,
          (int activeLightning) => buildIconWeatherControl(
        tooltip: '${LightningType.getName(lightning)} Lightning',
        action: () =>
            network.sendIsometricRequestWeatherSetLightning(lightning),
        icon: amulet.ui.buildAtlasIconType(
            convertLightningToIconType(lightning)),
        isActive: lightning == activeLightning,
      ));

  Widget buildIconWind(int windType) => buildWatch(
      environment.wind,
          (int activeWindType) => buildIconWeatherControl(
        tooltip: '${WindType.getName(windType)} Wind',
        action: () => network.sendIsometricRequestWeatherSetWind(windType),
        icon: amulet.ui.buildAtlasIconType(convertWindToIconType(windType)),
        isActive: windType == activeWindType,
      ));

  IconType convertRainToIconType(int rain) {
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

  IconType convertLightningToIconType(int lightning) {
    switch (lightning) {
      case LightningType.Off:
        return IconType.Lightning_Off;
      case LightningType.Nearby:
        return IconType.Lightning_Nearby;
      case LightningType.On:
        return IconType.Lightning_On;
      default:
        throw Exception('EditorUI.convertLightningToIconType($lightning)');
    }
  }

  IconType convertWindToIconType(int windType) {
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
    final buttons = buildWatch(environment.hours, (int hours) {
      final buttons1 = <Widget>[];
      final buttons2 = <Widget>[];

      for (var i = 0; i <= hours; i++) {
        buttons1.add(
          Tooltip(
            message: '$i - ${convertHourToString(i)}',
            child: buildButton(
              width: buttonWidth,
              color: colors.orange_0,
              action: () => network.sendIsometricRequestTimeSetHour(i),
            ),
          ),
        );
      }
      for (var i = hours + 1; i < 24; i++) {
        buttons2.add(
          Tooltip(
            message: '$i - ${convertHourToString(i)}',
            child: buildButton(
              width: buttonWidth,
              color: colors.white10,
              action: () => network.sendIsometricRequestTimeSetHour(i),
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
        buildWatch(environment.hours, (num hour) => buildText(padZero(hour))),
        buildText(':'),
        buildWatch(environment.minutes, (num hour) => buildText(padZero(hour))),
      ],
    );
    return Container(
      child: Row(
        children: [
          Container(
              color: colors.brownLight,
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

    final image = engine.buildAtlasImage(
      image: images.atlas_nodes,
      srcX: AtlasNodeX.mapNodeType(nodeType),
      srcY: AtlasNodeY.mapNodeType(nodeType),
      srcWidth: AtlasNodeWidth.mapNodeType(nodeType),
      srcHeight: AtlasNodeHeight.mapNodeType(nodeType),
    );

    return WatchBuilder(nodeSelectedType, (int selectedNodeType) => buildButton(
          height: 78,
          width: 78,
          alignment: Alignment.center,
          child: Tooltip(
            child: image,
            message: NodeType.getName(nodeType),
          ),
          action: () {
            if (options.playMode) {
              options.actionSetModePlay();
              return;
            }
            paint(nodeType: nodeType);
          },
          color: selectedNodeType == nodeType ? colors.white : colors.white60));
  }

  Widget buildColumnEditNodeOrientation(int nodeOrientation) =>
      Column(
        children: [
          if (NodeOrientation.slopeSymmetric.contains(nodeOrientation))
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
        color: colors.brown_2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWatch(options.gameRunning, (gameRunning) => onPressed(
                  action: toggleGameRunning,
                  child: buildText('Game Running: $gameRunning'),
              )),
            onPressed(
              action: editSceneReset,
              child: buildText ('Reset'),
            ),
            onPressed(
              action: editSceneSpawnAI,
              child: buildText('Spawn AI'),
            ),
            onPressed(
              action: editSceneClearSpawnedAI,
              child: buildText('Clear Spawned AI'),
            ),
          ],
        ),
      ),
    );
  }


  Widget buildOrientationIcon(int orientation) {

    final canvas = engine.buildAtlasImage(
      image: images.atlas_nodes,
      srcX: orientation == NodeOrientation.None ? 1442.0 : 0,
      srcY: AtlasNodeY.mapOrientation(orientation),
      srcWidth: IsometricConstants.Sprite_Width,
      srcHeight: IsometricConstants.Sprite_Height,
      scale: 0.75,
    );

    return onPressed(
      hint: NodeOrientation.getName(orientation),
      action: () {
        paintOrientation.value = orientation;
        setNode(
          index: nodeSelectedIndex.value,
          type: nodeSelectedType.value,
          orientation: orientation,
        );
      },
      child: buildWatch(nodeSelectedOrientation,
              (int selectedNodeOrientation) {
            return Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                color: selectedNodeOrientation == orientation ? colors.white : colors.brownDark,
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
      buildOrientationIcon(NodeOrientation.Corner_North_East),
      Row(
        children: [
          buildOrientationIcon(NodeOrientation.Corner_North_West),
          const SizedBox(width: 48),
          buildOrientationIcon(NodeOrientation.Corner_South_East),
        ],
      ),
      buildOrientationIcon(NodeOrientation.Corner_South_West),
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
      renderCanvas(
        canvas: canvas,
        image: images.atlas_icons,
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
      renderCanvas(
        canvas: canvas,
        image: amulet.images.atlas_icons,
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
    return buildWatch(nodeSelectedOrientation, (int nodeOrientation){
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
            print('row: $row, column: $column');
            if (row < 0) return;
            if (column < 0) return;
            if (row > 2) return;
            if (column > 2) return;
            indexX = row;
            indexY = column;
            if (row == 0 && column == 2){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Left,
              );
              return;
            }
            if (row == 0 && column == 1){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Center,
              );
              return;
            }
            if (row == 0 && column == 0){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Right,
              );
              return;
            }

            if (row == 1 && column == 2){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Left,
              );
              return;
            }
            if (row == 1 && column == 1){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Center,
              );
              return;
            }
            if (row == 1 && column == 0){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Right,
              );
              return;
            }

            if (row == 2 && column == 2){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Left,
              );
              return;
            }
            if (row == 2 && column == 1){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Center,
              );
              return;
            }
            if (row == 2 && column == 0){
              setNode(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Right,
              );
              return;
            }
          },
          child: Container(
            width: 200,
            height: 200,
            color: colors.brownDark,
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

  Widget buildColumnSelectedGameObject() => GSContainer(
        width: 220,
        child: buildWatch(
            gameObjectSelectedType,
            (int type) => buildWatch(
                gameObjectSelectedSubType,
                (int subType) => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          child: onPressed(
                            action: sendGameObjectRequestDeselect,
                            child: buildText('X'),
                          ),
                        ),
                        Center(child: amulet.ui.buildImageGameObject(subType)),
                        height8,
                        buildButtonDuplicate(),
                        height8,
                        buildText(ItemType.getName(type), size: 22),
                        height8,
                        buildText(
                            ItemType.getNameSubType(type, subType),
                            size: 22),
                        height8,
                        buildWatchCollidable(),
                        buildWatchGravity(),
                        buildWatchFixed(),
                        buildWatchCollectable(),
                        buildWatchPhysical(),
                        buildWatchPersistable(),
                        buildWatchEmission(),
                      ],
                    ))),
      );

  Widget buildColumnEditParticleEmitter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildWatch(gameObjectSelectedParticleType,
                (int particleType) => buildText('Particle Type: $particleType')),
        buildWatch(gameObjectSelectedParticleSpawnRate,
                (int rate) => buildText('Rate: $rate')),
      ],
    );
  }

  Column buildControlPaint() {
    return Column(
      children: [
        buildWatch(paintType, buildPaintType),
      ],
    );
  }

  Widget buildPaintType(int type) =>
      buildButton(child: NodeType.getName(type));

  Widget buildEditorMenu(EditorTab activeEditTab) => GSContainer(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: EditorTab.values
          .map((editTab) => buildButton(
        child: editTab.name,
        width: 150,
        color: activeEditTab == editTab
            ? colors.brownDark
            : colors.brownLight,
        action: () => this.editorTab.value = editTab,
      ))
          .toList(),
    ),
  );

  Widget buildMenu(
      {required String text, required List<Widget> children}) {
    final child = buildButton(child: text, color: colors.brownLight);
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

  Widget buildEditorTabMarks() => GSContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              onPressed(
                  action: onButtonPressedAddMark,
                  child: GSContainer(child: buildText('ADD')),
              ),
              onPressed(
                  action: markDelete,
                  child: GSContainer(child: buildText('DELETE')),
              ),
            ],
          ),
          WatchBuilder(selectedMarkType, (int selectedMarkType) => Row(
              children: MarkType.values
                  .map((markType) => onPressed(
                    action: () => markSetType(markType),
                    child: GSContainer(
                        color: selectedMarkType == markType ? colors.brownLight : colors.brownDark,
                        child: buildText(MarkType.getName(markType))))
                  )
                  .toList(growable: false),
            )),
          Container(
            height: 200,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildWatch(scene.marksChangedNotifier, (t) =>
                  buildWatch(selectedMarkListIndex, (selectedMarkListIndex) => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(scene.marks.length, (index) => onPressed(
                            action: (){
                              markSelect(index);
                            },
                            child: Container(
                                padding: const EdgeInsets.all(6),
                                color: index == selectedMarkListIndex ? Colors.white24 : null,
                                child: buildText(MarkType.getTypeName(scene.marks[index]))),
                        )),
                    )))
                ],
              ),
            ),
          )
        ],
      ),
    );

  void onButtonPressedAddMark() => markAdd(nodeSelectedIndex.value);

  Widget buildEditorTabNodes() =>
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

  Widget buildEditorSelectedNode({double shiftX = 17, double shiftY = 20.0}) =>
      Container(
        width: 130,
        height: 220,
        padding: const EdgeInsets.all(6),
        color: colors.brownDark,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildWatch(nodeSelectedIndex, buildText),
                onPressed(
                  hint: 'Delete',
                  action: delete,
                  child: Container(
                    width: 16,
                    height: 16,
                    child: onPressed(
                      action: delete,
                      child: engine.buildAtlasImage(
                        image: amulet.images.atlas_icons,
                        srcX: 80,
                        srcY: 96,
                        srcWidth: 16,
                        srcHeight: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                height: 70,
                alignment: Alignment.center,
                child: buildWatch(
                    nodeSelectedType,
                        (int nodeType) =>
                        buildText(NodeType.getName(nodeType), align: TextAlign.center)
                )
            ),
            buildWatch(nodeSelectedVariation, (variation) {
              return Row(
                children: List.generate(2, (index) {
                  return onPressed(
                    action: () => setNode(index: selectedIndex, variation: index),
                    child: Container(
                        width: 50,
                        height: 50,
                        color: index == variation ? Colors.green : Colors.grey,
                    ),
                  );
                }),
              );
            }),
            Container(
              width: 120,
              height: 120,
              alignment: Alignment.center,
              color: Colors.green,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  buildPositionedIconButton(
                    top: 65 + shiftY,
                    left: 27 + shiftX,
                    action: cursorZDecrease,
                    iconType: IconType.Arrows_Down,
                    hint: 'Shift + Arrow Down',
                  ),
                  buildPositionedIconButton(
                    top: 3 + shiftY,
                    left: 3 + shiftY,
                    action: cursorRowDecrease,
                    iconType: IconType.Arrows_North,
                    hint: 'Arrow Up',
                  ),
                  buildPositionedIconButton(
                    top: 5 + shiftY,
                    left: 50 + shiftX,
                    action: cursorColumnDecrease,
                    iconType: IconType.Arrows_East,
                    hint: 'Arrow Right',
                  ),
                  Container(
                      height: 72,
                      width: 72,
                      alignment: Alignment.center,
                      child: buildWatch(nodeSelectedType, amulet.ui.buildAtlasNodeType)
                  ),
                  buildPositionedIconButton(
                      top: 50 + shiftY,
                      left: 50 + shiftX,
                      action: cursorRowIncrease,
                      iconType: IconType.Arrows_South,
                      hint: 'Arrow Down'
                  ),
                  buildPositionedIconButton(
                      top: -10 + shiftY,
                      left: 27 + shiftX,
                      action: cursorZIncrease,
                      iconType: IconType.Arrows_Up,
                      hint: 'Shift + Arrow Up'
                  ),
                  buildPositionedIconButton(
                      top: 50 + shiftY,
                      left: 0 + shiftX,
                      action: cursorColumnIncrease,
                      iconType: IconType.Arrows_West,
                      hint: 'Arrow Left'
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget buildPositionedIconButton({
    required double top,
    required double left,
    required Function action,
    required IconType iconType,
    required String hint,
  }) =>
      Positioned(
        top: top,
        left: left,
        child: onPressed(
          action: action,
          child: MouseOver(builder: (bool mouseOver) =>
              amulet.ui.buildAtlasIconType(
                iconType,
              )
          ),
          hint: hint,
        ),
      );

  Widget buildWatchEditorDialog(EditorDialog? activeEditorDialog){
    if (activeEditorDialog == null) return nothing;

    return Container(
      width: engine.screen.width,
      height: engine.screen.height,
      alignment: Alignment.center,
      child: Container(
          width: 350,
          height: 400,
          color: colors.brownLight,
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  buildButtonGameDialogClose(),
                ],
              ),
              height8,
            ],
          )),
    );
  }

  Widget buildButtonGameDialogClose() =>
      onPressed(
          action: actionGameDialogClose,
          child: buildText('x'),
      );

  Widget buildButtonDuplicate() => onPressed(
    action: sendGameObjectRequestDuplicate,
    child: buildText('Duplicate'),
  );

  Widget buildWatchFixed() => buildWatch(
        gameObjectSelectedFixed,
            (bool enabled) =>
            onPressed(
              action:
              sendGameObjectRequestToggleFixed,
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  buildText('Fixed'),
                  buildText(enabled),
                ],
              ),
            ));

  Widget buildWatchGravity() => buildWatch(
        gameObjectSelectedGravity,
            (bool enabled) => onPressed(
          action: () =>
          sendGameObjectRequestToggleGravity,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              buildText('Gravity'),
              buildText(enabled),
            ],
          ),
        ));

  Widget buildWatchCollidable() => buildWatch(
        gameObjectSelectedCollidable,
            (bool enabled) => onPressed(
          action: () =>
          sendGameObjectRequestToggleStrikable,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              buildText('Collidable'),
              buildText(enabled),
            ],
          ),
        ));

  Widget buildWatchCollectable() => buildWatch(
        gameObjectSelectedCollectable,
            (bool enabled) => onPressed(
          action:
          sendGameObjectRequestToggleCollectable,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              buildText('Collectable'),
              buildText(enabled),
            ],
          ),
        ));

  Widget buildWatchPhysical() => buildWatch(
        gameObjectSelectedPhysical,
            (bool enabled) => onPressed(
          action:
          selectedGameObjectTogglePhysical,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              buildText('Physical'),
              buildText(enabled),
            ],
          ),
        ));

  Widget buildWatchPersistable() => buildWatch(
        gameObjectSelectedPersistable,
            (bool enabled) => onPressed(
          action:
          selectedGameObjectTogglePersistable,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              buildText('Persistable'),
              buildText(enabled),
            ],
          ),
        ));

  Widget buildWatchEmission() => buildWatch(
        gameObjectSelectedEmission,
            (int emissionType) => onPressed(
          action: () => gameObject
              .value!.emissionType =
          ((gameObject.value!.emissionType +
              1) %
              3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  buildText('Emission'),
                  buildText(emissionType),
                ],
              ),
              buildText('Intensity'),
              buildWatch(
                  gameObjectSelectedEmissionIntensity,
                      (double value) => Slider(
                    value: gameObject.value
                        ?.emissionIntensity ??
                        0,
                    onChanged:
                    setSelectedObjectedIntensity,
                  )),
              if (emissionType == EmissionType.Color)
                ColorPicker(
                  portraitOnly: true,
                  pickerColor: Color(gameObject
                      .value!.emissionColor),
                  onColorChanged: (color) {
                    final gameObject =
                        this.gameObject.value;
                    if (gameObject == null)
                      return;
                    final hsv =
                    HSVColor.fromColor(color);
                    gameObject.emissionAlp =
                        (hsv.alpha * 255).round();
                    gameObject.emissionHue =
                        (hsv.hue).round();
                    gameObject.emissionSat =
                        (hsv.saturation * 100)
                            .round();
                    gameObject.emissionVal =
                        (hsv.value * 100).round();

                    refreshGameObjectEmissionColor(gameObject);
                  },
                )
            ],
          ),
        ));


  void refreshGameObjectEmissionColor(GameObject gameObject){
    // TODO
    // gameObject.emissionColor = hsvToColor(
    //   hue: interpolate(ambientHue, gameObject.emissionHue, gameObject.emissionIntensity).toInt(),
    //   saturation: interpolate(ambientSaturation, gameObject.emissionSat, gameObject.emissionIntensity).toInt(),
    //   value: interpolate(ambientValue, gameObject.emissionVal, gameObject.emissionIntensity).toInt(),
    //   opacity: interpolate(ambientAlpha, gameObject.emissionAlp, gameObject.emissionIntensity).toInt(),
    // );
  }

  Positioned buildEditorTabKeys() => Positioned(
    top: 100,
    left: 0,
    child: GSContainer(
      // height: 300,
      child: Column(
        children: [
          Row(
            children: [
              buildButtonAddKey(),
              width8,
              buildButtonDeleteKey(),
              width8,
              buildButtonRenameKey(),
            ],
          ),
              buildWatch(
                  scene.keysChangedNotifier,
                  (t) => SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: engine.screen.height - 150),
                      child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: scene.keys.entries
                                .map(buildKeyEntry)
                                .toList(growable: false),
                          ),
                    ),
                  ))
            ],
          ),
    ),
  );

  Widget buildKeyEntry(MapEntry<String, int> entry) =>
      buildWatch(selectedKeyEntry, (selectedEntry) =>
        onPressed(
        action: () => onPressedKeyEntry(entry),
        child: buildBorder(
          padding: const EdgeInsets.all(4),
          color: selectedEntry?.key == entry.key ? Colors.white70 : Colors.transparent,
          child: buildText(entry.key),
        ),
      ));

  void onPressedKeyEntry(MapEntry<String, int> keyEntry) {
    selectedKeyEntry.value = keyEntry;
  }

  Widget buildButtonAddKey() => onPressed(
      action: (){
        ui.showDialogGetString(onSelected: (name) {
          network.sendNetworkRequest(
              NetworkRequest.Editor_Request,
              EditorRequest.Add_Key.index,
              name,
              editor.nodeSelectedIndex.value
          );
          // send request to add key
        });
      },
      child: GSContainer(
          color: Colors.black12,
          child: buildText('ADD')
      ),
    );

  Widget buildButtonDeleteKey() {
    return buildWatch(selectedKeyEntry, (selectedKeyEntry) {
      return onPressed(
        action: selectedKeyEntry == null ? null : deleteSelectedKeyEntry,
        child: GSContainer(
          color: Colors.black12,
          child: buildText(
              'DELETE',
              color: selectedKeyEntry == null
                  ? Colors.white38
                  : Colors.white),
        ),
      );
    });
  }

  Widget buildButtonRenameKey() =>
      buildWatch(selectedKeyEntry, (t) => onPressed(
        action: t == null ? null : onButtonPressedRenameKey,
        child: GSContainer(
            color: Colors.black12,
            child: buildText('RENAME', color: t == null ? Colors.white54 : Colors.white)),
      ));

  void onButtonPressedRenameKey(){
    final selectedKey = selectedKeyEntry.value;
    if (selectedKey == null){
      return;
    }

    ui.showDialogGetString(
        text: selectedKeyEntry.value?.key,
        onSelected: (text) => renameKey(from: selectedKey.key, to: text),
    );
  }
}







