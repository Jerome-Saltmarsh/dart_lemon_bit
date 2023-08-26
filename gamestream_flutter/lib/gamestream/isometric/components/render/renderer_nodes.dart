import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_math/src.dart';

import 'constants/node_src.dart';

class RendererNodes extends RenderGroup {

  static const Node_Size = 48.0;
  static const Node_Size_Half = 24.0;
  static const Node_Size_Third = 16.0;
  static const Node_Size_Sixth = 8.0;
  static const Node_Sprite_Width = 48.0;
  static const Cell_Size = 16.0;
  static const Cell_Size_Half = 8.0;
  static const Cell_Top_Width =  8.0;
  static const Cell_Top_Height =  8.0;
  static const Cell_South_Width = 8.0;
  static const Cell_South_Height = 8.0;
  static const Cell_West_Width = 8.0;
  static const Cell_West_Height = 8.0;
  static const Node_South_Height = 24.0;

  static const mapNodeTypeToSrcY = <int, double>{
    NodeType.Brick: 1760,
    NodeType.Grass: 1808,
    NodeType.Soil: 1856,
    NodeType.Wood: 1904,
  };

  var lightningColor = 0;
  var previousNodeTransparent = false;
  var lightningFlashing = false;
  var totalNodes = 0;
  var totalRows = 0;
  var totalColumns = 0;
  var totalZ = 0;
  var nodeSideTopSrcX = 0.0;
  var nodeSideWestSrcX = 0.0;
  var nodeSize = Node_Size;
  var nodeScale = 1.0;
  var plainIndex = 0;
  var plainStartRow = 0;
  var plainStartColumn = 0;
  var plainStartZ = 0;
  var totalPlains = 0;
  var orderShiftY = 151.0;


  // VARIABLES
  var previousVisibility = 0;

  var playerRenderRow = 0;
  var playerRenderColumn = 0;

  var indexShow = 0;
  var indexRow = 0;
  var indexColumn = 0;
  var indexZ = 0;
  var nodesStartRow = 0;
  var nodeStartColumn = 0;
  var nodesMaxZ = 0;
  var nodesMinZ = 0;
  var currentNodeZ = 0;
  var row = 0;
  var column = 0;
  var z = 0;
  var currentNodeDstX = 0.0;
  var currentNodeDstY = 0.0;
  var currentNodeIndex = 0;

  var offscreenNodesTop = 0;
  var offscreenNodesRight = 0;
  var offscreenNodesBottom = 0;
  var offscreenNodesLeft = 0;

  var onscreenNodes = 0;
  var offscreenNodes = 0;

  var playerProjection = 0;

  var playerZ = 0;
  var playerRow = 0;
  var playerColumn = 0;

  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var screenLeft = 0.0;

  var visited2DStack = Uint16List(0);
  var visited2DStackIndex = 0;
  var visited2D = <bool>[];
  var island = <bool>[];
  var zMin = 0;
  var visible3D = <bool>[];
  var visible3DStack = Uint16List(10000);
  var visible3DIndex = 0;
  var playerIndex = 0;
  var transparencyGrid = <bool>[];
  var transparencyGridStack = Uint16List(0);
  var transparencyGridStackIndex = 0;
  var currentNodeWithinIsland = false;
  var atlasNodesLoaded = false;

  late Uint8List nodeTypes;
  late Uint32List nodeColors;
  late Uint8List nodeOrientations;

  late final ui.Image atlasNodes;

  @override
  void onComponentReady() {
    atlasNodes = images.atlas_nodes;
    atlasNodesLoaded = true;
  }

  int get colorCurrent => nodeColors[currentNodeIndex];

  int get colorAbove {

    if (lightningFlashing) {
      return lightningColor;
    }

    final nodeAboveIndex = currentNodeIndex + scene.area;
    if (nodeAboveIndex >= totalNodes)
      return scene.ambientColor;
    return nodeColors[nodeAboveIndex];
  }

  int get colorWest {
    if (column + 1 >= totalColumns){
      return scene.ambientColor;
    }
    return nodeColors[currentNodeIndex + 1];
  }

  int get colorEast {
    if (column - 1 < 0){
      return scene.ambientColor;
    }
    return nodeColors[currentNodeIndex - 1];
  }

  int get colorNorth {
    if (row - 1 < 0) {
      return scene.ambientColor;
    }
    return nodeColors[currentNodeIndex - totalColumns];
  }

  int get colorSouth {
    if (row + 1 >= totalRows) {
      return scene.ambientColor;
    }
    return nodeColors[currentNodeIndex + totalColumns];
  }

  int get currentNodeOrientation => nodeOrientations[currentNodeIndex];

  int get wind => environment.wind.value;

  int get currentNodeVariation => scene.nodeVariations[currentNodeIndex];

  int get renderNodeOrientation => nodeOrientations[currentNodeIndex];

  int get renderNodeBelowIndex => currentNodeIndex - scene.area;

  int get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? scene.nodeVariations[renderNodeBelowIndex] : currentNodeVariation;

  int get renderNodeBelowColor => scene.getNodeColorAtIndex(currentNodeIndex - scene.area);

  int get nodeTypeBelow => scene.getTypeBelow(currentNodeIndex);

  @override
  void renderFunction() {
    engine.bufferImage = atlasNodes;
    previousNodeTransparent = false;
    renderPlain();
    return;


    // final playerInsideIsland = gamestream.player.playerInsideIsland;
    // final nodeTypes = scene.nodeTypes;
    //
    // while (
    //     column >= 0            &&
    //     row    <= nodesRowsMax &&
    //     currentNodeDstX   <= screenRight
    // ){
    //   currentNodeType = nodeTypes[currentNodeIndex];
    //   if (currentNodeType != NodeType.Empty){
    //     if (!playerInsideIsland){
    //       renderCurrentNode();
    //     } else {
    //       currentNodeWithinIsland = island[row * scene.totalColumns + column];
    //       if (!currentNodeWithinIsland){
    //         renderCurrentNode();
    //       } else if (currentNodeZ <= playerZ || visible3D[currentNodeIndex]) {
    //         renderCurrentNode();
    //       }
    //     }
    //   }
    //   if (row + 1 > nodesRowsMax) return;
    //   row++;
    //   column--;
    //   currentNodeIndex += nodesGridTotalColumnsMinusOne;
    //   currentNodeDstX += IsometricConstants.Sprite_Width;
    // }
  }

  void onPlainIndexChanged(){
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final height = scene.totalZ;
    final rowMax = rows - 1;
    final columnMax = columns - 1;
    final heightMax = height - 1;
    final index = plainIndex;
    plainStartRow = clamp(index - (height + columns), 0, rowMax);
    plainStartColumn = clamp(index - height + 1, 0, columnMax);
    plainStartZ = clamp(index, 0, heightMax);
    order = (plainStartRow * Node_Size) + (plainStartColumn * Node_Size) + (plainStartZ * Node_Height) + orderShiftY;
  }

