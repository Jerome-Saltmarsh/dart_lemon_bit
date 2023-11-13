import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_src_nodes_y.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/node_visibility.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/isometric/functions/get_render.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
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


  var totalSkipped = 0;
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
  var orderShiftY = 13.0;
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
  var zMin = 0;
  var playerIndex = 0;
  var currentNodeWithinIsland = false;

  late final ui.Image atlasNodes;

  @override
  void onComponentReady() {
    atlasNodes = images.atlas_nodes;
  }

  int get wind => environment.wind.value;

  final colorTransparent = Colors.white.withOpacity(0.15);

  @override
  void renderFunction(LemonEngine engine, IsometricImages images) {
    engine.bufferImage = atlasNodes;
    previousNodeTransparent = false;

    final scene = this.scene;
    final totalNodes = scene.totalNodes;
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
    final nodeRandoms = scene.nodeRandoms;
    final orientations = scene.nodeOrientations;
    final nodeColors = scene.nodeColors;
    final ambientColor = scene.ambientColor;
    final rainType = this.rainType;
    final windType = this.windType;
    final animationFrame1 = this.animation.frame1;
    final screenLeft = this.screenLeft; // cache in cpu
    final screenTop = this.screenTop; // cache in cpu
    final screenRight = this.screenRight; // cache in cpu
    final screenBottom = this.screenBottom; // cache in cpu
    final lightningFlashing = environment.lightningFlashing;
    final lightningColor = this.lightningColor;
    final nodeVisibility = scene.nodeVisibility;

    final src = engine.bufferSrc;
    final dst = engine.bufferDst;
    final clr = engine.bufferClr;

    int lineZ;
    int lineColumn;
    int lineRow;

    double? srcY;

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

    var column = lineColumn;
    var row = lineRow;
    var dstY = ((row + column) * Node_Size_Half) - (lineZ * Node_Height);
    var nodeIndex = -1;
    var dstX = 0.0;
    var colorWest = -1;
    var colorSouth = -1;
    var nodeType = -1;
    var previousVisibility = 0;

    final renderHeightMap = options.renderHeightMap;


    if (dstY > screenBottom){
      end();
      return;
    }

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

            nodeType = nodeTypes[nodeIndex];

            if (renderHeightMap) {
              if (nodeType != NodeType.Empty){
                final heightMapZ = scene.getHeightAt(row, column);
                if (lineZ < heightMapZ){
                  renderStandardNode(
                      srcX: 392,
                      srcY: 0,
                      dstX: dstX,
                      dstY: dstY - 24,
                      color: Colors.white.value,
                  );
                }
              }
            } else if (nodeType != NodeType.Empty){

              srcY = nodeTypeSrcY[nodeType];

              if (srcY != null) {

                final visibility = nodeVisibility[nodeIndex];
                if (visibility != NodeVisibility.invisible) {
                  if (visibility != previousVisibility) {
                    engine.flushBuffer();
                    previousVisibility = visibility;
                    if (visibility == NodeVisibility.transparent) {
                      engine.color = colorTransparent;
                    } else {
                      engine.color = Colors.white;
                    }
                  }


                  if (nodeIndex % columns + 1 >= columns) {
                    colorWest = ambientColor;
                  } else {
                    colorWest = nodeColors[nodeIndex + 1];
                  }

                  if ((nodeIndex % area) ~/ columns + 1 >= rows) {
                    colorSouth = ambientColor;
                  } else {
                    colorSouth = nodeColors[nodeIndex + columns];
                  }

                  final nodeAboveIndex = nodeIndex + area;
                  int colorAbove;

                  if (lightningFlashing) {
                    colorAbove = lightningColor;
                  } else if (nodeAboveIndex >= totalNodes) {
                    colorAbove = ambientColor;
                  } else {
                    colorAbove = nodeColors[nodeAboveIndex];
                  }

                  final nodeVariation = variations[nodeIndex];
                  final colorCurrent = nodeColors[nodeIndex];

                  switch (orientations[nodeIndex]) {
                    case NodeOrientation.Solid:
                      renderDynamicSolid(
                        dstX: dstX,
                        dstY: dstY,
                        srcY: srcY,
                        srcX: nodeVariation * 128.0,
                        colorAbove: colorAbove,
                        colorSouth: colorSouth,
                        colorWest: colorWest,
                        clr: clr,
                        dst: dst,
                        src: src,
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

                    case NodeOrientation.Half_Vertical_Top:
                      renderCellWest(
                        srcY: srcY,
                        dstX: dstX - Node_Size_Half,
                        dstY: dstY,
                        color: colorWest,
                      );

                      renderCellWest(
                        srcY: srcY,
                        dstX: dstX - Node_Size_Half + Cell_South_Width,
                        dstY: dstY + Cell_South_Height,
                        color: colorWest,
                      );

                      renderCellWest(
                        srcY: srcY,
                        dstX: dstX - Node_Size_Half + Cell_South_Width +
                            Cell_South_Width,
                        dstY: dstY + Cell_South_Height + Cell_South_Height,
                        color: colorWest,
                      );

                      engine.render(
                        color: colorSouth,
                        srcLeft: 248,
                        srcTop: srcY,
                        srcRight: 271,
                        srcBottom: srcY + 30,
                        scale: 1.0,
                        rotation: 0,
                        dstX: dstX,
                        dstY: dstY,
                      );

                      renderNodeSideTop(
                        color: colorAbove,
                        srcX: 0,
                        srcY: srcY,
                        dstX: dstX - Node_Size_Half,
                        dstY: dstY - Node_Height,
                      );
                      break;

                    case NodeOrientation.Column_Center_Center:
                      renderColumn(
                        colorSouth: colorSouth,
                        srcY: srcY,
                        dstX: dstX,
                        dstY: dstY,
                        colorWest: colorWest,
                        colorAbove: colorAbove,
                      );
                      break;
                    case NodeOrientation.Column_Top_Right:
                      renderColumn(
                        colorSouth: colorSouth,
                        srcY: srcY,
                        dstX: dstX,
                        dstY: dstY - 16,
                        colorWest: colorWest,
                        colorAbove: colorAbove,
                      );
                      break;
                    case NodeOrientation.Column_Bottom_Right:
                      renderColumn(
                        colorSouth: colorSouth,
                        srcY: srcY,
                        dstX: dstX + 16,
                        dstY: dstY,
                        colorWest: colorWest,
                        colorAbove: colorAbove,
                      );
                      break;
                    case NodeOrientation.Column_Bottom_Left:
                      renderColumn(
                        colorSouth: colorSouth,
                        srcY: srcY,
                        dstX: dstX,
                        dstY: dstY + 16,
                        colorWest: colorWest,
                        colorAbove: colorAbove,
                      );
                      break;
                    case NodeOrientation.Column_Top_Left:
                      renderColumn(
                        colorSouth: colorSouth,
                        srcY: srcY,
                        dstX: dstX - 16,
                        dstY: dstY,
                        colorWest: colorWest,
                        colorAbove: colorAbove,
                      );
                      break;
                  }
                }
              } else {

                final visibility = nodeVisibility[nodeIndex];
                if (visibility != NodeVisibility.invisible) {
                  if (visibility != previousVisibility) {
                    engine.flushBuffer();
                    previousVisibility = visibility;
                    if (visibility == NodeVisibility.transparent) {
                      engine.color = colorTransparent;
                    } else {
                      engine.color = Colors.white;
                    }
                  }

                  switch (nodeType) {
                    case NodeType.Rain_Falling:
                      renderNodeRainFalling(
                        dstX: dstX,
                        dstY: dstY,
                        color: nodeColors[nodeIndex],
                        rainType: rainType,
                        windType: windType,
                        animationFrame: animationFrame1 + nodeRandoms[nodeIndex],
                      );
                      break;

                    case NodeType.Rain_Landing:
                      if (scene.nodeTypeBelowIs(nodeIndex, NodeType.Water)) {
                        renderNodeRainLandingOnWater(
                          dstX: dstX,
                          dstY: dstY,
                          variation: nodeRandoms[nodeIndex],
                          color: scene.getColor(nodeIndex),
                          rainType: rainType,
                        );
                      } else {
                        renderNodeRainLanding(
                          dstX: dstX,
                          dstY: dstY,
                          color: nodeColors[nodeIndex],
                          rainType: rainType,
                          windType: windType,
                          animationFrame: animationFrame1 + variations[nodeIndex],
                        );
                      }
                      break;

                    default:
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
                      break;
                  }
                }
              }
            } else {
              final skips = scene.emptyNodes[nodeIndex];
              totalSkipped += skips;
              row += skips;
              column -= skips;
              nodeIndex += skips * shiftRight;
              dstX += skips * Node_Sprite_Width;
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
    engine.color = Colors.white;

    if (plainIndex <= totalPlains) {
      onPlainIndexChanged();
      return;
    }
    end();
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
        + (plainStartZ * Node_Size)
        + orderShiftY;
  }

  @override
  void updateFunction() {

  }

  @override
  int getTotal() => scene.totalNodes;

  @override
  void reset() {
    totalSkipped = 0;
    rainType = environment.rainType.value;
    windType = environment.wind.value;
    final scene = this.scene;

    if (lightningFlashing) {
      final lightningColorMax = lerpColors(colors.white.value, 0, environment.brightness);
      final ambientBrightness = lerpColors(scene.ambientColor, 0, environment.brightness);
      lightningColor = lerpColors(ambientBrightness, lightningColorMax, environment.lightningFlashing01 * goldenRatio_0618);
    }

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

    resetNodeVisibilityStack(scene);
    scene.resetNodeVisibility();
    beamTotal = 0;

    // var searchIndex = 0;
    // if (scene.nodeOrientations[scene.area + scene.area] == NodeOrientation.None){
    //   searchIndex = player.nodeIndex + scene.area + scene.area;
    // } else {
    //   searchIndex = player.nodeIndex + scene.area;
    // }
    // scene.emitHeightMapIsland(searchIndex);
    // scene.emitHeightMapIsland(player.nodeIndex + scene.area);
    scene.emitHeightMapIsland(player.nodeIndex);
    ensureVisible2(player.nodeIndex);

    if (player.indexRow + 1 < scene.totalRows - 1){
      ensureVisible2(player.nodeIndex + scene.totalColumns);
    }

    if (player.indexColumn + 1 < scene.totalColumns - 1){
      ensureVisible2(player.nodeIndex + 1);
    }

    if (player.indexRow + 1 < scene.totalRows - 1 && player.indexColumn + 1 < scene.totalColumns - 1){
      ensureVisible2(player.nodeIndex + scene.totalColumns + 1);
    }


    total = getTotal();
    remaining = total > 0;
    scene.resetNodeColorStack();
    scene.resetNodeAmbientStack();
    scene.applyEmissions();
    index = 0;
    skipPlainsAboveScreenTop();
    render.highlightAimTargetEnemy();
  }

  void ensureVisible2(int index){
    ensureVisible(index);
    ensureVisible(index + scene.area);
  }

  void ensureVisible(int index) {
    if (index < 0 || index >= this.totalNodes){
      return;
    }

    var projectionIndex = index;
    var zi = 0;
    final scene = this.scene;
    final totalNodes = this.totalNodes;
    final orientations = scene.nodeOrientations;
    final area = scene.area;
    final projection = scene.projection;
    final visited2D = scene.visited2D;

    while (projectionIndex < totalNodes){
      if (!const [
        NodeOrientation.None,
        NodeOrientation.Radial,
      ].contains(orientations[projectionIndex])){
        if (!visited2D[projectionIndex % area]){
          scene.emitHeightMapIsland(projectionIndex - (zi * area));
        }
      }
      projectionIndex += projection;
      zi++;
    }
  }

  void resetNodeVisibilityStack(IsometricScene scene) {
    final total = nodeVisibilityStackIndex;
    final stack = nodeVisibilityStack;
    final nodeVisibility = scene.nodeVisibility;
    for (var i = 0; i < total; i++){
       nodeVisibility[stack[i]] = NodeVisibility.opaque;
    }
    nodeVisibilityStackIndex = 0;
  }

  void skipPlainsAboveScreenTop() {

    final maxColumns = totalColumns - 1;
    final maxRows = totalRows - 1;
    final screenTop = this.screenTop;

    var skipped = 0;
    var column = 0;
    var row = 0;

    while (true){
      var renderY = getRenderYfOfRowColumn(row, column);

      if (renderY >= screenTop){
        break;
      }

      if (column < maxColumns){
        column++;
      } else if (row < maxRows){
        row++;
      } else {
        break;
      }
      skipped++;
    }
    index = skipped;
  }

  void increaseOrderShiftY(){
    orderShiftY++;
  }

  void decreaseOrderShiftY(){
    orderShiftY--;
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

    switch (nodeType) {

      case NodeType.Water:
        renderNodeWater(
          dstX: dstX,
          dstY: dstY,
          color: scene.colorAbove(index),
          animationFrame: ((animation.frameWater + ((scene.getRowColumn(index)) * 3)) % 10), // TODO Optimize
        );
        break;
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

      case NodeType.Tree_Stump:
        renderNodeTypeTreeStump(
          colorSouth: scene.colorSouth(index),
          colorWest: scene.colorWest(index),
          color: color,
          dstX: dstX,
          dstY: dstY,
        );
        return;

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
        final nodeVariationBelow = scene.nodeVariations[index - scene.area]; // TODO Optimize
        final row = scene.getRow(index);
        final column = scene.getColumn(index);
        renderNodeTreeTop(
          dstX: dstX,
          dstY: dstY,
          treeType: mapVariationToTreeType(nodeVariationBelow),
          colorWest: scene.colorWest(index),
          colorSouth: scene.colorSouth(index),
          colorNorth: scene.colorNorth(index),
          colorEast: scene.colorEast(index),
          animationFrame: row + column + animation.frame1, // TODO Optimize
        );
        break;
      case NodeType.Tree_Bottom:
        final row = scene.getRow(index);
        final column = scene.getRow(index);
        renderNodeTreeBottom(
          dstX: dstX,
          dstY: dstY,
          treeType: mapVariationToTreeType(variation),
          colorNorth: scene.colorNorth(index),
          colorEast: scene.colorEast(index),
          colorSouth: scene.colorSouth(index),
          colorWest: scene.colorWest(index),
          animationFrame: row + column + animation.frame1, // TODO Optimize
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
          wind: wind, // TODO Optimize
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
            srcX: 1343 + (animation.frame6 * 16), // TODO Optimize
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
            srcX: 1343 + (animation.frame6 * 16), // TODO Optimize
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
          animationFrame: wind == WindType.Calm // TODO Optimize
              ? 0
              : (((row - column) + animation.frame6) % 6), // TODO Optimize
        );
        break;
      case NodeType.Grass_Short:

        renderStandardNode(
          dstX: dstX,
          dstY: dstY,
          srcX: 848 + variation * 50,
          srcY: 0,
          color: color,
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
          colorNorth: scene.colorNorth(index),
          colorEast: scene.colorEast(index),
          colorSouth: scene.colorSouth(index),
          colorWest: scene.colorWest(index),
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
          color: scene.nodeColors[index], // TODO Optimize
          orientation: scene.nodeOrientations[index], // TODO Optimize
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
        throw Exception('renderNode(index: ${index}, orientation: ${NodeOrientation.getName(scene.nodeOrientations[index])}');
    }
  }

  void renderNodeTypeTreeStump({
    required int colorSouth,
    required int colorWest,
    required int color,
    required double dstX,
    required double dstY,
  }) {
    renderStandardNode(
      color: color,
      srcX: 292,
      srcY: 1545,
      dstX: dstX,
      dstY: dstY,
    );

    renderStandardNode(
      color: colorWest,
      srcX: 243,
      srcY: 1545,
      dstX: dstX,
      dstY: dstY,
    );

    renderStandardNode(
      color: colorSouth,
      srcX: 341,
      srcY: 1545,
      dstX: dstX,
      dstY: dstY,
    );
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
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
  }) {
    const anchorY = 0.28;
    const size = 46.0;
    final atlasNodes = this.atlasNodes;
    final engine = this.engine;

    engine.renderSprite(
      image: atlasNodes,
      srcX: 1264 + (size * 4),
      srcY: 448,
      srcWidth: size,
      srcHeight: size,
      dstX: dstX,
      dstY: dstY,
      color: colorNorth,
      anchorY: anchorY,
    );

    engine.renderSprite(
      image: atlasNodes,
      srcX: 1264,
      srcY: 448,
      srcWidth: size,
      srcHeight: size,
      dstX: dstX,
      dstY: dstY,
      color: colorNorth,
      anchorY: anchorY,
    );

    engine.renderSprite(
      image: atlasNodes,
      srcX: 1264 + size,
      srcY: 448,
      srcWidth: size,
      srcHeight: size,
      dstX: dstX,
      dstY: dstY,
      color: colorEast,
      anchorY: anchorY,
    );

    engine.renderSprite(
      image: atlasNodes,
      srcX: 1264 + size + size,
      srcY: 448,
      srcWidth: size,
      srcHeight: size,
      dstX: dstX,
      dstY: dstY,
      color: colorSouth,
      anchorY: anchorY,
    );

    engine.renderSprite(
      image: atlasNodes,
      srcX: 1264 + size + size + size,
      srcY: 448,
      srcWidth: size,
      srcHeight: size,
      dstX: dstX,
      dstY: dstY,
      color: colorWest,
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
        srcY: 72.0 * ((animation.frame1 + variation) % 8), // TODO Expensive Operation
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
    final column = animationFrame % 6;
    renderStandardNode(
      color: color,
      srcX: 1596 + (column * 48),
      srcY: 1306 + (row * 72),
      dstX: dstX,
      dstY: dstY,
    );
  }

  void renderNodeRainLanding({
    required double dstX,
    required double dstY,
    required int color,
    required int rainType,
    required int windType,
    required int animationFrame,
  }) {
    final row =  (rainType == RainType.Heavy ? 3 : 0) + windType;
    final column = animationFrame % 6;
    renderStandardNode(
      color: color,
      srcX: 1307 + (column * 48),
      srcY: 1306 + (row * 72),
      dstX: dstX,
      dstY: dstY,
    );
  }

  void renderNodeTreeTop({
    required double dstX,
    required double dstY,
    required int treeType,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    required int animationFrame,
  }) =>
      treeType == TreeType.Pine
          ? renderTreeTopPine(
              dstX: dstX,
              dstY: dstY,
              colorNorth: colorNorth,
              colorEast: colorEast,
              colorSouth: colorSouth,
              colorWest: colorWest,
              animationFrame: animationFrame,
            )
          : renderTreeTopOak(
              dstX: dstX,
              dstY: dstY,
              colorNorth: colorNorth,
              colorEast: colorEast,
              colorSouth: colorSouth,
              colorWest: colorWest,
              animationFrame: animationFrame,
            );

  void renderNodeTreeBottom({
    required double dstX,
    required double dstY,
    required int treeType,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    required int animationFrame,
  }) =>
      treeType == TreeType.Pine
          ? renderTreeBottomPine(
              dstX: dstX,
              dstY: dstY,
              colorNorth: colorNorth,
              colorEast: colorEast,
              colorSouth: colorSouth,
              colorWest: colorWest,
              animationFrame: animationFrame,
            )
          : renderTreeBottomOak(
              dstX: dstX,
              dstY: dstY,
              colorNorth: colorNorth,
              colorEast: colorEast,
              colorWest: colorWest,
              colorSouth: colorSouth,

              animationFrame: animationFrame,
            );

  void renderTreeTopOak({
    required double dstX,
    required double dstY,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    required int animationFrame,
  }) {
    final shift = treeAnimation[animationFrame % treeAnimationLength] * wind;
    final shiftRotation = treeAnimation[(animationFrame - 2) % treeAnimationLength] * wind;
    final rotation = shiftRotation * 0.0066;
    final engine = this.engine;
    final atlasNodes = this.atlasNodes;
    const anchorY = 0.82;

    const srcX = 656.0;
    const srcY = 1454.0;
    const srcWidth = 48.0;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 4),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorWest,
      rotation: rotation,
      anchorY: anchorY,
    );

    // south
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 5),
      srcY: srcY,
      srcWidth: srcWidth,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );

    // north
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 7),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorNorth,
      rotation: rotation,
      anchorY: anchorY,
    );

    // east
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 6),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorEast,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeTopPine({
    required double dstX,
    required double dstY,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    required int animationFrame,
}) {
    final shift = treeAnimation[animationFrame % treeAnimationLength] * wind;
    final shiftRotation = treeAnimation[(animationFrame - 2) % treeAnimationLength] * wind;
    final rotation = shiftRotation * 0.0066;
    final engine = this.engine;
    final atlasNodes = this.atlasNodes;
    const anchorY = 0.82;

    const srcX = 656.0;
    const srcY = 1527.0;
    const srcWidth = 48.0;

    // west
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

    // south
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

    // north
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 7),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorNorth,
      rotation: rotation,
      anchorY: anchorY,
    );

    // east
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 6),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX + (shift * 0.5),
      dstY: dstY + 40,
      color: colorEast,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeBottomOak({
    required double dstX,
    required double dstY,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    required int animationFrame,
  }) {
    const anchorY = 0.72;
    const dstYShift = 32;
    const srcX = 656.0;
    const srcY = 1454.0;
    const srcWidth = 48.0;

    final shiftRotation = treeAnimation[animationFrame % treeAnimationLength] * wind;
    final rotation = shiftRotation * 0.013;
    final engine = this.engine;
    final atlasNodes = this.atlasNodes;

    // west
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX,
      srcY: srcY,
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
      srcX: srcX + srcWidth * 1,
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
      color: colorSouth,
      rotation: rotation,
      anchorY: anchorY,
    );

    // north
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 3),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
      color: colorNorth,
      rotation: rotation,
      anchorY: anchorY,
    );

    // east
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 2),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
      color: colorEast,
      rotation: rotation,
      anchorY: anchorY,
    );
  }

  void renderTreeBottomPine({
    required double dstX,
    required double dstY,
    required int colorNorth,
    required int colorEast,
    required int colorSouth,
    required int colorWest,
    required int animationFrame,
  }) {
    const anchorY = 0.72;
    const dstYShift = 32;
    const srcX = 656.0;
    const srcY = 1527.0;
    const srcWidth = 48.0;

    final shiftRotation = treeAnimation[animationFrame % treeAnimationLength] * wind;
    final rotation = shiftRotation * 0.013;
    final engine = this.engine;
    final atlasNodes = this.atlasNodes;

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

    // north
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 3),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
      color: colorNorth,
      rotation: rotation,
      anchorY: anchorY,
    );

    // east
    engine.renderSpriteRotated(
      image: atlasNodes,
      srcX: srcX + (srcWidth * 2),
      srcY: srcY,
      srcWidth: Src_Width_Sprite_Tree,
      srcHeight: Src_Height_Sprite_Tree,
      dstX: dstX,
      dstY: dstY + dstYShift,
      color: colorEast,
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

  /// TODO optimize
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

  void renderColumn({
    required int colorSouth,
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorAbove,
  }) {

    // west
    engine.render(
      color: colorWest,
      srcLeft: 64,
      srcTop: srcY + 17,
      srcRight: 64 + 8,
      srcBottom: srcY + 48,
      scale: 1.0,
      rotation: 0,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY,
    );

    // south
    engine.render(
      color: colorSouth,
      srcLeft: 74,
      srcTop: srcY + 16,
      srcRight: 74 + 8,
      srcBottom: srcY + 48,
      scale: 1.0,
      rotation: 0,
      dstX: dstX,
      dstY: dstY,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_South_Width,
      dstY: dstY - 8,
      color: colorAbove,
    );
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
      color: colorAbove,
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
      color: colorAbove,
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
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
    );

    renderCellTop(
      srcY: srcY,
      dstX: dstX - Cell_Size_Half - Cell_Size_Half,
      dstY: dstY + Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorAbove,
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
    required Int32List clr,
    required Float32List src,
    required Float32List dst,
  }) {

    final renderFast = engine.renderFast;

    renderFast(
      color: colorAbove,
      srcLeft: srcX,
      srcTop: srcY,
      srcRight: srcX + Src_Width_Side_Top,
      srcBottom: srcY + Src_Height_Side_Top,
      scale: 1.0,
      rotation: 0,
      dstX: dstX - Node_Size_Half,
      dstY: dstY - Node_Size_Half,
      clr: clr,
      dst: dst,
      src: src,
    );

    renderFast(
      color: colorWest,
      srcLeft: srcX + Src_X_Side_West,
      srcTop: srcY,
      srcRight: srcX + Src_X_Side_West + Src_Width_Side_West,
      srcBottom: srcY + Src_Height_Side_West,
      scale: 1.0,
      rotation: 0,
      dstX: dstX - Node_Size_Half,
      dstY: dstY,
      clr: clr,
      dst: dst,
      src: src,
    );

    renderFast(
      color: colorSouth,
      srcLeft: srcX + Src_X_Side_South,
      srcTop: srcY,
      srcRight: srcX + Src_X_Side_South + Src_Width_Side_South,
      srcBottom: srcY + Src_Height_Side_South,
      scale: 1.0,
      rotation: 0,
      dstX: dstX,
      dstY: dstY,
      clr: clr,
      dst: dst,
      src: src,
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

  static int toRawVelocity(int x, int y, int z) =>
      parseSigned(x) | (parseSigned(y) << 2) | parseSigned(z) << 4;

  static int parseSigned(int value) => switch (value) {
        0 => 0x0,
        1 => 0x1,
        -1 => 0x2,
        _ => (throw Exception()),
      };

  static int parseRaw(int raw) => switch(raw) {
      0 => 0,
      1 => 1,
      2 => -1,
      _ => (throw Exception(raw))
    };

  final beamIndexesSrc = Uint16List(1000);
  final beamIndexesTgt = Uint16List(1000);
  final beamVelocities = Uint8List(1000);
  final beamDistance = Uint8List(1000);
  var beamTotal = 0;


  void emitVisibilityVertical(int index, int value) {

    final scene = this.scene;
    final total = scene.totalNodes;
    final nodeVisibility = scene.nodeVisibility;
    final nodeVisibilityStack = this.nodeVisibilityStack;
    final area = scene.area;

    while (index < total) {
      nodeVisibility[index] = value;
      nodeVisibilityStack[nodeVisibilityStackIndex++] = index;
      index += area;
    }
  }


  var nodeVisibilityStack = Uint16List(10000);
  var nodeVisibilityStackIndex = 0;

  void renderVisibilityBeams() {
    engine.color = Colors.white;
    for (var i = 0; i < beamTotal; i++){
      if (beamDistance[i] <= 0) continue;
      final indexSrc = beamIndexesSrc[i];
      final indexTgt = beamIndexesTgt[i];
      render.lineBetweenIndexes(indexSrc, indexTgt);
    }
  }

  void setProjectionTransparent(int targetIndex) {

    while (targetIndex < scene.totalNodes){
      if (scene.nodeOrientations[targetIndex] == NodeOrientation.None)
        continue;

      scene.nodeVisibility[targetIndex] = NodeVisibility.transparent;
      nodeVisibilityStack[nodeVisibilityStackIndex++] = targetIndex;
      targetIndex += scene.projection;
    }
  }

  static bool orientationBlocksVelocity(int vx, int vy, int orientation){
     if (orientation == NodeOrientation.None)
       return false;
     if (orientation == NodeOrientation.Solid)
       return true;

     if (vx != 0){
       return const [
         NodeOrientation.Half_North,
         NodeOrientation.Half_South,
       ].contains(orientation);
     }

     if (vy != 0){
       return const [
         NodeOrientation.Half_West,
         NodeOrientation.Half_East,
       ].contains(orientation);
     }

     return false;

  }

  void emitHeightMapBeam(int index) {
    if (index < 0)
      return;

    final scene = this.scene;

    if (index >= scene.totalNodes)
      return;

    final orientations = scene.nodeOrientations;
    final beamIndexesSrc = this.beamIndexesSrc;
    final beamIndexesTgt = this.beamIndexesTgt;
    final beamVelocities = this.beamVelocities;
    final beamDistance = this.beamDistance;
    final area = scene.area;
    final totalNodes = scene.totalNodes;
    final totalRows = scene.totalRows;
    final totalColumns = scene.totalColumns;
    final totalZ = scene.totalZ;

    final initialZ = scene.getIndexZ(index);

    var beamI = 0;
    var beamTotal = 0;

    for (var vx = -1; vx <= 1; vx++) {
      for (var vy = -1; vy <= 1; vy++) {
        beamIndexesTgt[beamTotal] = index;
        beamDistance[beamTotal] = 0;
        final raw = toRawVelocity(vx, vy, 0);
        beamVelocities[beamTotal] = raw;
        beamTotal++;
      }
    }

    while (beamI < beamTotal) {
      final srcIndex = beamIndexesTgt[beamI];
      final velocity = beamVelocities[beamI];
      final distance = beamDistance[beamI];
      beamI++;

      final vxRaw = velocity & 0x3;
      final vyRaw = (velocity >> 2) & 0x3;
      final vx = parseRaw(vxRaw);
      final vy = parseRaw(vyRaw);

      final row = scene.getRow(srcIndex) + vx;
      final column = scene.getColumn(srcIndex) + vy;
      final z = scene.getIndexZ(srcIndex);

      if (
          row < 0 ||
          column < 0 ||
          z < 0 ||
          row >= totalRows ||
          column >= totalColumns ||
          z >= totalZ
      )
        continue;


      var targetIndex = scene.getIndexZRC(z, row, column);

      if (scene.getHeightMapHeightAt(targetIndex) < initialZ) {
        continue;
      }

      if ((vx > 0 || vy > 0) && !(vx < 0 || vy < 0)) {
        var i = scene.getIndexZRC(initialZ, row, column);
        emitVisibilityVertical(i, NodeVisibility.invisible);
      } else {

        while (
          targetIndex < totalNodes &&
          orientationBlocksVelocity(vx, vy, orientations[targetIndex])
        ) {
          targetIndex += area;
        }

        if (targetIndex >= totalNodes){
          continue;
        } else {
          emitVisibilityVertical(targetIndex, NodeVisibility.invisible);
        }

      }

      if (distance >= 10)
        continue;

      if (vx != 0){
        beamIndexesSrc[beamTotal] = srcIndex;
        beamIndexesTgt[beamTotal] = targetIndex;
        beamVelocities[beamTotal] =  vxRaw;
        beamDistance[beamTotal] =  distance + 1;
        beamTotal++;

        if (vy != 0){
          beamIndexesSrc[beamTotal] = srcIndex;
          beamIndexesTgt[beamTotal] = targetIndex;
          beamVelocities[beamTotal] =  vxRaw | (vyRaw << 2);
          beamDistance[beamTotal] =  distance + 2;
          beamTotal++;
        }
      }

      if (vy != 0){
        beamIndexesSrc[beamTotal] = srcIndex;
        beamIndexesTgt[beamTotal] = targetIndex;
        beamVelocities[beamTotal] =  vyRaw << 2;
        beamDistance[beamTotal] =  distance + 1;
        beamTotal++;
      }

      if (vx != 0 && vy != 0){
        beamIndexesSrc[beamTotal] = srcIndex;
        beamIndexesTgt[beamTotal] = targetIndex;
        beamVelocities[beamTotal] =  velocity;
        beamDistance[beamTotal] =  distance + 2;
        beamTotal++;
      }
    }

    this.beamTotal = beamTotal;

  }




}



int mapVariationToTreeType(int variation){
  if (variation == 0) {
    return TreeType.Oak;
  }
  return TreeType.Pine;

}