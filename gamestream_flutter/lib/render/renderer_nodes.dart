import 'dart:math';

import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/library.dart';

class RendererNodes extends Renderer {

  // VARIABLES
  var previousVisibility = 0;

  final bufferClr = Engine.bufferClr;
  final bufferSrc = Engine.bufferSrc;
  final bufferDst = Engine.bufferDst;
  final atlas = GameImages.atlas_nodes;

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
  var currentNodeDstX = 0.0;
  var currentNodeDstY = 0.0;
  var currentNodeIndex = 0;
  var currentNodeType = 0;

  var offscreenNodesTop = 0;
  var offscreenNodesRight = 0;
  var offscreenNodesBottom = 0;
  var offscreenNodesLeft = 0;

  var onscreenNodes = 0;
  var offscreenNodes = 0;

  var nodesRowsMax = 0;
  var nodesShiftIndex = 0;
  var nodesScreenTopLeftRow = 0;
  var nodesScreenBottomRightRow = 0;
  var nodesGridTotalColumnsMinusOne = 0;
  var nodesGridTotalZMinusOne = 0;
  var nodesPlayerColumnRow = 0;
  var nodesPlayerUnderRoof = false;

  var playerZ = 0;
  var playerRow = 0;
  var playerColumn = 0;

  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var screenLeft = 0.0;

  var nodeTypes = GameNodes.nodesType;

  // GETTERS

  // double get currentNodeRenderX => (currentNodeRow - currentNodeColumn) * Node_Size_Half;
  double get currentNodeRenderY => GameConvert.rowColumnZToRenderY(row, column, currentNodeZ);

  int get currentNodeShade => GameNodes.nodesShade[currentNodeIndex];
  int get currentNodeColor => (currentNodeVisibilityOpaque ? GameLighting.values : GameLighting.values_transparent)[currentNodeShade];
  int get currentNodeOrientation => GameNodes.nodesOrientation[currentNodeIndex];
  int get currentNodeVisibility => GameNodes.nodesVisible[currentNodeIndex];
  int get currentNodeWind => GameNodes.nodesWind[currentNodeIndex];

  bool get currentNodeVisible => currentNodeVisibility == Visibility.Invisible;
  bool get currentNodeInvisible => currentNodeVisibility == Visibility.Invisible;
  bool get currentNodeVisibilityOpaque => GameNodes.nodesVisible[currentNodeIndex] == Visibility.Opaque;
  bool get currentNodeVariation => GameNodes.nodesVariation[currentNodeIndex];

  int get renderNodeShade => GameNodes.nodesShade[currentNodeIndex];
  int get renderNodeOrientation => GameNodes.nodesOrientation[currentNodeIndex];
  int get renderNodeColor => GameLighting.values[renderNodeShade];
  int get renderNodeWind => GameNodes.nodesWind[renderNodeShade];
  bool get renderNodeVariation => GameNodes.nodesVariation[currentNodeIndex];

  int get renderNodeBelowIndex => currentNodeIndex - GameNodes.nodesArea;
  bool get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? GameNodes.nodesVariation[renderNodeBelowIndex] : renderNodeVariation;

  int get renderNodeBelowShade {
    if (renderNodeBelowIndex < 0) return ServerState.ambientShade.value;
    if (renderNodeBelowIndex >= GameNodes.nodesTotal) return ServerState.ambientShade.value;
    return GameNodes.nodesShade[renderNodeBelowIndex];
  }

  int get renderNodeBelowColor => GameLighting.values[renderNodeBelowShade];

  // METHODS