  void renderPlain(){

    final height = scene.totalZ;
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final rowMax = rows;
    final columnMax = columns - 1;
    final heightMax = height - 1;
    final shiftRight = columns - 1;
    final index = plainIndex;

    var lineRow = clamp(index - (height + columns), 0, rowMax);
    var lineColumn = clamp(index - height + 1, 0, columnMax);
    var lineZ = clamp(index, 0, heightMax);

    plainStartRow = lineRow;
    plainStartColumn = lineColumn;
    plainStartZ = lineZ;

    column = lineColumn;
    row = lineRow;

    while (lineZ >= 0) {
      z = lineZ;
      currentNodeDstY = ((row + column) * Node_Size_Half) - (lineZ * Node_Height);

      if (currentNodeDstY > screenTop) {
        if (currentNodeDstY > screenBottom){
          break;
        }

        currentNodeIndex = scene.getIndexZRC(lineZ, lineRow, lineColumn);
        currentNodeDstX = (row - column) * Node_Size_Half;

        while (true) {
          if (currentNodeDstX > screenLeft &&
              currentNodeDstX < screenRight
          ) {
            final nodeType = nodeTypes[currentNodeIndex];
            if (nodeType != NodeType.Empty){
              renderCurrentNodeIndex(
                currentNodeIndex: currentNodeIndex,
                dstX: currentNodeDstX,
                dstY: currentNodeDstY,
              );
            }
          }

          row++;
          column--;

          if (column < 0 || row >= rowMax)
            break;

          currentNodeIndex += shiftRight;
          currentNodeDstX += Node_Sprite_Width;
        }
      }

      // TODO check logic
      if (lineColumn <= rowMax){
        lineColumn++;
      } else {
        lineRow++;
      }

      column = lineColumn;
      row = lineRow;
      lineZ--;
      currentNodeDstY += Node_Height;
    }

    plainIndex++;

    if (plainIndex < totalPlains) {
      onPlainIndexChanged();
      return;
    }

    end();
  }

  @override
  void updateFunction() {

    // currentNodeZ++;
    // if (currentNodeZ > nodesMaxZ) {
    //   currentNodeZ = 0;
    //   nodesShiftIndexDown();
    //   if (!remaining) return;
    //   nodesCalculateMinMaxZ();
    //   if (!remaining) return;
    //
    //   assert (column >= 0);
    //   assert (row >= 0);
    //   assert (row < totalRows);
    //   assert (column < totalColumns);
    //
    //   trimLeft();
    //
    //   while (currentNodeRenderY > screenBottom) {
    //     currentNodeZ++;
    //     if (currentNodeZ > nodesMaxZ) {
    //       remaining = false;
    //       return;
    //     }
    //   }
    // } else {
    //   assert (nodesStartRow < totalRows);
    //   assert (column < totalColumns);
    //   row = nodesStartRow;
    //   column = nodeStartColumn;
    // }
    //
    // currentNodeIndex = (currentNodeZ * area) + (row * totalColumns) + column;
    // assert (currentNodeZ >= 0);
    // assert (row >= 0);
    // assert (column >= 0);
    // assert (currentNodeIndex >= 0);
    // assert (currentNodeZ < totalZ);
    // assert (row < totalRows);
    // assert (column < totalColumns);
    // assert (currentNodeIndex < totalNodes);
    // currentNodeDstX = (row - column) * Node_Size_Half;
    // currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    // currentNodeType = nodeTypes[currentNodeIndex];
    // // orderZ = currentNodeZ;
    // order = (row + column).toDouble() - 0.5;
  }

  @override
  int getTotal() => atlasNodesLoaded ? scene.totalNodes : 0;

