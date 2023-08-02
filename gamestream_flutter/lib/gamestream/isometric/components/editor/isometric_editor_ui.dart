
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';

import 'package:gamestream_flutter/isometric.dart';
import 'package:gamestream_flutter/ui.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:gamestream_flutter/library.dart';

extension IsometricEditorUI on IsometricEditor {

  static const gameObjects = const [
    ObjectType.Barrel,
    ObjectType.Barrel_Explosive,
    ObjectType.Crate_Wooden,
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
    NodeType.Torch_Blue,
    NodeType.Torch_Red,
    NodeType.Fireplace,
  ];


  Widget buildEditor(){
    return buildWatch(editTab, buildUI);
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

  Widget buildUI(IsometricEditorTab activeEditTab) => buildPage(
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
      if (activeEditTab == IsometricEditorTab.Objects)
        Positioned(
          left: 0,
          top: 50,
          child: Container(
              height: engine.screen.height - 100,
              child: buildEditorTabGameObjects()),
        ),
      if (activeEditTab == IsometricEditorTab.Grid)
        Positioned(
          left: 0,
          top: 50,
          child: buildColumnSelectNodeType(),
        ),
      if (activeEditTab == IsometricEditorTab.Grid)
        Positioned(
          left: 160,
          top: 50,
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
      if (activeEditTab == IsometricEditorTab.File)
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
      buildWatchBool(windowEnabledScene, buildWindowEditScene),
      buildWatchBool(windowEnabledCanvasSize, buildWindowEditCanvasSize),
      buildWatchBool(windowEnabledGenerate, buildWindowGenerateScene),
    ],
  );

  Column buildColumnFile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildButton(child: 'DOWNLOAD', action: downloadScene),
        buildButton(child: 'LOAD', action: uploadScene),
        buildButton(child: 'EDIT', action: toggleWindowEnabledScene),
        buildButton(child: 'MAP SIZE', action: toggleWindowEnabledCanvasSize),
        buildButton(child: 'GENERATE', action: windowEnabledGenerate.toggle),
        if (engine.isLocalHost)
          buildButton(child: 'SAVE', action: saveScene),
      ],
    );
  }

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
                buildText('Close', onPressed: toggleWindowEnabledCanvasSize),
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
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Row_Start),
                      iconType: IconType.Plus,
                      hint: 'Add Row',
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 40,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Row_Start),
                      iconType: IconType.Minus,
                      hint: 'Remove Row',
                    ),
                    buildPositionedIconButton(
                      top: 0,
                      left: 150,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Column_Start),
                      iconType: IconType.Plus,
                      hint: 'Add Column',
                    ),
                    buildPositionedIconButton(
                      top: 20,
                      left: 160,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Column_Start),
                      iconType: IconType.Minus,
                      hint: 'Remove Column',
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 120,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Row_End),
                      iconType: IconType.Minus,
                      hint: 'Remove Row',
                    ),
                    buildPositionedIconButton(
                      top: 160,
                      left: 160,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Row_End),
                      iconType: IconType.Plus,
                      hint: 'Add Row',
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 0,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Column_End),
                      iconType: IconType.Plus,
                      hint: 'Add Column',
                    ),
                    buildPositionedIconButton(
                      top: 140,
                      left: 40,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Column_End),
                      iconType: IconType.Minus,
                      hint: 'Remove Column',
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 60,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Add_Z),
                      iconType: IconType.Plus,
                      hint: 'Add Z',
                    ),
                    buildPositionedIconButton(
                      top: 80,
                      left: 100,
                      action: () => sendClientRequestModifyCanvasSize(RequestModifyCanvasSize.Remove_Z),
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
                buildText('Close', onPressed: windowEnabledGenerate.toggle),
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
                buildText('Close', onPressed: toggleWindowEnabledScene),
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
            child: amulet.ui.buildImageGameObject(objectType),
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
      environment.windTypeAmbient,
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
              color: colors.orange,
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
        color: colors.brown02,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWatch(options.gameRunning, (gameRunning) {
              return buildText('Game Running: $gameRunning', onPressed: () => toggleGameRunning);
            }),
            buildText ('Reset', onPressed: editSceneReset),
            buildText('Spawn AI', onPressed: editSceneSpawnAI),
            buildText('Clear Spawned AI',
                onPressed: editSceneClearSpawnedAI),
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
        sendClientRequestSetBlock(
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
      engine.renderExternalCanvas(
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
      engine.renderExternalCanvas(
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
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Left,
              );
              return;
            }
            if (row == 0 && column == 1){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Center,
              );
              return;
            }
            if (row == 0 && column == 0){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Top_Right,
              );
              return;
            }

            if (row == 1 && column == 2){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Left,
              );
              return;
            }
            if (row == 1 && column == 1){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Center,
              );
              return;
            }
            if (row == 1 && column == 0){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Center_Right,
              );
              return;
            }

            if (row == 2 && column == 2){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Left,
              );
              return;
            }
            if (row == 2 && column == 1){
              sendClientRequestSetBlock(
                index: nodeSelectedIndex.value,
                type: nodeSelectedType.value,
                orientation: NodeOrientation.Column_Bottom_Center,
              );
              return;
            }
            if (row == 2 && column == 0){
              sendClientRequestSetBlock(
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
                          child: buildText('X',
                              onPressed: sendGameObjectRequestDeselect
                          ),
                        ),
                        Center(child: amulet.ui.buildImageGameObject(subType)),
                        height8,
                        buildButtonDuplicate(),
                        height8,
                        buildText(GameObjectType.getName(type), size: 22),
                        height8,
                        buildText(
                            GameObjectType.getNameSubType(type, subType),
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

  Widget buildEditorMenu(IsometricEditorTab activeEditTab) => GSContainer(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: IsometricEditorTab.values
          .map((editTab) => buildButton(
        child: editTab.name,
        width: 150,
        color: activeEditTab == editTab
            ? colors.brownDark
            : colors.brownLight,
        action: () => this.editTab.value = editTab,
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
                color: mouseOver ? Colors.black38.value : Colors.white.value,
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
      buildText('x', onPressed: actionGameDialogClose);

  Widget buildButtonDuplicate() => buildText('Duplicate', onPressed: sendGameObjectRequestDuplicate);

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
              .value!.colorType =
          ((gameObject.value!.colorType +
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

}