  @override
  void renderFunction() {
    Engine.bufferImage = atlas;
    while (
        column >= 0            &&
        row    <= nodesRowsMax &&
        currentNodeDstX   <= screenRight
    ){
      currentNodeType = nodeTypes[currentNodeIndex];
      if (currentNodeType != NodeType.Empty){
        renderCurrentNode();
      }
      if (row + 1 > nodesRowsMax) return;
      row++;
      column--;
      currentNodeIndex += nodesGridTotalColumnsMinusOne;
      currentNodeDstX += GameConstants.Sprite_Width;
    }
  }
  @override
  void updateFunction() {
    currentNodeZ++;
    if (currentNodeZ > nodesMaxZ) {
      currentNodeZ = 0;
      nodesShiftIndexDown();
      if (!remaining) return;
      nodesCalculateMinMaxZ();
      if (!remaining) return;

      assert (column >= 0);
      assert (row >= 0);
      assert (row < GameState.nodesTotalRows);
      assert (column < GameState.nodesTotalColumns);

      trimLeft();

      while (currentNodeRenderY > screenBottom) {
        currentNodeZ++;
        if (currentNodeZ > nodesMaxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      assert (nodesStartRow < GameState.nodesTotalRows);
      assert (column < GameState.nodesTotalColumns);
      row = nodesStartRow;
      column = nodeStartColumn;
    }

    currentNodeIndex = (currentNodeZ * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
    assert (currentNodeZ >= 0);
    assert (row >= 0);
    assert (column >= 0);
    assert (currentNodeIndex >= 0);
    assert (currentNodeZ < GameState.nodesTotalZ);
    assert (row < GameState.nodesTotalRows);
    assert (column < GameState.nodesTotalColumns);
    assert (currentNodeIndex < GameNodes.nodesTotal);
    currentNodeDstX = (row - column) * Node_Size_Half;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeType = GameNodes.nodesType[currentNodeIndex];
    order = ((row + column) * Node_Size) + Node_Size_Half;
    orderZ = currentNodeZ;
  }

  @override
  void reset() {
    nodeTypes = GameNodes.nodesType;
    nodesRowsMax = GameState.nodesTotalRows - 1;
    nodesGridTotalZMinusOne = GameState.nodesTotalZ - 1;
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    offscreenNodes = 0;
    onscreenNodes = 0;
    nodesMinZ = 0;
    order = 0;
    orderZ = 0;
    currentNodeZ = 0;
    nodesGridTotalColumnsMinusOne = GameState.nodesTotalColumns - 1;
    playerZ = GamePlayer.position.indexZ;
    playerRow = GamePlayer.position.indexRow;
    playerColumn = GamePlayer.position.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (GamePlayer.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (GamePlayer.position.indexZ ~/ 2);
    nodesPlayerUnderRoof = GameState.gridIsUnderSomething(playerZ, playerRow, playerColumn);

    screenRight = Engine.screen.right + Node_Size;
    screenLeft = Engine.screen.left - Node_Size;
    screenTop = Engine.screen.top - 72;
    screenBottom = Engine.screen.bottom + 72;
    var screenTopLeftColumn = GameConvert.convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(GameConvert.convertWorldToRow(screenRight, screenBottom, 0), 0, GameState.nodesTotalRows - 1);
    nodesScreenTopLeftRow = GameConvert.convertWorldToRow(screenLeft, screenTop, 0);

    if (nodesScreenTopLeftRow < 0){
      screenTopLeftColumn += nodesScreenTopLeftRow;
      nodesScreenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      nodesScreenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= GameState.nodesTotalColumns){
      nodesScreenTopLeftRow = screenTopLeftColumn - nodesGridTotalColumnsMinusOne;
      screenTopLeftColumn = nodesGridTotalColumnsMinusOne;
    }
    if (nodesScreenTopLeftRow < 0 || screenTopLeftColumn < 0){
      nodesScreenTopLeftRow = 0;
      screenTopLeftColumn = 0;
    }

    row = nodesScreenTopLeftRow;
    column = screenTopLeftColumn;

    nodesShiftIndex = 0;
    nodesCalculateMinMaxZ();
    nodesTrimTop();
    trimLeft();

    currentNodeDstX = (row - column) * Node_Size_Half;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeIndex = (currentNodeZ * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
    currentNodeType = nodeTypes[currentNodeIndex];

    GameNodes.resetVisible();

    showIndexPlayer();
    showIndexMouse();

    total = getTotal();
    index = 0;
    remaining = total > 0;
    GameNodes.resetStackDynamicLight();
    GameState.applyEmissions();

    if (GameState.editMode){
      GameNodes.applyEmissionDynamic(
        index: GameEditor.nodeSelectedIndex.value,
        maxBrightness: Shade.Very_Bright,
      );
    }

    highlightCharacterNearMouse();
  }
  @override
  int getTotal() => GameNodes.nodesTotal;

  void trimLeft(){
    var currentNodeRenderX = (row - column) * Node_Size_Half;
    while (currentNodeRenderX < screenLeft && column > 0){
      row++;
      column--;
      currentNodeRenderX += Node_Size;
    }
    nodesSetStart();
  }

  void nodesSetStart(){
    // nodesStartRow = min(currentNodeRow, GameState.nodesTotalRows);
    nodesStartRow = clamp(row, 0, GameState.nodesTotalRows - 1);
    nodeStartColumn = clamp(column, 0, GameState.nodesTotalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < GameState.nodesTotalRows);
    assert (nodeStartColumn < GameState.nodesTotalColumns);
  }

  void nodesShiftIndexDown(){

    column = row + column + 1;
    row = 0;
    if (column < GameState.nodesTotalColumns) {
      nodesSetStart();
      return;
    }

    if (column - nodesGridTotalColumnsMinusOne >= GameState.nodesTotalRows){
      remaining = false;
      return;
    }

    row = column - nodesGridTotalColumnsMinusOne;
    column = nodesGridTotalColumnsMinusOne;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    nodesSetStart();
  }

  void nodesCalculateMinMaxZ(){
    final bottom = (row + column) * Node_Size_Half;
    final distance =  bottom - screenTop;
    nodesMaxZ = (distance ~/ Node_Height); // TODO optimize
    if (nodesMaxZ > nodesGridTotalZMinusOne){
      nodesMaxZ = nodesGridTotalZMinusOne;
    }
    if (nodesMaxZ < 0){
      nodesMaxZ = 0;
    }

    var renderY = bottom - (nodesMinZ * Node_Height);
    while (renderY > screenBottom){
      nodesMinZ++;
      renderY -= Node_Height;
      if (nodesMinZ >= GameState.nodesTotalZ){
        return end();
      }
    }
  }

  void nodesTrimTop() {
    while (currentNodeRenderY < screenTop){
      nodesShiftIndexDown();
    }
    nodesCalculateMinMaxZ();
    nodesSetStart();
  }


  void renderNodeTorch(){
    if (!ClientState.torchesIgnited.value) {
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch,
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: currentNodeColor,
      );
      return;
    }
    if (renderNodeWind == WindType.Calm){
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((row + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: currentNodeColor,
      );
      return;
    }
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNode.X_Torch_Windy,
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((row + (GameAnimation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
      color: currentNodeColor,
    );
    return;
  }

  void renderCurrentNode() {
    if (currentNodeVisibility == Visibility.Invisible) return;

    if (currentNodeVisibility != previousVisibility){
      previousVisibility = currentNodeVisibility;
      Engine.bufferBlendMode = VisibilityBlendModes.fromVisibility(currentNodeVisibility);
    }

    switch (currentNodeType) {
      case NodeType.Grass:
        if (currentNodeOrientation == NodeOrientation.Solid){
          if (currentNodeVariation){
            renderStandardNodeShaded(
              srcX: 624,
              srcY: 0,
            );
            return;
          }
        }
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_3);
        return;
      case NodeType.Brick:
        const index_grass = 2;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        return;
      case NodeType.Torch:
        renderNodeTorch();
        break;
      case NodeType.Water:
        renderNodeWater();
        break;
      case NodeType.Tree_Bottom:
        renderTreeBottom();
        break;
      case NodeType.Tree_Top:
        renderTreeTop();
        break;
      case NodeType.Grass_Long:
        switch (currentNodeWind) {
          case WindType.Calm:
            renderStandardNodeShaded(
              srcX: AtlasNodeX.Grass_Long,
              srcY: 0,
            );
            return;
          default:
            renderStandardNodeShaded(
              srcX: AtlasNodeX.Grass_Long + ((((row - column) + GameAnimation.animationFrameGrass) % 6) * 48), // TODO Expensive Operation
              srcY: 0,
            );
            return;
        }
      case NodeType.Rain_Falling:
        renderStandardNodeShaded(
          srcX: ClientState.srcXRainFalling,
          srcY: 72.0 * ((GameAnimation.animationFrame + row + row + column) % 6), // TODO Expensive Operation
        );
        return;
      case NodeType.Rain_Landing:
        if (GameQueries.getNodeTypeBelow(currentNodeIndex) == NodeType.Water){
          Engine.renderSprite(
            image: GameImages.atlas_nodes,
            srcX: AtlasNode.Node_Rain_Landing_Water_X,
            srcY: 72.0 * ((GameAnimation.animationFrame + row + column) % 10), // TODO Expensive Operation
            srcWidth: GameConstants.Sprite_Width,
            srcHeight: GameConstants.Sprite_Height,
            dstX: currentNodeDstX,
            dstY: currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
            anchorY: 0.3,
            color: currentNodeColor,
          );
          return;
        }
        renderStandardNodeShaded(
          srcX: ClientState.srcXRainLanding,
          srcY: 72.0 * ((GameAnimation.animationFrame + row + column) % 6), // TODO Expensive Operation
        );
        return;
      case NodeType.Concrete:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_8);
        return;
      case NodeType.Metal:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_4);
        return;
      case NodeType.Road:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_9);
        return;
      case NodeType.Road_2:
        renderStandardNodeShaded(srcX: 768, srcY: 672 + GameConstants.Sprite_Height_Padded);
        return;
      case NodeType.Wooden_Plank:
        renderNodeWoodenPlank();
        return;
      case NodeType.Wood:
        const index_grass = 5;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
      case NodeType.Bau_Haus:
        const index_grass = 6;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
      case NodeType.Sunflower:
        renderStandardNodeShaded(
          srcX: 1753.0,
          srcY: AtlasNodeY.Sunflower,
        );
        return;
      case NodeType.Soil:
        const index_grass = 7;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        return;
      case NodeType.Fireplace:
        renderStandardNode(
          srcX: AtlasNode.Campfire_X,
          srcY: AtlasNode.Node_Campfire_Y + ((GameAnimation.animationFrame % 6) * 72),
        );
        return;
      case NodeType.Boulder:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Boulder,
          srcY: AtlasNodeY.Boulder,
        );
        return;
      case NodeType.Oven:
        renderStandardNodeShaded(
          srcX: AtlasNodeX.Oven,
          srcY: AtlasNodeY.Oven,
        );
        return;
      case NodeType.Chimney:
        renderStandardNodeShaded(
          srcX: AtlasNode.Chimney_X,
          srcY: AtlasNode.Node_Chimney_Y,
        );
        return;
      case NodeType.Window:
        renderNodeWindow();
        break;
      case NodeType.Spawn:
        if (GameState.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_X,
          srcY: AtlasNode.Spawn_Y,
        );
        break;
      case NodeType.Spawn_Weapon:
        if (GameState.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_Weapon_X,
          srcY: AtlasNode.Spawn_Weapon_Y,
        );
        break;
      case NodeType.Spawn_Player:
        if (GameState.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_Player_X,
          srcY: AtlasNode.Spawn_Player_Y,
        );
        break;
      case NodeType.Table:
        renderStandardNode(
          srcX: AtlasNode.Table_X,
          srcY: AtlasNode.Node_Table_Y,
        );
        return;
      case NodeType.Bed_Top:
        renderStandardNode(
          srcX: AtlasNode.X_Bed_Top,
          srcY: AtlasNode.Y_Bed_Top,
        );
        return;
      case NodeType.Bed_Bottom:
        renderStandardNode(
          srcX: AtlasNode.X_Bed_Bottom,
          srcY: AtlasNode.Y_Bed_Bottom,
        );
        return;
      case NodeType.Respawning:
        return;
      default:
        throw Exception('renderNode(index: ${currentNodeIndex}, type: ${NodeType.getName(currentNodeType)}, orientation: ${NodeOrientation.getName(GameNodes.nodesOrientation[currentNodeIndex])}');
    }
  }

  void renderTreeTop() => renderNodeBelowVariation ? renderTreeTopPine() : renderTreeTopOak();

  void renderTreeBottom() => renderNodeVariation ? renderTreeBottomPine() : renderTreeBottomOak();

  void renderTreeTopOak(){
    var shift = GameAnimation.treeAnimation[((row - column) + GameAnimation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.Tree_Top,
      srcY: AtlasNodeY.Tree_Top,
      srcWidth: AtlasNode.Node_Tree_Top_Width,
      srcHeight: AtlasNode.Node_Tree_Top_Height,
      dstX: currentNodeDstX + (shift * 0.5),
      dstY: currentNodeDstY,
      color: getRenderLayerColor(-2),
    );
  }

  void renderTreeTopPine() {
    var shift = GameAnimation.treeAnimation[((row - column) + GameAnimation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: 1262,
      srcY: 80 ,
      srcWidth: 45,
      srcHeight: 58,
      dstX: currentNodeDstX + (shift * 0.5),
      dstY: currentNodeDstY,
      color: getRenderLayerColor(-2),
    );
  }

  void renderTreeBottomOak() {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.Tree_Bottom,
      srcY: AtlasNodeY.Tree_Bottom,
      srcWidth: AtlasNode.Width_Tree_Bottom,
      srcHeight: AtlasNode.Node_Tree_Bottom_Height,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      color: renderNodeBelowColor,
    );
  }

  void renderTreeBottomPine() {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: 1216,
      srcY: 80,
      srcWidth: 45,
      srcHeight: 66,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      color: renderNodeBelowColor,
    );
  }

  void renderNodeTemplateShaded(double srcX) {
    switch (currentNodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_00,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Top:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_03,
        );
        return;
      case NodeOrientation.Corner_Right:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_04,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_05,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_06,
        );
        return;
      case NodeOrientation.Slope_North:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_07,
        );
        return;
      case NodeOrientation.Slope_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_08,
        );
        return;
      case NodeOrientation.Slope_South:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_09,
        );
        return;
      case NodeOrientation.Slope_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_10,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_11,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_12,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_13,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_14,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_15,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_18,
        );
        return;
      case NodeOrientation.Radial:
        renderStandardNodeShaded(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_19,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: -9,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: -1,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_20,
          offsetX: 0,
          offsetY: 2,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 0,
          offsetY: -16,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: -16,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 8,
          offsetY: -8,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 0,
          offsetY: 0,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: -8,
          offsetY: 8,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 0,
          offsetY: 16,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_21,
          offsetX: 16,
          offsetY: 0,
        );
        return;
    }
  }

  void renderNodeWoodenPlank(){
    switch(renderNodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNodeShaded(
          srcX: AtlasNode.Wooden_Plank_Solid_X,
          srcY: AtlasNode.Node_Wooden_Plank_Solid_Y,
        );
        return;
      case NodeOrientation.Half_North:
        renderStandardNodeHalfNorthOld(
          srcX: AtlasNode.Node_Wooden_Plank_Half_South_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_South_Y,
          color: renderNodeColor,
        );
        return;
      case NodeOrientation.Half_East:
        renderStandardNodeHalfEastOld(
          srcX: AtlasNode.Node_Wooden_Plank_Half_West_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_West_Y,
          color: renderNodeColor,
        );
        return;
      case NodeOrientation.Half_South:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Half_South_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_South_Y,
        );
        return;
      case NodeOrientation.Half_West:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Half_West_X,
          srcY: AtlasNode.Node_Wooden_Plank_Half_West_Y,
        );
        return;
      case NodeOrientation.Corner_Top:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Top_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Top_Y,
        );
        return;
      case NodeOrientation.Corner_Right:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Right_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Right_Y,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Bottom_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Bottom_Y,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderStandardNodeShaded(
          srcX: AtlasNode.Node_Wooden_Plank_Corner_Left_X,
          srcY: AtlasNode.Node_Wooden_Plank_Corner_Left_Y,
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
          srcY: 80 + GameConstants.Sprite_Height_Padded,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + GameConstants.Sprite_Height_Padded,
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
        throw Exception("render_node_window(${NodeOrientation.getName(renderNodeOrientation)})");
    }
  }

  void renderNodeWater() =>
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: AtlasNodeX.Water,
        srcY: AtlasNodeY.Water + (((GameAnimation.animationFrameWater + ((row + column) * 3)) % 10) * 72.0), // TODO Optimize
        srcWidth: GameConstants.Sprite_Width,
        srcHeight: GameConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + GameAnimation.animationFrameWaterHeight + 14,
        anchorY: 0.3334,
        color: renderNodeColor,
      );

  void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = currentNodeVisibility == Visibility.Opaque ? 1 : GameLighting.Transparent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameConstants.Sprite_Width_Half);
    bufferDst[f + 3] = currentNodeDstY - (GameConstants.Sprite_Height_Third);
    Engine.incrementBufferIndex();
  }

  void renderStandardNodeShaded({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = currentNodeVisibility == Visibility.Opaque ? currentNodeColor : GameLighting.Transparent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameConstants.Sprite_Width_Half);
    bufferDst[f + 3] = currentNodeDstY - (GameConstants.Sprite_Height_Third);
    Engine.incrementBufferIndex();
  }

  void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex * 4;
    bufferClr[Engine.bufferIndex] = currentNodeColor;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (GameConstants.Sprite_Height_Third) + offsetY;
    Engine.incrementBufferIndex();
  }


  void renderStandardNodeHalfEastOld({
    required double srcX,
    required double srcY,
    int color = 1,
  }){
    onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
      srcX: srcX,
      srcY: srcY,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: currentNodeDstX + 17,
      dstY: currentNodeDstY - 17,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  void renderStandardNodeHalfNorthOld({
    required double srcX,
    required double srcY,
    int color = 1,
  }){
    onscreenNodes++;
    Engine.renderSprite(
      image: atlas,
      srcX: srcX,
      srcY: srcY,
      srcWidth: GameConstants.Sprite_Width,
      srcHeight: GameConstants.Sprite_Height,
      dstX: currentNodeDstX - 17,
      dstY: currentNodeDstY - 17,
      anchorY: GameConstants.Sprite_Anchor_Y,
      color: color,
    );
  }

  int getRenderLayerColor(int layers) =>
      GameLighting.values[getRenderLayerShade(layers)];

  int getRenderLayerShade(int layers){
    final index = currentNodeIndex + (layers * GameNodes.nodesArea);
    if (index < 0) return ServerState.ambientShade.value;
    if (index >= GameNodes.nodesTotal) return ServerState.ambientShade.value;
    return GameNodes.nodesShade[index];
  }

  void showIndexPlayer() {
    if (GamePlayer.position.outOfBounds) return;
    showIndexFinal(GamePlayer.position.nodeIndex);
  }

  void showIndexMouse(){
    var x1 = GamePlayer.position.x;
    var y1 = GamePlayer.position.y;
    final z = GamePlayer.position.z + Node_Height_Half;

    if (!GameQueries.inBounds(x1, y1, z)) return;
    if (!GameQueries.inBounds(GameMouse.positionX, GameMouse.positionY, GameMouse.positionZ)) return;

    final mouseAngle = GameMouse.playerAngle;
    final mouseDistance = min(200.0, GameMouse.playerDistance);
    final jumps = mouseDistance ~/ Node_Height_Half;
    final tX = Engine.calculateAdjacent(mouseAngle, Node_Height_Half);
    final tY = Engine.calculateOpposite(mouseAngle, Node_Height_Half);
    var i1 = GamePlayer.position.nodeIndex;

    for (var i = 0; i < jumps; i++) {
      final x2 = x1 - tX;
      final y2 = y1 - tY;
      final i2 = GameQueries.getNodeIndex(x2, y2, z);
      if (!NodeType.isTransient(GameNodes.nodesType[i2])) break;
      x1 = x2;
      y1 = y2;
      i1 = i2;
    }
    showIndexFinal(i1);
  }

  void nodesHideIndex(int z, int row, int column, int initRow, int initColumn){

    var index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
    while (index < GameNodes.nodesTotal) {
      if (NodeType.isRainOrEmpty(GameNodes.nodesType[index])) {
        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }

      final distance = (z - GamePlayer.indexZ).abs();
      final transparent = distance <= 2;

      if (column >= initColumn && row >= initRow) {

        if (transparent){
          GameNodes.addTransparentIndex(index);
        } else {
          GameNodes.addInvisibleIndex(index);
        }

        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }
      var nodeIndexBelow = index - GameNodes.nodesArea;

      if (nodeIndexBelow < 0) continue;

      if (GameNodes.nodesType[nodeIndexBelow] == NodeType.Empty) {

        if (transparent){
          GameNodes.addTransparentIndex(index);
        } else {
          GameNodes.addInvisibleIndex(index);
        }

        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }

      if (GameNodes.nodesVisible[nodeIndexBelow] == Visibility.Invisible) {

        if (transparent){
          GameNodes.addTransparentIndex(index);
        } else {
          GameNodes.addInvisibleIndex(index);
        }

        row += 1;
        column += 1;
        z += 2;
        index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
        continue;
      }
      row += 1;
      column += 1;
      z += 2;
      index = (z * GameNodes.nodesArea) + (row * GameState.nodesTotalColumns) + column;
    }
  }

  void nodesRevealRaycast(int z, int row, int column){
    if (!GameQueries.isInboundZRC(z, row, column)) return;

    for (; z < GameState.nodesTotalZ; z += 2){
      row++;
      column++;
      if (row >= GameState.nodesTotalRows) return;
      if (column >= GameState.nodesTotalColumns) return;
      GameNodes.nodesVisible[GameState.getNodeIndexZRC(z, row, column)] = Visibility.Invisible;;
      if (z < GameState.nodesTotalZ - 2){
        GameNodes.nodesVisible[GameState.getNodeIndexZRC(z + 1, row, column)] = Visibility.Invisible;;
      }
    }
  }

  void nodesRevealAbove(int z, int row, int column){
    for (; z < GameState.nodesTotalZ; z++){
      GameNodes.nodesVisible[GameState.getNodeIndexZRC(z, row, column)] = Visibility.Invisible;;
    }
  }

  void showIndexFinal(int index){
    showIndex(index + GameNodes.nodesArea);
    showIndex(index + GameNodes.nodesArea + GameNodes.nodesArea);
  }

  void showIndex(int index) {
    if (index < 0) return;
    if (index >= GameNodes.nodesTotal) return;
    indexZ = GameState.convertNodeIndexToZ(index);
    indexRow = GameState.convertNodeIndexToRow(index);
    indexColumn = GameState.convertNodeIndexToColumn(index);
    const radius = 3;
    for (var r = -radius; r <= radius + 2; r++) {
      final row = indexRow + r;
      if (row < 0) continue;
      if (row >= GameState.nodesTotalRows) break;
      for (var c = -radius; c <= radius + 2; c++) {
        final column = indexColumn + c;
        if (column < 0) continue;
        if (column >= GameState.nodesTotalColumns) break;
        nodesHideIndex(indexZ, row, column, indexRow, indexColumn);
      }
    }
  }
}
