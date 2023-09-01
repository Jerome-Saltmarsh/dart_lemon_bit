import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src_nodes_y.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/isometric/functions/get_render.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_math/src.dart';

import 'constants/node_src.dart';



class RendererNodes extends RenderGroup {

  static const treeAnimation = [0, 1, 2, 1, 0, -1, -2, -1];
  static final treeAnimationLength = treeAnimation.length;
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


  var srcXRainLanding = 6739.0;
  var windType = 0;
  var rainType = 0;
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
  var totalPlains = 0;
  var orderShiftY = 151.0;
  var renderRainFalling = true;
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

  late Uint8List nodeTypes;
  late Uint32List nodeColors;
  late Uint8List nodeOrientations;

  late final ui.Image atlasNodes;

  @override
  void onComponentReady() {
    atlasNodes = images.atlas_nodes;
  }

  int get wind => environment.wind.value;

  @override
  void renderFunction() {
    engine.bufferImage = atlasNodes;
    previousNodeTransparent = false;

    final scene = this.scene;
    final area = scene.area;
    final totalZ = scene.totalZ;
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final columnMax = columns - 1;
    final rowMax = rows - 1;
    final maxZ = totalZ - 1;
    final shiftRight = columns - 1;
    final index = plainIndex;
    final nodeTypes = scene.nodeTypes;
    final variations = scene.nodeVariations;
    final orientations = scene.nodeOrientations;
    final nodeColors = scene.nodeColors;
    final ambientColor = scene.ambientColor;

    int lineZ;
    int lineColumn;
    int lineRow;

    if (index < maxZ){
      lineZ = index;
      lineColumn = 0;
      lineRow = 0;
    } else if (index < maxZ + columns){
      lineZ = maxZ;
      lineColumn = index - maxZ;
      lineRow = 0;
    } else {
      lineZ = maxZ;
      lineColumn = columnMax;
      lineRow = index - maxZ - columns;
    }

    final screenLeft = this.screenLeft; // cache in cpu
    final screenTop = this.screenTop; // cache in cpu
    final screenRight = this.screenRight; // cache in cpu
    final screenBottom = this.screenBottom; // cache in cpu

    var column = lineColumn;
    var row = lineRow;

    var dstY = ((row + column) * Node_Size_Half) - (lineZ * Node_Height);

    if (dstY > screenBottom){
      end();
      return;
    }
    var nodeIndex = -1;
    var dstX = 0.0;

    final lightningFlashing = environment.lightningFlashing;
    final lightningColor = this.lightningColor;

    while (lineZ >= 0) {
      dstY = ((row + column) * Node_Size_Half) - (lineZ * Node_Height);

      if (dstY > screenTop) {
        if (dstY > screenBottom){
          break;
        }

        nodeIndex = (lineZ * area) + (row * columns) + column;
        dstX = (row - column) * Node_Size_Half;

        while (true) {

          if (dstX > screenLeft) {
            if (dstX > screenRight) {
              break;
            }

            final nodeType = nodeTypes[nodeIndex];
            if (nodeType != NodeType.Empty){

              final srcY = nodeTypeSrcY[nodeType];

              if (srcY != null) {

                final int colorWest;
                final column = nodeIndex % columns;
                if (column + 1 >= columns){
                  colorWest = ambientColor;
                } else {
                  colorWest = nodeColors[nodeIndex + 1];
                }

                renderDynamic(
                  nodeType: nodeType,
                  nodeOrientation: orientations[nodeIndex],
                  nodeVariation: variations[nodeIndex],
                  colorAbove: lightningFlashing
                      ? lightningColor
                      : scene.colorAbove(nodeIndex),
                  colorWest: colorWest,
                  colorSouth: scene.colorSouth(nodeIndex),
                  colorCurrent: nodeColors[nodeIndex],
                  dstX: dstX,
                  dstY: dstY,
                  srcY: srcY,
                );
              } else {
                renderNodeIndex(
                  index: nodeIndex,
                  nodeType: nodeType,
                  orientation: orientations[nodeIndex],
                  dstX: dstX,
                  dstY: dstY,
                  scene: scene,
                  variation: variations[nodeIndex],
                  color: nodeColors[nodeIndex],
                );
              }
            }
          }

          row++;
          column--;

          if (column < 0 || row >= rows)
            break;

          nodeIndex += shiftRight;
          dstX += Node_Sprite_Width;
        }
      }

      if (lineColumn < columnMax){
        lineColumn++;
      } else {
        if (lineRow < rowMax){
          lineRow++;
        } else {
          break;
        }
      }

      column = lineColumn;
      row = lineRow;
      lineZ--;
      dstY += Node_Height;
    }

    plainIndex++;

    if (plainIndex <= totalPlains) {
      onPlainIndexChanged();
      return;
    }

    end();

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
    final scene = this.scene;
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final height = scene.totalZ;
    final rowMax = rows - 1;
    final columnMax = columns - 1;
    final heightMax = height - 1;
    final index = plainIndex;
    final plainStartRow = clamp(index - (height + columns), 0, rowMax);
    final plainStartColumn = clamp(index - height + 1, 0, columnMax);
    final plainStartZ = clamp(index, 0, heightMax);
    order = (plainStartRow * Node_Size)
        + (plainStartColumn * Node_Size)
        + (plainStartZ * Node_Height)
        + orderShiftY;
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
  int getTotal() => scene.totalNodes;

  @override
  void reset() {
    // lightningFlashing = environment.lightningFlashing;
    renderRainFalling = options.renderRainFallingTwice;
    rainType = environment.rainType.value;
    windType = environment.wind.value;

    if (lightningFlashing) {
      final lightningColorMax = lerpColors(colors.white.value, 0, environment.brightness);
      final ambientBrightness = lerpColors(scene.ambientColor, 0, environment.brightness);
      lightningColor = lerpColors(ambientBrightness, lightningColorMax, environment.lightningFlashing01 * goldenRatio_0618);
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
    final playerPosition = player.position;
    playerZ = playerPosition.indexZ;
    playerRow = playerPosition.indexRow;
    playerColumn =playerPosition.indexColumn;
    playerRenderRow = playerRow - (playerPosition.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (playerPosition.indexZ ~/ 2);
    playerProjection = playerIndex % scene.projection;
    scene.offscreenNodes = 0;
    scene.onscreenNodes = 0;

    screenRight = engine.Screen_Right + Node_Size;
    screenLeft = engine.Screen_Left - Node_Size;
    screenTop = engine.Screen_Top - 72;
    screenBottom = engine.Screen_Bottom + 72;

    currentNodeWithinIsland = false;

    updateTransparencyGrid();
    updateHeightMapPerception();

    total = getTotal();
    remaining = total > 0;
    scene.resetNodeColorStack();
    scene.resetNodeAmbientStack();
    scene.applyEmissions();
    render.highlightAimTargetEnemy();

    // get the column at the top left screen
    // the the row at the top left screen
    // add total z, that will give the index

    var column = 0;
    var row = 0;
    final sTop = screenTop;

    index = 0;

    while (true){
      var renderY = getRenderYfOfRowColumn(row, column);

      if (renderY >= sTop){
        break;
      }

      if (column < totalColumns -1){
        column++;
      } else if (row < totalRows - 1){
        row++;
      } else {
        break;
      }
      index++;
    }

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


    final totalColumns = scene.totalColumns;
    final totalRows = scene.totalRows;
    final projection = scene.projection;

    final maxZ = playerZ + 1;

    for (var z = playerZ; z <= maxZ; z++){
      if (z >= scene.totalZ) break;
      final indexZ = z * scene.area;
      for (var row = playerRow - r; row <= playerRow + r; row++){
        if (row < 0) continue;
        if (row >= totalRows) break;
        final rowIndex = row * totalColumns + indexZ;
        for (var column = playerColumn - r; column <= playerColumn + r; column++){
          if (column < 0) continue;
          if (column >= totalColumns) break;
          final index = rowIndex + column;
          final projectionIndex = index % projection;
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
    visit2D(
      player.areaNodeIndex,
      columns: scene.totalColumns,
      rows: scene.totalRows,
      scene: scene,
    );
  }

  void ensureIndexPerceptible(int index){
    var projectionRow     = scene.getRow(index);
    var projectionColumn  = scene.getColumn(index);
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
      visit2D(projectionIndex,
        columns: scene.totalColumns,
        rows: scene.totalRows,
        scene: scene,
      );
      return;
    }
  }

  void addVisible3D(int i){
    visible3D[i] = true;
    visible3DStack[visible3DIndex] = i;
    visible3DIndex++;
  }

  void visit2D(int i, {
    required int columns,
    required int rows,
    required IsometricScene scene,
  }) {
     if (visited2D[i])
       return;

     visited2D[i] = true;
     visited2DStack[visited2DStackIndex] = i;
     visited2DStackIndex++;
     if (scene.heightMap[i] <= zMin) return;
     island[i] = true;

     final area = scene.area;
     final playerIndexZ = player.indexZ;
     var searchIndex = i + (area * playerIndexZ);
     addVisible3D(searchIndex);

     var spaceReached = nodeOrientations[searchIndex] == NodeOrientation.None;
     var gapReached = false;

     final totalNodes = scene.totalNodes;

     while (true) {
       searchIndex += area;
        if (searchIndex >= totalNodes) break;
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
     searchIndex = i + (area * playerIndexZ);
     while (true) {
       addVisible3D(searchIndex);
       if (blocksBeamVertical(searchIndex)) break;
       searchIndex -= area;
       if (searchIndex < 0) break;
     }

     final iAbove = i - columns;
     if (iAbove > 0) {
       visit2D(iAbove, columns: columns, rows: rows, scene: scene);
     }
     final iBelow = i + columns;
     if (iBelow < area) {
       visit2D(iBelow, columns: columns, rows: rows, scene: scene);
     }

     final row = i % rows;
     if (row - 1 >= 0) {
       visit2D(i - 1, columns: columns, rows: rows, scene: scene);
     }
     if (row + 1 < rows){
       visit2D(i + 1, columns: columns, rows: rows, scene: scene);
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

  void renderNodeTorch({
    required double dstX,
    required double dstY,
    required bool grassy,
    required int wind,
}){
    renderCustomNode(
        srcX: grassy ? 1294.0 : 1311.0,
        srcY: 304,
        srcWidth: 16,
        srcHeight: 34,
        dstX: dstX - 8,
        dstY: dstY,
        color: 0,
    );

    render.flame(dstX: dstX, dstY: dstY - 12, scale: 0.7, wind: wind);
  }

  // bool assertOnScreen(){
  //   if (currentNodeDstX < screenLeft){
  //     offscreenNodesLeft++;
  //     return true;
  //   }
  //   if (currentNodeDstX > screenRight){
  //     offscreenNodesRight++;
  //     return true;
  //   }
  //   if (currentNodeDstY < screenTop){
  //     offscreenNodesTop++;
  //     return true;
  //   }
  //   if (currentNodeDstY > screenBottom){
  //     offscreenNodesBottom++;
  //     return true;
  //   }
  //
  //   return true;
  // }

  // bool get currentNodeTransparent {
  //   if (currentNodeZ <= playerZ) return false;
  //   final currentNodeProjection = currentNodeIndex % scene.projection;
  //   if (!transparencyGrid[currentNodeProjection]) return false;
  //
  //   final nodeOrientation = scene.nodeOrientations[currentNodeIndex];
  //
  //   if (nodeOrientation == NodeOrientation.Half_North || nodeOrientation == NodeOrientation.Half_South){
  //     return row >= playerRow;
  //   }
  //   if (nodeOrientation == NodeOrientation.Half_East || nodeOrientation == NodeOrientation.Half_West){
  //     return column >= playerColumn;
  //   }
  //
  //   return row >= playerRow && column >= playerColumn;
  // }

  void renderNodeIndex({
    required int index,
    required int nodeType,
    required int variation,
    required int orientation,
    required double dstX,
    required double dstY,
    required IsometricScene scene,
    required int color,
  }) {

    // if (currentNodeWithinIsland && currentNodeZ >= playerZ + 2) return;
    // final transparent = currentNodeTransparent;
    // if (previousNodeTransparent != transparent) {
    // TODO use engine.color.opacity = 0.5;
    //   previousNodeTransparent = transparent;
    //   engine.bufferImage = transparent ? images.atlas_nodes_transparent : images.atlas_nodes;
    // }

    switch (nodeType) {

      case NodeType.Rain_Falling:
        renderNodeRainFalling(
            dstX: dstX,
            dstY: dstY,
            color: scene.getColor(index),
            rainType: rainType,
            windType: windType,
            animationFrame: (animation.frame + variation)
        );
        return;
      case NodeType.Rain_Landing:

        if (scene.nodeTypeBelowIs(index, NodeType.Water)){
          renderNodeRainLandingOnWater(
            dstX: dstX,
            dstY: dstY,
            variation: variation,
            color: scene.getColor(index),
            rainType: rainType,
          );
        } else {
          renderNodeRainLandingOnGround(
            dstX: dstX,
            dstY: dstY,
            color: scene.getColor(index),
            rainType: rainType,
            animationFrame: animation.frame + variation,
          );
        }

        if (renderRainFalling) {
          renderNodeRainFalling(
              dstX: dstX,
              dstY: dstY,
              color: color,
              rainType: rainType,
              windType: windType,
              animationFrame: (animation.frame + variation)
          );
        }

        return;

      case NodeType.Bricks_Red:
        renderNodeTemplateShaded(
            srcX: IsometricConstants.Sprite_Width_Padded_13,
            dstX: dstX,
            dstY: dstY,
            nodeOrientation: orientation,
            color: color
        );
        return;
      case NodeType.Bricks_Brown:
        renderNodeTemplateShaded(
          srcX: IsometricConstants.Sprite_Width_Padded_14,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        return;
      case NodeType.Water:
        renderNodeWater(
          dstX: dstX,
          dstY: dstY,
          color: scene.getColor(index),
          animationFrame: ((animation.frameWater + ((scene.getRowColumn(index)) * 3)) % 10),
        );
        break;
      case NodeType.Dust:
        break;
      case NodeType.Sandbag:
        renderStandardNode(
          srcX: 539,
          srcY: 0,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        break;
      case NodeType.Concrete:
        renderNodeTemplateShaded(
            srcX: IsometricConstants.Sprite_Width_Padded_8,
            dstX: dstX,
            dstY: dstY,
            nodeOrientation: orientation,
            color: color
        );
        return;
      case NodeType.Metal:
        renderNodeTemplateShaded(
          srcX: IsometricConstants.Sprite_Width_Padded_4,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        return;
      case NodeType.Road:
        renderNodeTemplateShadedOffset(
          IsometricConstants.Sprite_Width_Padded_9,
          offsetY: 7,
          color: scene.colorAbove(index),
          orientation: orientation,
        );
        return;
      case NodeType.Tree_Top:
        final nodeVariationBelow = scene.nodeVariations[index - scene.area];
        final row = scene.getRow(index);
        final column = scene.getColumn(index);
        renderNodeTreeTop(
          dstX: dstX,
          dstY: dstY,
          treeType: mapVariationToTreeType(nodeVariationBelow),
          colorWest: scene.colorWest(index),
          colorSouth: scene.colorSouth(index),
          animationFrame: row + column + animation.frame,
        );
        break;
      case NodeType.Tree_Bottom:
        final row = scene.getRow(index);
        final column = scene.getRow(index);
        renderNodeTreeBottom(
          dstX: dstX,
          dstY: dstY,
          treeType: mapVariationToTreeType(variation),
          colorWest: scene.colorWest(index),
          colorSouth: scene.colorSouth(index),
          animationFrame: row + column + animation.frame,
        );
        break;
      case NodeType.Scaffold:
        renderNodeTemplateShaded(
          srcX: IsometricConstants.Sprite_Width_Padded_15,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        break;
      case NodeType.Road_2:
        renderNodeShadedOffset(
            dstX: dstX,
            dstY: dstY,
            srcX: 1490,
            srcY: 305,
            offsetX: 0,
            offsetY: 7,
            color: scene.getColor(index),
        );
        return;
      case NodeType.Wooden_Plank:
        renderNodeTemplateShaded(
          srcX: IsometricConstants.Sprite_Width_Padded_10,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        return;
      case NodeType.Torch:
        renderNodeTorch(
          dstX: dstX,
          dstY: dstY,
          grassy: scene.nodeTypeBelowIs(index, NodeType.Grass),
          wind: wind,
        );
        break;
      case NodeType.Torch_Blue:
        renderCustomNode(
          srcX: 1328,
          srcY: 306,
          srcWidth: 14,
          srcHeight: 28,
          dstX: dstX - 7,
          dstY: dstY + 4,
          color: scene.getColor(index),
        );

        renderCustomNode(
            srcX: 1343 + (animation.frame6 * 16),
            srcY: 306,
            srcWidth: 14,
            srcHeight: 32,
            dstX: dstX - 8,
            dstY: dstY - 16,
            color: 0,
        );
        break;
      case NodeType.Torch_Red:
        renderCustomNode(
          srcX: 1328,
          srcY: 306,
          srcWidth: 14,
          srcHeight: 28,
          dstX: dstX - 7,
          dstY: dstY + 4,
          color: scene.getColor(index),
        );

        renderCustomNode(
            srcX: 1343 + (animation.frame6 * 16),
            srcY: 339,
            srcWidth: 14,
            srcHeight: 32,
            dstX: dstX - 8,
            dstY: dstY - 16,
            color: 0,
        );
        break;
      case NodeType.Shopping_Shelf:
        renderNodeShoppingShelf(
          dstX: dstX,
          dstY: dstY,
          variation: variation,
          color: color,
        );
        break;
      case NodeType.Bookshelf:
        renderNodeBookShelf(
          dstX: dstX,
          dstY: dstY,
          color: scene.nodeColors[index],
        );
        break;
      case NodeType.Grass_Long:
        final row = scene.getRow(index);
        final column = scene.getColumn(index);

        renderNodeGrassLong(
          dstX: dstX,
          dstY: dstY,
          colorAbove: scene.colorAbove(index),
          colorWest: scene.colorWest(index),
          colorSouth: scene.colorSouth(index),
          animationFrame: wind == WindType.Calm
              ? 0
              : (((row - column) + animation.frame6) % 6),
        );
        break;
      case NodeType.Tile:
        renderNodeTemplateShaded(
          srcX: 588,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        return;
      case NodeType.Glass:
        renderNodeTemplateShaded(
          srcX: IsometricConstants.Sprite_Width_Padded_16,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        return;
      case NodeType.Bau_Haus:
        const index_grass = 6;
        const srcX = IsometricConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(
          srcX: srcX,
          dstX: dstX,
          dstY: dstY,
          nodeOrientation: orientation,
          color: color
        );
        break;
      case NodeType.Sunflower:
        renderStandardNode(
          srcX: 1753.0,
          srcY: 867.0,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        return;
      case NodeType.Fireplace:
        renderFireplace(
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeType.Boulder:
        renderBoulder(
          dstX: dstX,
          dstY: dstY,
          colorWest: scene.colorWest(index),
          colorSouth: scene.colorSouth(index),
        );
        return;
      case NodeType.Oven:
        renderStandardNode(
          color: color,
          srcX: AtlasNodeX.Oven,
          srcY: AtlasNodeY.Oven,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeType.Chimney:
        renderStandardNode(
          color: color,
          srcX: AtlasNode.Chimney_X,
          srcY: AtlasNode.Node_Chimney_Y,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeType.Window:
        renderNodeWindow(
          dstX: dstX,
          dstY: dstY,
          color: scene.nodeColors[index],
          orientation: scene.nodeOrientations[index],
        );
        break;
      case NodeType.Table:
        renderStandardNode(
          color: color,
          srcX: AtlasNode.Table_X,
          srcY: AtlasNode.Node_Table_Y,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeType.Respawning:
        return;
      default:
        throw Exception('renderNode(index: ${index}, orientation: ${NodeOrientation.getName(nodeOrientations[index])}');
    }
  }

  void renderFireplace({
    required double dstX,
    required double dstY,
}) => engine.renderSprite(
      image: atlasNodes,
      srcX: AtlasNode.Src_Fireplace_X,
      srcY: AtlasNode.Src_Fireplace_Y + (animation.frame6 * AtlasNode.Src_Fireplace_Height),
      srcWidth: 48,
      srcHeight: 72,
      dstX: dstX,
      dstY: dstY + 12,
      color: 0,
    );

  void renderBoulder({
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
  }) {
    const anchorY = 0.28;

    engine.renderSprite(
      image: atlasNodes,
      srcX: Src_X_Sprite_Boulder_West,
      srcY: Src_Y_Sprite_Boulder,
      srcWidth: Src_Width_Sprite_Boulder,
      srcHeight: Src_Height_Sprite_Boulder,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
      anchorY: anchorY,
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
      anchorY: anchorY,
    );

  }

  void renderNodeShoppingShelf({
    required double dstX,
    required double dstY,
    required int variation,
    required int color,
}) {
     if (variation == 0){
      renderStandardNode(
        color: color,
        srcX: 1392,
        srcY: 160,
        dstX: dstX,
        dstY: dstY,
      );
    } else {
      renderStandardNode(
        color: color,
        srcX: 1441,
        srcY: 160,
        dstX: dstX,
        dstY: dstY,
      );
    }
  }

  void renderNodeBookShelf({
    required double dstX,
    required double dstY,
    required int color,
  }) => renderStandardNode(
      color: color,
      srcX: 1392,
      srcY: 233,
      dstX: dstX,
      dstY: dstY,
    );

  void renderNodeGrassLong({
    required double dstX,
    required double dstY,
    required int colorAbove,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
  }) {
    const Src_X = 957.0;
    const Src_Y = 305.0;
    const Src_Width = 48.0;
    const Src_Height = 72.0;
    const dstOff = -24;

    final srcX = Src_X + (animationFrame * Src_Width);

    renderCustomNode(
      srcX: srcX,
      srcY: Src_Y,
      srcWidth: Src_Width,
      srcHeight: Src_Height,
      dstX: dstX + dstOff,
      dstY: dstY + dstOff,
      color: colorAbove,
    );

    renderCustomNode(
      srcX: srcX,
      srcY: Src_Y + Src_Height,
      srcWidth: Src_Width,
      srcHeight: Src_Height,
      dstX: dstX + dstOff,
      dstY: dstY + dstOff,
      color: colorWest,
    );

    renderCustomNode(
      srcX: srcX,
      srcY: Src_Y + Src_Height + Src_Height,
      srcWidth: Src_Width,
      srcHeight: Src_Height,
      dstX: dstX + dstOff,
      dstY: dstY + dstOff,
      color: colorSouth,
    );
  }

  void renderNodeRainLandingOnGround({
    required double dstX,
    required double dstY,
    required int color,
    required int rainType,
    required int animationFrame,
  }) => renderStandardNode(
      color: color,
      srcX: srcXRainLanding,
      srcY: 72.0 * (animationFrame % 6), // TODO Expensive Operation
      dstX: dstX,
      dstY: dstY,
    );
  void renderNodeRainLandingOnWater({
    required double dstX,
    required double dstY,
    required int variation,
    required int color,
    required int rainType,
  }) => engine.renderSprite(
        image: atlasNodes,
        srcX: AtlasNode.Node_Rain_Landing_Water_X,
        srcY: 72.0 * ((animation.frame + variation) % 8), // TODO Expensive Operation
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: dstX,
        dstY: dstY + animation.frameWaterHeight + 14,
        anchorY: 0.3,
        color: color,
      );

  void renderNodeRainFalling({
    required double dstX,
    required double dstY,
    required int color,
    required int rainType,
    required int windType,
    required int animationFrame,
  }) {
    final row =  (rainType == RainType.Heavy ? 3 : 0) + windType;
    // final column = (animation.frame + nodeVariation) % 6;
    final column = animationFrame % 6;
    renderStandardNode(
      color: color,
      srcX: 1596 + (column * 48),
      srcY: 1306 + (row * 72),
      dstX: dstX,
      dstY: dstY,
    );
  }

  void renderNodeTreeTop({
    required double dstX,
    required double dstY,
    required int treeType,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
  }) =>
      treeType == TreeType.Pine
          ? renderTreeTopPine(
              dstX: dstX,
              dstY: dstY,
              colorWest: colorWest,
              colorSouth: colorSouth,
              animationFrame: animationFrame,
            )
          : renderNodeTreeTopOak(
              dstX: dstX,
              dstY: dstY,
              colorWest: colorWest,
              colorSouth: colorSouth,
              animationFrame: animationFrame,
            );

  void renderNodeTreeBottom({
    required double dstX,
    required double dstY,
    required int treeType,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
  }) =>
      treeType == TreeType.Pine
          ? renderTreeBottomPine(
              dstX: dstX,
              dstY: dstY,
              colorWest: colorWest,
              colorSouth: colorSouth,
              animationFrame: animationFrame,
            )
          : renderTreeBottomOak(
              dstX: dstX,
              dstY: dstY,
              colorWest: colorWest,
              colorSouth: colorSouth,
              animationFrame: animationFrame,
            );

  void renderNodeTreeTopOak({
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
  }){
    final shift = treeAnimation[animationFrame % treeAnimation.length] * wind;
    final shiftRotation = treeAnimation[(animationFrame - 2) % treeAnimation.length] * wind;
    final rotation = shiftRotation * 0.0066;
    const anchorY = 0.82;

    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Top_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Top_South,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeTopPine({
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
}) {
    final shift = treeAnimation[animationFrame % treeAnimation.length] * wind;
    final shiftRotation = treeAnimation[(animationFrame - 2) % treeAnimation.length] * wind;
    final rotation = shiftRotation * 0.0066;
    const anchorY = 0.82;

    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Top_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Top_South,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );

  }

  void renderTreeBottomOak({
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
}) {
    final shiftRotation = treeAnimation[animationFrame % treeAnimationLength] * wind;
    final rotation = shiftRotation * 0.013;
    const anchorY = 0.72;
    const dstYShift = 32;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Oak_Bottom_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
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
      dstY: dstY + dstYShift,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeBottomPine({
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int animationFrame,
  }) {
    final shiftRotation = treeAnimation[animationFrame % treeAnimationLength] * wind;
    final rotation = shiftRotation * 0.013;
    const anchorY = 0.72;
    const dstYShift = 32;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: Src_X_Sprite_Tree_Pine_Bottom_West,
      srcY: Src_Y_Sprite_Tree,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
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
      dstY: dstY + dstYShift,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderNodeTemplateShadedOffset(double srcX, {
    required int color,
    required int orientation,
    double offsetX = 0,
    double offsetY = 0,
    double dstX = 0,
    double dstY = 0,
  }) {
    switch (orientation){
      case NodeOrientation.Solid:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_00,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
            dstX: dstX,
            dstY: dstY,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;

      case NodeOrientation.Corner_North_East:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );

        return;
      case NodeOrientation.Corner_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Corner_South_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Corner_North_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_North:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_03,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_04,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_South:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_05,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_06,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_07,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_08,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_09,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_10,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_11,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_12,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_13,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_14,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Radial:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_15,
          offsetX: offsetX,
          offsetY: offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -9 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -1 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: 2 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: -16 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -16 + offsetX,
          offsetY: 0 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 0 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 16 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 16 + offsetX,
          offsetY: 0 + offsetY,
          dstX: dstX,
          dstY: dstY,
        );
        return;
    }
  }

  void renderNodeTemplateShaded({
    required int nodeOrientation,
    required int color,
    required double srcX,
    required double dstX,
    required double dstY,
  }) {
    switch (nodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_00,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Corner_North_East:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16,
          offsetY: -8,
          srcWidth: 32,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
          srcWidth: 32,
          dstX: dstX,
          dstY: dstY,
          color: color,
        );
        return;
      case NodeOrientation.Corner_South_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Corner_South_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Corner_North_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_North:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_03,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_East:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_04,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_South:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_05,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_West:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_06,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_07,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_08,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_09,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_10,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_11,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_12,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_13,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_14,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Radial:
        renderStandardNode(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_15,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: -8,
          color: color,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 0,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: -16,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -16,
          offsetY: 0,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 0,
          dstX: dstX,
          dstY: dstY,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,

            color: color
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 16,
          dstX: dstX,
          dstY: dstY,

            color: color
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,

            color: color
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: IsometricConstants.Sprite_Height_Padded_17,
          offsetX: 16,
          offsetY: 0,
          dstX: dstX,
          dstY: dstY,

            color: color
        );
        return;
    }
  }


  void renderNodeWindow({
    required double dstX,
    required double dstY,
    required int color,
    required int orientation,
  }){
    const srcX = 1508.0;
    switch (orientation) {
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + IsometricConstants.Sprite_Height_Padded,
          offsetX: -8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
            color: color

        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: 80 + IsometricConstants.Sprite_Height_Padded,
          offsetX: 8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: 80,
          offsetX: 8,
          offsetY: -8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          color: color,
          srcX: srcX,
          srcY: 80,
          offsetX: -8,
          offsetY: 8,
          dstX: dstX,
          dstY: dstY,
        );
        return;
      default:
        throw Exception('render_node_window(${NodeOrientation.getName(orientation)})');
    }
  }

  void renderNodeWater({
    required double dstX,
    required double dstY,
    required int color,
    required int animationFrame,
  }) =>
      engine.renderSprite(
        image: atlasNodes,
        srcX: AtlasNodeX.Water,
        srcY: AtlasNodeY.Water + (animationFrame * 72.0), // TODO Optimize
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: dstX,
        dstY: dstY + animation.frameWaterHeight + 14,
        anchorY: 0.3334,
        color: color,
      );

  void renderStandardNode({
    required double srcX,
    required double srcY,
    required double dstX,
    required double dstY,
    required int color,
  }) => engine.render(
        color: color,
        srcLeft: srcX,
        srcTop: srcY,
        srcRight: srcX + IsometricConstants.Sprite_Width,
        srcBottom: srcY + IsometricConstants.Sprite_Height,
        scale: 1.0,
        rotation: 0,
        dstX: dstX - (IsometricConstants.Sprite_Width_Half),
        dstY: dstY - (IsometricConstants.Sprite_Height_Third),
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
    required double dstX,
    required double dstY,
    required double offsetX,
    required double offsetY,
    required int color,
    double? srcWidth,
    double? srcHeight
  }) => engine.render(
    color: color,
    srcLeft: srcX,
    srcTop: srcY,
    srcRight: srcX + (srcWidth ?? IsometricConstants.Sprite_Width),
    srcBottom: srcY + (srcHeight ?? IsometricConstants.Sprite_Height),
    scale: 1.0,
    rotation: 0,
    dstX: dstX - (IsometricConstants.Sprite_Width_Half) + offsetX,
    dstY: dstY - (IsometricConstants.Sprite_Height_Third) + offsetY,
  );

  void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double dstX,
    required double dstY,
    required double offsetX,
    required double offsetY,
    required int color,
  }) => engine.render(
    color: color,
    srcLeft: srcX,
    srcTop: srcY,
    srcRight: srcX + IsometricConstants.Sprite_Width,
    srcBottom: srcY + IsometricConstants.Sprite_Height,
    scale: 1.0,
    rotation: 0,
    dstX: dstX - (IsometricConstants.Sprite_Width_Half) + offsetX,
    dstY: dstY - (IsometricConstants.Sprite_Height_Third) + offsetY,
  );

  void renderDynamic({
    required int nodeType,
    required int nodeOrientation,
    required int nodeVariation,
    required int colorAbove,
    required int colorSouth,
    required int colorWest,
    required int colorCurrent,
    required double dstX,
    required double dstY,
    required double srcY,
  }) {

    switch (nodeOrientation) {
      case NodeOrientation.Solid:
        renderDynamicSolid(
          dstX: dstX,
          dstY: dstY,
          srcY: srcY,
          srcX: nodeVariation < 126 ? 0.0 : 128.0,
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
          colorWest: colorCurrent,
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
          colorSouth: colorCurrent,
          colorWest: colorWest,
          colorAbove: colorAbove,
        );
        break;

      case NodeOrientation.Corner_South_East:
        renderCornerSouthEast(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorSouth: colorSouth,
          colorWest: colorWest,
          colorAbove: colorAbove,
          colorCurrent: colorCurrent,
        );
        break;

      case NodeOrientation.Corner_North_East:
        renderCornerNorthEast(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorSouth: colorSouth,
          colorWest: colorWest,
          colorAbove: colorAbove,
          colorCurrent: colorCurrent,
        );
        break;

      case NodeOrientation.Corner_North_West:
        renderCornerNorthWest(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorWest: colorWest,
          colorSouth: colorSouth,
          colorAbove: colorAbove,
          colorCurrent: colorCurrent,
        );
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
        renderSlopeWest(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorAbove: colorAbove,
          colorSouth: colorSouth,
          colorWest: colorWest,
          colorCurrent: colorCurrent,
        );
        break;

      case NodeOrientation.Slope_South:
        renderSlopeSouth(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorAbove: colorAbove,
          colorSouth: colorSouth,
          colorWest: colorWest,
          colorCurrent: colorCurrent,
        );
        break;

      case NodeOrientation.Slope_North:
        renderSlopeNorth(
          srcY: srcY,
          dstX: dstX,
          dstY: dstY,
          colorAbove: colorAbove,
          colorSouth: colorSouth,
          colorWest: colorWest,
          colorCurrent: colorCurrent,
        );
        break;
    }
  }

  void renderSlopeNorth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
    required int colorCurrent,
  }) {

    renderCellTopColumn(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY - Cell_South_Height,
      color: colorAbove,
    );

    renderCellSouthColumn(
      srcY: srcY,
      dstX: dstX - Cell_South_Width - Cell_South_Width,
      dstY: dstY,
      color: colorCurrent,
    );

    renderCellTopColumn(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_South_Width,
      dstY: dstY - Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellSouthColumn(
      srcY: srcY,
      dstX: dstX - Cell_South_Width - Cell_South_Width + Cell_South_Width,
      dstY: dstY + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellTopColumn(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_South_Width + Cell_South_Width,
      dstY: dstY - Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellSouthColumn(
      srcY: srcY,
      dstX: dstX - Cell_South_Width - Cell_South_Width + Cell_South_Width + Cell_South_Width,
      dstY: dstY + Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY + Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_West_Width,
      dstY: dstY + Cell_West_Height + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_West_Width,
      dstY: dstY + Cell_West_Height + Cell_West_Height + Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_West_Width + Cell_West_Width,
      dstY: dstY + Cell_West_Height + Cell_West_Height + Cell_West_Height + Cell_West_Height,
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
      dstX: dstX,
      dstY: dstY,
      color: color,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Cell_Top_Width,
      dstY: dstY - Cell_Top_Height,
      color: color,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Cell_Top_Width + Cell_Top_Width,
      dstY: dstY - Cell_Top_Height - Cell_Top_Height,
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
      dstX: dstX,
      dstY: dstY,
      color: color,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: dstX + Cell_South_Width,
      dstY: dstY - Cell_South_Height,
      color: color,
    );
    renderCellSouth(
      srcY: srcY,
      dstX: dstX + Cell_South_Width + Cell_South_Width,
      dstY: dstY - Cell_South_Height - Cell_South_Height,
      color: color,
    );
  }

  void renderSlopeSouth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
    required int colorCurrent,
  }) {

    renderNodeSideSouth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width + Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width + Cell_Top_Width + Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width + Cell_Top_Width - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width + Cell_Top_Width + Cell_Top_Width - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Cell_West_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Cell_West_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Cell_West_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Cell_West_Width - Cell_West_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Cell_West_Width - Cell_West_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      srcY: srcY,
      dstX: dstX - Cell_West_Width - Cell_West_Width - Cell_West_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width,
      dstY: dstY + Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width + Cell_Top_Width,
      dstY: dstY + Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Top_Width + Cell_Top_Width + Cell_Top_Width,
      dstY: dstY + Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );
  }

  void renderSlopeWest({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
    required int colorAbove,
    required int colorCurrent,
  }) {

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height -Cell_Size - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderNodeSideWest(
      srcY: srcY,
      dstX: dstX - Node_Size_Half,
      dstY: dstY,
      color: colorWest,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX + Cell_South_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height -Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX + Cell_South_Width + Cell_South_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX + Cell_South_Width,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
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

  void renderCornerNorthWest({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorCurrent,
    required int colorAbove,
    required int colorSouth,
  }) {
    renderDynamicHalfNorth(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      colorSouth: colorCurrent,
      colorWest: colorWest,
      colorAbove: colorAbove,
    );
    renderDynamicHalfWest(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY,
      colorSouth: colorSouth,
      colorWest: colorWest,
      colorAbove: colorAbove,
    );
  }

  void renderCornerNorthEast({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorAbove,
    required int colorSouth,
    required int colorCurrent,
  }) {
    renderDynamicHalfNorth(
      dstX: dstX,
      dstY: dstY,
      srcY: srcY,
      colorWest: colorWest,
      colorSouth: colorCurrent,
      colorAbove: colorAbove,
    );

    renderNodeSideWest(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY - Cell_Size + Node_Size_Sixth,
      width: Cell_Size,
      color: colorCurrent,
    );

    renderNodeSideSouth(
      srcY: srcY,
      width: Node_Size_Sixth,
      dstX: dstX + Node_Size_Half - Cell_Size_Half,
      dstY: dstY - Cell_Size + Node_Size_Sixth - Cell_Size_Half,
      color: colorSouth,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY - Cell_Size,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY - Cell_Size + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderCornerSouthEast({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorAbove,
    required int colorSouth,
    required int colorCurrent,
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
      colorWest: colorWest,
      colorTop: colorAbove,
      colorSouth: colorSouth,
    );
    renderSlopeEastStep(
      srcY: srcY,
      dstX: dstX - Node_Size_Half + Cell_Size_Half + Cell_Size_Half,
      dstY: dstY + Node_South_Height - Cell_South_Height - Cell_Size - Cell_Size,
      colorWest: colorWest,
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

int mapVariationToTreeType(int variation){
  if (variation < 126) {
    return TreeType.Oak;
  }
  return TreeType.Pine;

}