  @override
  void reset() {
    lightningFlashing = environment.lightningFlashing.value;

    if (lightningFlashing) {
      final lightningColorMax = lerpColors(colors.white.value, 0, environment.brightness);
      final ambientBrightness = lerpColors(scene.ambientColor, 0, environment.brightness);
      lightningColor = lerpColors(ambientBrightness, lightningColorMax, environment.lightningFlashing01.value * goldenRatio_0618);
    }

    nodeColors = scene.nodeColors;
    nodeTypes = scene.nodeTypes;
    totalNodes = scene.totalNodes;
    totalRows = scene.totalRows;
    totalColumns = scene.totalColumns;
    totalZ = scene.totalZ;
    nodeScale = 1.0;
    nodeSize = Node_Size / nodeScale;
    nodeSideTopSrcX = 0.0;
    nodeSideWestSrcX = 49.0;


    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final height = scene.totalZ;
    totalPlains = columns + rows + height - 2;
    plainIndex = 0;
    onPlainIndexChanged();
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    offscreenNodes = 0;
    onscreenNodes = 0;
    nodesMinZ = 0;
    currentNodeZ = 0;
    playerZ = player.position.indexZ;
    playerRow = player.position.indexRow;
    playerColumn = player.position.indexColumn;
    playerRenderRow = playerRow - (player.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (player.position.indexZ ~/ 2);
    playerProjection = playerIndex % scene.projection;
    scene.offscreenNodes = 0;
    scene.onscreenNodes = 0;

    screenRight = engine.Screen_Right + Node_Size;
    screenLeft = engine.Screen_Left - Node_Size;
    screenTop = engine.Screen_Top - 72;
    screenBottom = engine.Screen_Bottom + 72;

    currentNodeDstX = (row - column) * Node_Size_Half;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeIndex = (currentNodeZ * scene.area) + (row * scene.totalColumns) + column;
    currentNodeWithinIsland = false;

    updateTransparencyGrid();
    updateHeightMapPerception();

    total = getTotal();
    index = 0;
    remaining = total > 0;
    scene.resetNodeColorStack();
    scene.resetNodeAmbientStack();
    scene.applyEmissions();
    render.highlightAimTargetEnemy();
  }

  void increaseOrderShiftY(){
    orderShiftY++;
  }

  void decreaseOrderShiftY(){
    orderShiftY--;
  }

  void updateTransparencyGrid() {

    if (transparencyGrid.length != scene.projection) {
      transparencyGrid = List.generate(scene.projection, (index) => false, growable: false);
      transparencyGridStack = Uint16List(scene.projection);
    } else {
      for (var i = 0; i < transparencyGridStackIndex; i++){
        transparencyGrid[transparencyGridStack[i]] = false;
      }
    }
    transparencyGridStackIndex = 0;

    const r = 2;

    for (var z = playerZ; z <= playerZ + 1; z++){
      if (z >= scene.totalZ) break;
      final indexZ = z * scene.area;
      for (var row = playerRow - r; row <= playerRow + r; row++){
        if (row < 0) continue;
        if (row >= scene.totalRows) break;
        final rowIndex = row * scene.totalColumns + indexZ;
        for (var column = playerColumn - r; column <= playerColumn + r; column++){
          if (column < 0) continue;
          if (column >= scene.totalColumns) break;
          final index = rowIndex + column;
          final projectionIndex = index % scene.projection;
          transparencyGrid[projectionIndex] = true;
          transparencyGridStack[transparencyGridStackIndex] = projectionIndex;
          transparencyGridStackIndex++;
        }
      }
    }
  }

  void updateHeightMapPerception() {

    if (visible3D.length != scene.totalNodes) {
      visible3D = List.generate(scene.totalNodes, (index) => false);
      visible3DIndex = 0;
    }

    for (var i = 0; i < visible3DIndex; i++){
      visible3D[visible3DStack[i]] = false;
    }
    visible3DIndex = 0;

    if (visited2D.length != scene.area) {
      visited2D = List.generate(scene.area, (index) => false, growable: false);
      visited2DStack = Uint16List(scene.area);
      visited2DStackIndex = 0;
      island = List.generate(scene.area, (index) => false, growable: false);
    } else {
      for (var i = 0; i < visited2DStackIndex; i++){
        final j = visited2DStack[i];
        visited2D[j] = false;
        island[j] = false;
      }
    }
    visited2DStackIndex = 0;

    final height = scene.heightMap[player.areaNodeIndex];

    if (player.indexZ <= 0) {
      zMin = 0;
      player.playerInsideIsland = false;
      return;
    }

    player.playerInsideIsland = player.indexZ < height;

    if (!player.playerInsideIsland) {
      ensureIndexPerceptible(player.nodeIndex);
    }

    if (mouse.inBounds){
      ensureIndexPerceptible(mouse.nodeIndex);
    }

    zMin = max(player.indexZ - 1, 0);
    visit2D(player.areaNodeIndex);
  }

  void ensureIndexPerceptible(int index){
    var projectionRow     = scene.getIndexRow(index);
    var projectionColumn  = scene.getIndexColumn(index);
    var projectionZ       = scene.getIndexZ(index);

    while (true) {
      projectionZ += 2;
      projectionColumn++;
      projectionRow++;
      if (projectionZ >= scene.totalZ) return;
      if (projectionColumn >= scene.totalColumns) return;
      if (projectionRow >= scene.totalRows) return;
      final projectionIndex =
          (projectionRow * scene.totalColumns) + projectionColumn;
      final projectionHeight = scene.heightMap[projectionIndex];
      if (projectionZ > projectionHeight) continue;
      player.playerInsideIsland = true;
      zMin = max(player.indexZ - 1, 0);
      visit2D(projectionIndex);
      return;
    }
  }

  void addVisible3D(int i){
    visible3D[i] = true;
    visible3DStack[visible3DIndex] = i;
    visible3DIndex++;
  }

  void visit2D(int i) {
     if (visited2D[i]) return;
     visited2D[i] = true;
     visited2DStack[visited2DStackIndex] = i;
     visited2DStackIndex++;
     if (scene.heightMap[i] <= zMin) return;
     island[i] = true;

     var searchIndex = i + (scene.area * player.indexZ);
     addVisible3D(searchIndex);

     var spaceReached = nodeOrientations[searchIndex] == NodeOrientation.None;
     var gapReached = false;

     while (true) {
       searchIndex += scene.area;
        if (searchIndex >= scene.totalNodes) break;
        final nodeOrientation = nodeOrientations[searchIndex];
        if (nodeOrientation == NodeOrientation.Half_Vertical_Top) break;
        if (nodeOrientation == NodeOrientation.Half_Vertical_Center) break;
        if (nodeOrientation == NodeOrientation.Half_Vertical_Bottom) break;
        if (!spaceReached){
           spaceReached = nodeOrientation == NodeOrientation.None;
        } else

        if (nodeOrientation != NodeOrientation.None)  break;

        if (!gapReached) {
          gapReached =
              NodeOrientation.isHalf(nodeOrientation)     ||
              NodeOrientation.isCorner(nodeOrientation)   ||
              NodeOrientation.isColumn(nodeOrientation)   ;
        } else if (
          NodeOrientation.slopeSymmetric.contains(nodeOrientation) ||
          NodeOrientation.isSlopeCornerInner(nodeOrientation) ||
          NodeOrientation.isSlopeCornerOuter(nodeOrientation)
        ) break;

        addVisible3D(searchIndex);
     }
     searchIndex = i + (scene.area * player.indexZ);
     while (true) {
       addVisible3D(searchIndex);
       if (blocksBeamVertical(searchIndex)) break;
       searchIndex -= scene.area;
       if (searchIndex < 0) break;
     }

     final iAbove = i - scene.totalColumns;
     if (iAbove > 0) {
       visit2D(iAbove);
     }
     final iBelow = i + scene.totalColumns;
     if (iBelow < scene.area) {
       visit2D(iBelow);
     }

     final row = i % scene.totalRows;
     if (row - 1 >= 0) {
       visit2D(i - 1);
     }
     if (row + 1 < scene.totalRows){
       visit2D(i + 1);
     }
  }

  int getProjectionIndex(int index){
    return index % scene.projection;
  }

  bool nodeTypeBlocks(int nodeType){
    if (nodeType == NodeType.Window) return false;
    if (nodeType == NodeType.Shopping_Shelf) return false;
    if (nodeType == NodeType.Wooden_Plank) return false;
    if (nodeType == NodeType.Boulder) return false;
    return true;
  }

  bool blocksBeamHorizontal(int index, int dirRow, int dirColumn){
    assert (dirRow == 0 || dirColumn == 0);
    final nodeOrientation = nodeOrientations[index];
    if (nodeOrientation == NodeOrientation.None) return false;
    if (nodeOrientation == NodeOrientation.Solid) return true;
    if (nodeOrientation == NodeOrientation.Radial) return false;
    if (nodeOrientation == NodeOrientation.Half_Vertical_Bottom) return false;
    if (NodeOrientation.isColumn(nodeOrientation)) return false;
    if (NodeOrientation.isCorner(nodeOrientation)) return false;

    if (NodeOrientation.isHalf(nodeOrientation)){
      if (dirRow != 0){
        return nodeOrientation == NodeOrientation.Half_North || nodeOrientation == NodeOrientation.Half_South;
      }
      return nodeOrientation == NodeOrientation.Half_East || nodeOrientation == NodeOrientation.Half_West;
    }

    final nodeType = scene.nodeTypes[index];
    if (nodeType == NodeType.Window) return false;
    if (nodeType == NodeType.Shopping_Shelf) return false;
    if (nodeType == NodeType.Wooden_Plank) return false;
    if (nodeType == NodeType.Boulder) return false;

    return true;
  }

  bool blocksBeamVertical(int index){
    final nodeOrientation = nodeOrientations[index];
    if (nodeOrientation == NodeOrientation.None) return false;
    if (NodeOrientation.isHalf(nodeOrientation)) return false;
    if (NodeOrientation.isRadial(nodeOrientation)) return false;
    if (NodeOrientation.isColumn(nodeOrientation)) return false;
    if (NodeOrientation.isCorner(nodeOrientation)) return false;
    return true;
  }

  void nodesSetStart(){
    nodesStartRow = clamp(row, 0, scene.totalRows - 1);
    nodeStartColumn = clamp(column, 0, scene.totalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < scene.totalRows);
    assert (nodeStartColumn < scene.totalColumns);
  }

  void renderNodeTorch(){
    final dstX = currentNodeDstX;
    final dstY = currentNodeDstY - 16;
    const Src_X_Plain = 1294.0;
    const Src_X_Grassy = 1311.0;
    final srcX = nodeTypeBelow == NodeType.Grass ? Src_X_Grassy : Src_X_Plain;

    renderCustomNode(
        srcX: srcX,
        srcY: 304,
        srcWidth: 16,
        srcHeight: 34,
        dstX: dstX - 8,
        dstY: dstY + 16,
        color: 0,
    );

    render.flame(dstX: dstX, dstY: dstY + 4, scale: 0.7);
  }

  bool assertOnScreen(){
    if (currentNodeDstX < screenLeft){
      offscreenNodesLeft++;
      return true;
    }
    if (currentNodeDstX > screenRight){
      offscreenNodesRight++;
      return true;
    }
    if (currentNodeDstY < screenTop){
      offscreenNodesTop++;
      return true;
    }
    if (currentNodeDstY > screenBottom){
      offscreenNodesBottom++;
      return true;
    }

    return true;
  }

  bool get currentNodeTransparent {
    if (currentNodeZ <= playerZ) return false;
    final currentNodeProjection = currentNodeIndex % scene.projection;
    if (!transparencyGrid[currentNodeProjection]) return false;

    final nodeOrientation = currentNodeOrientation;

    if (nodeOrientation == NodeOrientation.Half_North || nodeOrientation == NodeOrientation.Half_South){
      return row >= playerRow;
    }
    if (nodeOrientation == NodeOrientation.Half_East || nodeOrientation == NodeOrientation.Half_West){
      return column >= playerColumn;
    }

    return row >= playerRow && column >= playerColumn;
  }

  void renderCurrentNodeIndex({
    required int currentNodeIndex,
    required double dstX,
    required double dstY,
  }) {

    // if (currentNodeWithinIsland && currentNodeZ >= playerZ + 2) return;
    // final transparent = currentNodeTransparent;
    // if (previousNodeTransparent != transparent) {
    // TODO use engine.color.opacity = 0.5;
    //   previousNodeTransparent = transparent;
    //   engine.bufferImage = transparent ? images.atlas_nodes_transparent : images.atlas_nodes;
    // }

    final nodeType = nodeTypes[currentNodeIndex];
    final nodeOrientation = nodeOrientations[currentNodeIndex];


    if (mapNodeTypeToSrcY.containsKey(nodeType)){

      renderDynamic(
        nodeType:nodeType,
        nodeOrientation: nodeOrientation,
        dstX: dstX,
        dstY: dstY,
        colorAbove: scene.getColorAbove(currentNodeIndex),
        colorWest: scene.getColorWest(currentNodeIndex),
        colorSouth: scene.getColorSouth(currentNodeIndex),
      );
      return;
    }

    switch (nodeType) {

      case NodeType.Bricks_Red:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_13);
        return;
      case NodeType.Bricks_Brown:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_14);
        return;
      case NodeType.Water:
        renderNodeWater();
        break;
      case NodeType.Dust:
        renderNodeDust();
        break;
      case NodeType.Rain_Falling:
        renderNodeRainFalling();
        return;
      case NodeType.Rain_Landing:
        renderNodeRainLanding();
        return;
      case NodeType.Sandbag:
        renderStandardNode(
          srcX: 539,
          srcY: 0,
        );
        break;
      case NodeType.Concrete:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_8);
        return;
      case NodeType.Metal:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_4);
        return;
      case NodeType.Road:
        renderNodeTemplateShadedOffset(IsometricConstants.Sprite_Width_Padded_9, offsetY: 7);
        return;
      case NodeType.Tree_Bottom:
        renderNodeTreeBottom();
        break;
      case NodeType.Tree_Top:
        renderNodeTreeTop();
        break;
      case NodeType.Scaffold:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_15);
        break;
      case NodeType.Road_2:
        renderNodeShadedOffset(srcX: 1490, srcY: 305, offsetX: 0, offsetY: 7);
        return;
      case NodeType.Wooden_Plank:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_10);
        return;
      case NodeType.Torch:
        renderNodeTorch();
        break;
      case NodeType.Torch_Blue:
        renderCustomNode(
          srcX: 1328,
          srcY: 306,
          srcWidth: 14,
          srcHeight: 28,
          dstX: currentNodeDstX - 7,
          dstY: currentNodeDstY + 4,
          color: colorCurrent,
        );

        renderCustomNode(
            srcX: 1343 + (animation.frame6 * 16),
            srcY: 306,
            srcWidth: 14,
            srcHeight: 32,
            dstX: currentNodeDstX - 8,
            dstY: currentNodeDstY - 16,
            color: 0,
        );
        break;
      case NodeType.Torch_Red:
        renderCustomNode(
          srcX: 1328,
          srcY: 306,
          srcWidth: 14,
          srcHeight: 28,
          dstX: currentNodeDstX - 7,
          dstY: currentNodeDstY + 4,
          color: colorCurrent,
        );

        renderCustomNode(
            srcX: 1343 + (animation.frame6 * 16),
            srcY: 339,
            srcWidth: 14,
            srcHeight: 32,
            dstX: currentNodeDstX - 8,
            dstY: currentNodeDstY - 16,
            color: 0,
        );
        break;
      case NodeType.Shopping_Shelf:
        renderNodeShoppingShelf();
        break;
      case NodeType.Bookshelf:
        renderNodeBookShelf();
        break;
      case NodeType.Grass_Long:
        renderNodeGrassLong();
        break;
      case NodeType.Tile:
        renderNodeTemplateShaded(588);
        return;
      case NodeType.Glass:
        renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_16);
        return;
      case NodeType.Bau_Haus:
        const index_grass = 6;
        const srcX = IsometricConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
      case NodeType.Sunflower:
        renderStandardNode(
          srcX: 1753.0,
          srcY: 867.0,
        );
        return;
      case NodeType.Fireplace:
        renderFireplace();
        return;
      case NodeType.Boulder:
        renderBoulder();
        return;
      case NodeType.Oven:
        renderStandardNode(
          srcX: AtlasNodeX.Oven,
          srcY: AtlasNodeY.Oven,
        );
        return;
      case NodeType.Chimney:
        renderStandardNode(
          srcX: AtlasNode.Chimney_X,
          srcY: AtlasNode.Node_Chimney_Y,
        );
        return;
      case NodeType.Window:
        renderNodeWindow();
        break;
      case NodeType.Table:
        renderStandardNode(
          srcX: AtlasNode.Table_X,
          srcY: AtlasNode.Node_Table_Y,
        );
        return;
      case NodeType.Respawning:
        return;
      default:
        throw Exception('renderNode(index: ${currentNodeIndex}, orientation: ${NodeOrientation.getName(nodeOrientations[currentNodeIndex])}');
    }
  }

  void renderFireplace() => engine.renderSprite(
      image: atlasNodes,
      srcX: AtlasNode.Src_Fireplace_X,
      srcY: AtlasNode.Src_Fireplace_Y + (animation.frame6 * AtlasNode.Src_Fireplace_Height),
      srcWidth: 48,
      srcHeight: 72,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY + 12,
      color: 0,
    );

  void renderBoulder() {
    final dstX = currentNodeDstX;
    final dstY = currentNodeDstY + 14;

    engine.renderSprite(
      image: atlasNodes,
      srcX: Src_X_Sprite_Boulder_West,
      srcY: Src_Y_Sprite_Boulder,
      srcWidth: Src_Width_Sprite_Boulder,
      srcHeight: Src_Height_Sprite_Boulder,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
    );

    engine.renderSprite(
      image: atlasNodes,
      srcX: Src_X_Sprite_Boulder_South,
      srcY: Src_Y_Sprite_Boulder,
      srcWidth: Src_Width_Sprite_Boulder,
      srcHeight: Src_Height_Sprite_Boulder,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
    );

  }

  void renderDynamic({
    required int nodeType,
    required int nodeOrientation,
    required double dstX,
    required double dstY,
    required int colorAbove,
    required int colorSouth,
    required int colorWest,
  }) {
    final srcY = mapNodeTypeToSrcY[nodeType] ??
        (throw Exception('RendererNodes.mapNodeTypeToSrcY(nodeType: $nodeType)'));

    switch (nodeOrientation) {
      case NodeOrientation.Solid:
        renderDynamicSolid(
          dstX: dstX,
          dstY: dstY,
          srcY: srcY,
          srcX: currentNodeVariation < 126 ? 0.0 : 128.0,
          colorAbove: colorAbove,
          colorSouth: colorSouth,
          colorWest: colorWest,
        );
        break;
      case NodeOrientation.Half_West:
        renderDynamicHalfWest(
          srcY: srcY,
          colorWest: colorWest,
          colorSouth: colorSouth,
          colorAbove: colorAbove,
          dstX: dstX,
          dstY: dstY,
        );
        break;
      case NodeOrientation.Half_East:
        renderDynamicHalfEast(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorWest: colorWest,
          colorSouth: colorSouth,
          colorAbove: colorAbove,
        );
        break;
      case NodeOrientation.Half_South:
        renderDynamicHalfSouth(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorWest: colorWest,
          colorSouth: colorSouth,
          colorAbove: colorAbove,
        );
        break;
      case NodeOrientation.Half_North:
        renderDynamicHalfNorth(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorSouth: colorSouth,
          colorWest: colorWest,
          colorAbove: colorAbove,
        );
        break;

      case NodeOrientation.Corner_South_East:
        renderCornerSouthEast(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
        );
        break;

      case NodeOrientation.Corner_North_East:
        renderCornerNorthEast(srcY);
        break;

      case NodeOrientation.Corner_North_West:
        renderCornerNorthWest(srcY);
        break;

      case NodeOrientation.Corner_South_West:
        renderCornerSouthWest(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorWest: colorWest,
          colorSouth: colorSouth,
          colorAbove: colorAbove,
        );
        break;

      case NodeOrientation.Slope_East:
        renderSlopeEast(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorAbove: colorAbove,
          colorSouth: colorSouth,
          colorWest: colorWest,
        );
        break;

      case NodeOrientation.Slope_West:
        renderSlopeWest(srcY);
        break;

      case NodeOrientation.Slope_South:
        renderSlopeSouth(srcY: srcY);
        break;

      case NodeOrientation.Slope_North:
        renderSlopeNorth(srcY: srcY);
        break;
    }
  }

  void renderNodeShoppingShelf() {
     if (currentNodeVariation == 0){
      renderStandardNode(
        srcX: 1392,
        srcY: 160,
      );
    } else {
      renderStandardNode(
        srcX: 1441,
        srcY: 160,
      );
    }
  }

  void renderNodeBookShelf() {
    renderStandardNode(
      srcX: 1392,
      srcY: 233,
    );
  }

  void renderNodeGrassLong() {
    final frame = wind == WindType.Calm
        ? 0
        : (((row - column) + animation.frame6) % 6);
    const Src_X = 957.0;
    const Src_Y = 305.0;
    const Src_Width = 48.0;
    const Src_Height = 72.0;

    final srcX = Src_X + (frame * Src_Width);
    final dstX = currentNodeDstX - 24;
    final dstY = currentNodeDstY - 24;

    renderCustomNode(
      srcX: srcX,
      srcY: Src_Y,
      srcWidth: Src_Width,
      srcHeight: Src_Height,
      dstX: dstX,
      dstY: dstY,
      color: colorAbove,
    );

    renderCustomNode(
      srcX: srcX,
      srcY: Src_Y + Src_Height,
      srcWidth: Src_Width,
      srcHeight: Src_Height,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
    );

    renderCustomNode(
      srcX: srcX,
      srcY: Src_Y + Src_Height + Src_Height,
      srcWidth: Src_Width,
      srcHeight: Src_Height,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
    );
  }

  void renderNodeRainLanding() {
    if (currentNodeIndex > scene.area && scene.nodeTypes[currentNodeIndex - scene.area] == NodeType.Water){
      engine.renderSprite(
        image: atlasNodes,
        srcX: AtlasNode.Node_Rain_Landing_Water_X,
        srcY: 72.0 * ((animation.frame + currentNodeVariation) % 8), // TODO Expensive Operation
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + animation.frameWaterHeight + 14,
        anchorY: 0.3,
        color: colorCurrent,
      );
      return;
    }
    renderStandardNode(
      srcX: environment.srcXRainLanding,
      srcY: 72.0 * ((animation.frame + currentNodeVariation) % 6), // TODO Expensive Operation
    );
    if (options.renderRainFallingTwice){
      renderNodeRainFalling();
    }
  }

  void renderNodeRainFalling() {
    final row =  (environment.rainType.value == RainType.Heavy ? 3 : 0) + environment.wind.value;
    final column = (animation.frame + currentNodeVariation) % 6;

    renderStandardNode(
      srcX: 1596 + (column * 48),
      srcY: 1306 + (row * 72),
    );
  }

  void renderNodeTreeTop() => renderNodeBelowVariation == 0 ? renderTreeTopPine() : renderNodeTreeTopOak();

  void renderNodeTreeBottom() => currentNodeVariation == 0 ? renderTreeBottomPine() : renderTreeBottomOak();

  void renderNodeTreeTopOak(){
    final treeAnimation = animation.treeAnimation;
    final shift = treeAnimation[((row - column) + animation.frame) % treeAnimation.length] * wind;
    final shiftRotation = treeAnimation[((row - column) + animation.frame - 2) % treeAnimation.length] * wind;
    final dstX = currentNodeDstX + (shift * 0.5);
    final dstY = currentNodeDstY + 40;
    final rotation = shiftRotation * 0.0066;
    const anchorY = 0.82;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Top_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    // south
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Top_South,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeTopPine() {

    final treeAnimation = animation.treeAnimation;
    final shift = treeAnimation[((row - column) + animation.frame) % treeAnimation.length] * wind;
    final shiftRotation = treeAnimation[((row - column) + animation.frame - 2) % treeAnimation.length] * wind;
    final dstX = currentNodeDstX + (shift * 0.5);
    final dstY = currentNodeDstY + 40;
    final rotation = shiftRotation * 0.0066;
    const anchorY = 0.82;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Top_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    // south
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Top_South,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );

  }

  void renderTreeBottomOak() {

    final treeAnimation = animation.treeAnimation;
    final frame = row - column + 4;
    final shiftRotation = treeAnimation[(frame + animation.frame - 2) % treeAnimation.length] * wind;
    final dstX = currentNodeDstX;
    final dstY = currentNodeDstY + 32;
    final rotation = shiftRotation * 0.013;
    const anchorY = 0.72;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Bottom_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    // south
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Bottom_South,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeBottomPine() {
    final treeAnimation = animation.treeAnimation;
    final frame = row - column + 4;
    final shiftRotation = treeAnimation[(frame + animation.frame - 2) % treeAnimation.length] * wind;
    final dstX = currentNodeDstX;
    final dstY = currentNodeDstY + 32;
    final rotation = shiftRotation * 0.013;
    const anchorY = 0.72;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Bottom_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    // south
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Bottom_South,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderNodeTemplateShadedOffset(double srcX, {double offsetX = 0, double offsetY = 0}) {
    switch (currentNodeOrientation){
      case NodeOrientation.Solid:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_00,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;

      case NodeOrientation.Corner_North_East:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
        );

        return;
      case NodeOrientation.Corner_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Corner_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Corner_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Slope_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_03,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_04,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_05,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_06,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_07,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_08,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_09,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_10,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_11,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_12,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_13,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_14,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Radial:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_15,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -9 + offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -1 + offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: 2 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: -16 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -16 + offsetX,
          offsetY: 0 + offsetY,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 0 + offsetY,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 16 + offsetY,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 16 + offsetX,
          offsetY: 0 + offsetY,
        );
        return;
    }
  }

  void renderNodeTemplateShaded(double srcX) {
    switch (currentNodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_00,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_North_East:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16,
          offsetY: -8,
          srcWidth: 32,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
          srcWidth: 32,
        );
        return;
      case NodeOrientation.Corner_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Slope_North:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_03,
        );
        return;
      case NodeOrientation.Slope_East:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_04,
        );
        return;
      case NodeOrientation.Slope_South:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_05,
        );
        return;
      case NodeOrientation.Slope_West:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_06,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_07,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_08,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_09,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_10,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_11,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_12,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_13,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_14,
        );
        return;
      case NodeOrientation.Radial:
        renderStandardNode(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_15,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: -8,
          color: scene.nodeColors[currentNodeIndex + scene.area < scene.totalNodes ? currentNodeIndex + scene.area : currentNodeIndex],
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: -16,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -16,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: -8,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 0,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: 8,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 16,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 16,
          offsetY: 0,
        );
        return;
    }
  }


  void renderNodeWindow(){
    const srcX = 1508.0;
    switch (renderNodeOrientation) {
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + IsometricConstants.Sprite_Height_Padded,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + IsometricConstants.Sprite_Height_Padded,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80,
          offsetX: 8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      default:
        throw Exception('render_node_window(${NodeOrientation.getName(renderNodeOrientation)})');
    }
  }

  void renderNodeDust() =>
      engine.renderSprite(
        image: atlasNodes,
        srcX: 1552,
        srcY: 432 + (animation.frame6 * 72.0), // TODO Optimize
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: 0.3334,
        color: colorCurrent,
      );

  void renderNodeWater() =>
      engine.renderSprite(
        image: atlasNodes,
        srcX: AtlasNodeX.Water,
        srcY: AtlasNodeY.Water + (((animation.frameWater + ((row + column) * 3)) % 10) * 72.0), // TODO Optimize
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + animation.frameWaterHeight + 14,
        anchorY: 0.3334,
        color: colorCurrent,
      );

  void renderStandardNode({
    required double srcX,
    required double srcY,
  }) => engine.render(
        color: colorCurrent,
        srcLeft: srcX,
        srcTop: srcY,
        srcRight: srcX + IsometricConstants.Sprite_Width,
        srcBottom: srcY + IsometricConstants.Sprite_Height,
        scale: 1.0,
        rotation: 0,
        dstX: currentNodeDstX - (IsometricConstants.Sprite_Width_Half),
        dstY: currentNodeDstY - (IsometricConstants.Sprite_Height_Third),
    );


  void renderCustomNode({
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    required double dstX,
    required double dstY,
    required int color,
    double scale = 1.0,
  }) => engine.render(
    color: color,
    srcLeft: srcX,
    srcTop: srcY,
    srcRight: srcX + srcWidth,
    srcBottom: srcY + srcHeight,
    scale: scale,
    rotation: 0,
    dstX: dstX,
    dstY: dstY,
  );

  void renderNodeShadedCustom({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
    int? color,
    double? srcWidth,
    double? srcHeight
  }) => engine.render(
    color: color ?? colorCurrent,
    srcLeft: srcX,
    srcTop: srcY,
    srcRight: srcX + (srcWidth ?? IsometricConstants.Sprite_Width),
    srcBottom: srcY + (srcHeight ?? IsometricConstants.Sprite_Height),
    scale: 1.0,
    rotation: 0,
    dstX: currentNodeDstX - (IsometricConstants.Sprite_Width_Half) + offsetX,
    dstY: currentNodeDstY - (IsometricConstants.Sprite_Height_Third) + offsetY,
  );

  void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }) => engine.render(
    color: colorCurrent,
    srcLeft: srcX,
    srcTop: srcY,
    srcRight: srcX + IsometricConstants.Sprite_Width,
    srcBottom: srcY + IsometricConstants.Sprite_Height,
    scale: 1.0,
    rotation: 0,
    dstX: currentNodeDstX - (IsometricConstants.Sprite_Width_Half) + offsetX,
    dstY: currentNodeDstY - (IsometricConstants.Sprite_Height_Third) + offsetY,
  );

  void renderSlopeNorth({
    required double srcY,
  }) {

    renderCellTopColumn(
      srcY: srcY,
      dstX: -Node_Size_Half,
      dstY: -Cell_South_Height,
      color: colorAbove,
    );

    renderCellSouthColumn(
      srcY: srcY,
      dstX: -Cell_South_Width - Cell_South_Width,
      dstY: 0,
      color: colorCurrent,
    );

    renderCellTopColumn(
      srcY: srcY,
      dstX: -Node_Size_Half + Cell_South_Width,
      dstY: -Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellSouthColumn(
      srcY: srcY,
      dstX: -Cell_South_Width - Cell_South_Width + Cell_South_Width,
      dstY: Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellTopColumn(
      srcY: srcY,
      dstX: -Node_Size_Half + Cell_South_Width + Cell_South_Width,
      dstY: -Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellSouthColumn(
      srcY: srcY,
      dstX: -Cell_South_Width - Cell_South_Width + Cell_South_Width + Cell_South_Width,
      dstY: Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half,
      dstY: currentNodeDstY,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half,
      dstY: currentNodeDstY + Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half,
      dstY: currentNodeDstY + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );

    // column 2

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half + Cell_West_Width,
      dstY: currentNodeDstY + Cell_West_Height + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half + Cell_West_Width,
      dstY: currentNodeDstY + Cell_West_Height + Cell_West_Height + Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // column 3

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half + Cell_West_Width + Cell_West_Width,
      dstY: currentNodeDstY + Cell_West_Height + Cell_West_Height + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );
  }

  void renderCellTopColumn({
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
  }){

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX,
      dstY: currentNodeDstY + dstY,
      color: color,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX + Cell_Top_Width,
      dstY: currentNodeDstY + dstY - Cell_Top_Height,
      color: color,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX + Cell_Top_Width + Cell_Top_Width,
      dstY: currentNodeDstY + dstY - Cell_Top_Height - Cell_Top_Height,
      color: color,
    );
  }


  void renderCellSouthColumn({
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
  }) {
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX + dstX,
      dstY: currentNodeDstY + dstY,
      color: color,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX + dstX + Cell_South_Width,
      dstY: currentNodeDstY + dstY - Cell_South_Height,
      color: color,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX + dstX + Cell_South_Width + Cell_South_Width,
      dstY: currentNodeDstY + dstY - Cell_South_Height - Cell_South_Height,
      color: color,
    );
  }

  void renderSlopeSouth({required double srcY}) {

    renderNodeSideSouth(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width + Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width + Cell_Top_Width + Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );


    // row 2

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width + Cell_Top_Width - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width + Cell_Top_Width + Cell_Top_Width - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    // column 1

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_West_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_West_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_West_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // column 2

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_West_Width - Cell_West_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_West_Width - Cell_West_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // column 3

    renderCellWest(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_West_Width - Cell_West_Width - Cell_West_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // row 1

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width + Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Top_Width + Cell_Top_Width + Cell_Top_Width,
      dstY: currentNodeDstY + Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );
  }

  void renderSlopeWest(double srcY) {

    const dstX1 = Cell_Size_Half;
    const dstY1 = Node_Size_Half + Cell_South_Height -Cell_Size - Cell_Size_Half;

    const dstX2 = 0;
    const dstY2 = Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half;

    const dstX14 = -Cell_Size_Half;
    const dstY14 = Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half;

    // 1
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX1,
      dstY:  currentNodeDstY + dstY1,
      color: colorCurrent,
    );

    //2
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX2,
      dstY: currentNodeDstY + dstY2,
      color: colorCurrent,
    );

    //3
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Size_Half,
      dstY:  currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    //4
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY:  currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half,
      color: colorCurrent,
    );

    //5
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Size_Half,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    //6
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Size_Half - Cell_Size_Half,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    //7
    renderNodeSideWest(
      srcY: srcY,
      dstX: currentNodeDstX - Node_Size_Half,
      dstY: currentNodeDstY,
      color: colorWest,
    );

    //8
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height,
      color: colorSouth,
    );

    //9
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX + Cell_South_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height -Cell_South_Height,
      color: colorSouth,
    );

    //10
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX + Cell_South_Width + Cell_South_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    //11
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    //12
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX + Cell_South_Width,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    const cellSouthDstYZ = Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height;

    //13
    renderCellSouth(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY + cellSouthDstYZ,
      color: colorSouth,
    );

    // 14
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX14,
      dstY: currentNodeDstY + dstY14,
      color: colorAbove,
    );

    // 15
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Size_Half - Cell_Size_Half,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
    );

    // 16
    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      dstY: currentNodeDstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
    );
  }

  void renderCornerSouthWest({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
  }) {

    renderDynamicHalfSouth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      colorAbove: colorAbove,
      colorSouth: colorSouth,
      colorWest: colorWest,
    );

    renderDynamicHalfWest(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      colorWest: colorWest,
      colorSouth: colorSouth,
      colorAbove: colorAbove,
    );
  }

  void renderCornerNorthWest(double srcY) {
    renderDynamicHalfNorth(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      colorSouth: colorCurrent,
      colorWest: colorWest,
      colorAbove: colorAbove,
    );
    renderDynamicHalfWest(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      colorSouth: colorSouth,
      colorWest: colorWest,
      colorAbove: colorAbove,
    );
  }

  void renderCornerNorthEast(double srcY) {
    renderDynamicHalfNorth(
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      srcY: srcY,
      colorWest: colorWest,
      colorSouth: colorCurrent,
      colorAbove: colorAbove,
    );

    final dstX = 0.0;
    final dstY = -Cell_Size;

    renderNodeSideWest(
      srcY: srcY,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY + dstY + Node_Size_Sixth,
      width: Cell_Size,
      color: colorCurrent,
    );

    renderNodeSideSouth(
      srcY: srcY,
      width: Node_Size_Sixth,
      dstX: currentNodeDstX + dstX + Node_Size_Half - Cell_Size_Half,
      dstY: currentNodeDstY + dstY + Node_Size_Sixth - Cell_Size_Half,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX,
      dstY: currentNodeDstY + dstY,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: currentNodeDstX + dstX + Node_Size_Sixth,
      dstY: currentNodeDstY + dstY + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderCornerSouthEast({
    required double srcY,
    required double dstX,
    required double dstY,
  }) {
    renderSideEastWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Sixth,
      dstY: dstY - Node_Size_Sixth - Node_Size_Sixth - Node_Size_Sixth,
      colorWest: colorCurrent,
      colorSouth: colorSouth,
      colorAbove: colorAbove,
    );

    renderNodeSideWest(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Cell_Size,
      width: Node_Size_Sixth,
      color: colorWest,
    );

    renderNodeSideSouth(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half + Node_Size_Sixth,
      dstY: dstY + Cell_Size - Node_Size_Half + Node_Size_Sixth,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Cell_Size - Node_Size_Half + Node_Size_Third,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half + Node_Size_Sixth,
      dstY: dstY + Cell_Size - Node_Size_Half + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderSlopeEast({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorAbove,
    required int colorWest,
    required int colorSouth,
  }) {
    renderSlopeEastStep(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY + Node_South_Height - Cell_South_Height,
      colorWest: colorWest,
      colorTop: colorAbove,
      colorSouth: colorSouth,
    );
    renderSlopeEastStep(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_Size_Half,
      dstY: dstY + Node_South_Height - Cell_South_Height - Cell_Size,
      colorWest: colorCurrent,
      colorTop: colorAbove,
      colorSouth: colorSouth,
    );
    renderSlopeEastStep(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_Size_Half + Cell_Size_Half,
      dstY: dstY + Node_South_Height - Cell_South_Height - Cell_Size - Cell_Size,
      colorWest: colorCurrent,
      colorTop: colorAbove,
      colorSouth: colorSouth,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: dstX - Node_Size_Half +Cell_Size + Cell_Size,
      dstY: dstY + Node_South_Height,
      color: colorSouth,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_Size + Cell_Size + Cell_South_Width,
      dstY: dstY + Node_South_Height - Cell_South_Height,
      color: colorSouth,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_Size + Cell_Size + Cell_South_Width,
      dstY: dstY + Node_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );
  }

  void renderSlopeEastStep({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorTop,
    required int colorSouth,
  }) {

    renderCellWest(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + 1,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX + Cell_West_Width,
      dstY: dstY + Cell_Size_Half + 1,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX + Cell_West_Width + Cell_West_Width,
      dstY: dstY + Cell_Size_Half + Cell_Size_Half + 1,
      color: colorWest,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY - Cell_Size_Half,
      color: colorTop,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Cell_Size_Half,
      dstY: dstY - Cell_Size_Half + Cell_Size_Half,
      color: colorTop,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Cell_Size_Half + Cell_Size_Half,
      dstY: dstY - Cell_Size_Half + Cell_Size_Half + Cell_Size_Half,
      color: colorTop,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX + Cell_Size_Half + Cell_Size_Half + Cell_Size_Half,
      dstY: dstY - Cell_Size_Half + Cell_Size_Half + Cell_Size_Half + Cell_Size_Half,
      color: colorSouth,
    );
  }

  void renderDynamicHalfNorth({
    required double srcY,
    required int colorSouth,
    required int colorWest,
    required int colorAbove,
    required double dstX,
    required double dstY,
  }) =>
      renderDynamicSideNorthSouth(
        srcY: srcY,
        dstX: dstX - Node_Size_Half,
        dstY: dstY,
        colorSouth: colorSouth,
        colorWest: colorWest,
        colorAbove: colorAbove,
      );

  void renderDynamicHalfSouth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
  }) =>
      renderDynamicSideNorthSouth(
        srcY: srcY,
        dstX: dstX - Node_Size_Sixth,
        dstY: dstY + Node_Size_Third,
        colorWest: colorWest,
        colorSouth: colorSouth,
        colorAbove: colorAbove,
      );

  void renderDynamicSolid({
    required double srcX,
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorAbove,
    required int colorWest,
    required int colorSouth,
  }) {
    renderNodeSideTop(
      srcX: srcX,
      srcY: srcY,
      color: colorAbove,
      dstX: dstX - Node_Size_Half,
      dstY: dstY - Node_Size_Half,
    );
    renderNodeSideWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY,
      color: colorWest,
    );
    renderNodeSideSouth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
    );
  }

  void renderDynamicHalfWest({
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
    required double srcY,
    required double dstX,
    required double dstY,
  }) => renderSideEastWest(
    srcY: srcY,
    dstX: dstX - Node_Size_Half,
    dstY: dstY - Node_Size_Sixth,
    colorWest: colorWest,
    colorSouth: colorSouth,
    colorAbove: colorAbove,
  );

  void renderDynamicHalfEast({
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
    required double srcY,
    required double dstX,
    required double dstY,
  }) => renderSideEastWest(
    srcY: srcY,
    dstX: dstX - Node_Size_Sixth,
    dstY: dstY - Node_Size_Sixth - Node_Size_Sixth - Node_Size_Sixth,
    colorSouth: colorSouth,
    colorWest: colorWest,
    colorAbove: colorAbove,
  );

  void renderSideEastWest({
    required double srcY,
    required double dstX,
    required double dstY,
    required colorWest,
    required colorSouth,
    required colorAbove,
  }){

    renderNodeSideWest(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Sixth,
      color: colorWest,
    );

    renderNodeSideSouth(
      srcY: srcY,
      dstX: dstX + Node_Size_Half,
      dstY: dstY + Node_Size_Sixth,
      width: Node_Size_Sixth,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY + Node_Size_Sixth,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Node_Size_Sixth + Node_Size_Sixth,
      dstY: dstY + Node_Size_Sixth + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderNodeSideWest({
    required int color,
    required double srcY,
    required double dstX,
    required double dstY,
    double width = Src_Width_Side_West,
    double height = Src_Height_Side_West,
  }) =>
      engine.render(
        color: color,
        srcLeft: Src_X_Side_West,
        srcTop: srcY,
        srcRight: Src_X_Side_West + width,
        srcBottom: srcY + height,
        scale: 1.0,
        rotation: 0,
        dstX: dstX,
        dstY: dstY,
      );

  void renderNodeSideSouth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
    double width = Src_Width_Side_South,
    double height = Src_Height_Side_South,
  }) => engine.render(
    color: color,
    srcLeft: Src_X_Side_South,
    srcTop: srcY,
    srcRight: Src_X_Side_South + width,
    srcBottom: srcY + height,
    scale: 1.0,
    rotation: 0,
    dstX: dstX,
    dstY: dstY,
  );

  void renderDynamicSideNorthSouth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
  }){
    renderNodeSideWest(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      width: Node_Size_Sixth,
      color: colorWest
    );

    renderNodeSideSouth(
      srcY: srcY,
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half + Node_Size_Sixth,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
        dstX: dstX,
        dstY: dstY - Node_Size_Half + Node_Size_Third,
        color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half + Node_Size_Sixth,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Node_Size_Sixth + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half,
      color: colorAbove,
    );
  }

  void renderCellTop({
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
  }) => engine.render(
        color: color,
        srcLeft: Src_X_Cell_Top,
        srcTop: srcY,
        srcRight: Src_X_Cell_Top + Src_Width_Cell_Top,
        srcBottom: srcY + Src_Height_Cell_Top,
        scale: 1.0,
        rotation: 0,
        dstX: dstX,
        dstY: dstY,
    );

  void renderCellWest({
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
  }) => engine.render(
        color: color,
        srcLeft: Src_X_Cell_West,
        srcTop: srcY + Src_Y_Cell_West,
        srcRight: Src_X_Cell_West + Src_Width_Cell_West,
        srcBottom: srcY + Src_Y_Cell_West + Src_Height_Cell_West,
        scale: 1.0,
        rotation: 0,
        dstX: dstX,
        dstY: dstY,
    );

  void renderCellSouth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
  }) =>
      engine.render(
        color: color,
        srcLeft: Src_X_Cell_South,
        srcTop: srcY + Src_Y_Cell_South,
        srcRight: Src_X_Cell_South + Src_Width_Cell_South,
        srcBottom: srcY + Src_Y_Cell_South + Src_Height_Cell_South,
        scale: 1.0,
        rotation: 0,
        dstX: dstX,
        dstY: dstY,
      );

  void renderNodeSideTop({
    required int color,
    required double srcX,
    required double srcY,
    required double dstX,
    required double dstY,
  }) {
    engine.render(
        color: color,
        srcLeft: srcX,
        srcTop: srcY,
        srcRight: srcX + Src_Width_Side_Top,
        srcBottom: srcY + Src_Height_Side_Top,
        scale: 1.0,
        rotation: 0,
        dstX: dstX,
        dstY: dstY,
    );
  }
}
