import 'dart:math';

import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/library.dart';

class RendererNodes extends Renderer {

  // VARIABLES
  static var previousVisibility = 0;

  static final bufferClr = Engine.bufferClr;
  static final bufferSrc = Engine.bufferSrc;
  static final bufferDst = Engine.bufferDst;
  static final atlas = GameImages.atlas_nodes;

  static var playerRenderRow = 0;
  static var playerRenderColumn = 0;

  static var indexShow = 0;
  static var indexRow = 0;
  static var indexColumn = 0;
  static var indexZ = 0;
  static var nodesStartRow = 0;
  static var nodeStartColumn = 0;
  static var nodesMaxZ = 0;
  static var nodesMinZ = 0;
  static var currentNodeZ = 0;
  static var row = 0;
  static var column = 0;
  static var currentNodeDstX = 0.0;
  static var currentNodeDstY = 0.0;
  static var currentNodeIndex = 0;
  static var currentNodeType = 0;

  static var offscreenNodesTop = 0;
  static var offscreenNodesRight = 0;
  static var offscreenNodesBottom = 0;
  static var offscreenNodesLeft = 0;

  static var onscreenNodes = 0;
  static var offscreenNodes = 0;

  static var nodesRowsMax = 0;
  static var nodesShiftIndex = 0;
  static var nodesScreenTopLeftRow = 0;
  static var nodesScreenBottomRightRow = 0;
  static var nodesGridTotalColumnsMinusOne = 0;
  static var nodesGridTotalZMinusOne = 0;
  static var nodesPlayerColumnRow = 0;
  static var nodesPlayerUnderRoof = false;

  static var playerZ = 0;
  static var playerRow = 0;
  static var playerColumn = 0;

  static var screenTop = 0.0;
  static var screenRight = 0.0;
  static var screenBottom = 0.0;
  static var screenLeft = 0.0;

  static var nodeTypes = GameNodes.nodesType;

  // GETTERS

  // double get currentNodeRenderX => (currentNodeRow - currentNodeColumn) * Node_Size_Half;
  static double get currentNodeRenderY => GameConvert.rowColumnZToRenderY(row, column, currentNodeZ);

  static int get currentNodeShade => GameNodes.nodesShade[currentNodeIndex];
  static int get currentNodeColor => (currentNodeVisibilityOpaque ? GameLighting.values : GameLighting.values_transparent)[currentNodeShade];
  static int get currentNodeOrientation => GameNodes.nodesOrientation[currentNodeIndex];
  static int get currentNodeVisibility => GameNodes.nodesVisible[currentNodeIndex];
  // int get currentNodeWind => GameNodes.nodesWind[currentNodeIndex];
  static int get currentNodeWind => ServerState.windTypeAmbient.value;

  static bool get currentNodeVisible => currentNodeVisibility == Visibility.Invisible;
  static bool get currentNodeInvisible => currentNodeVisibility == Visibility.Invisible;
  static bool get currentNodeVisibilityOpaque => GameNodes.nodesVisible[currentNodeIndex] == Visibility.Opaque;
  static bool get currentNodeVariation => GameNodes.nodesVariation[currentNodeIndex];

  static int get renderNodeShade => GameNodes.nodesShade[currentNodeIndex];
  static int get renderNodeOrientation => GameNodes.nodesOrientation[currentNodeIndex];
  static int get renderNodeColor => GameLighting.values[renderNodeShade];
  // int get renderNodeWind => GameNodes.nodesWind[renderNodeShade];
  static int get renderNodeWind => ServerState.windTypeAmbient.value;
  static bool get renderNodeVariation => GameNodes.nodesVariation[currentNodeIndex];

  static int get renderNodeBelowIndex => currentNodeIndex - GameNodes.nodesArea;
  static bool get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? GameNodes.nodesVariation[renderNodeBelowIndex] : renderNodeVariation;

  static int get renderNodeBelowShade {
    if (renderNodeBelowIndex < 0) return Shade.Medium;
    if (renderNodeBelowIndex >= GameNodes.nodesTotal) return Shade.Medium;
    return GameNodes.nodesShade[renderNodeBelowIndex];
  }

  static int get renderNodeBelowColor => GameLighting.values[renderNodeBelowShade];

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

  static void nodesSetStart(){
    // nodesStartRow = min(currentNodeRow, GameState.nodesTotalRows);
    nodesStartRow = clamp(row, 0, GameState.nodesTotalRows - 1);
    nodeStartColumn = clamp(column, 0, GameState.nodesTotalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < GameState.nodesTotalRows);
    assert (nodeStartColumn < GameState.nodesTotalColumns);
  }

  static void nodesShiftIndexDown(){

    column = row + column + 1;
    row = 0;
    if (column < GameState.nodesTotalColumns) {
      nodesSetStart();
      return;
    }

    if (column - nodesGridTotalColumnsMinusOne >= GameState.nodesTotalRows){
      GameRender.rendererNodes.remaining = false;
      return;
    }

    row = column - nodesGridTotalColumnsMinusOne;
    column = nodesGridTotalColumnsMinusOne;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    nodesSetStart();
  }

  static void nodesCalculateMinMaxZ(){
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
        GameRender.rendererNodes.remaining = false;
        return;
      }
    }
  }



  void nodesTrimTop() {
    // TODO optimize
    while (currentNodeRenderY < screenTop){
      nodesShiftIndexDown();
    }
    nodesCalculateMinMaxZ();
    nodesSetStart();
  }

  static void renderNodeTorch(){
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

  static bool assertOnScreen(){
    if (!ClientState.debugVisible.value) return true;
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

  static void renderCurrentNode() {
    // assert (currentNodeDstX > screenLeft);
    // assert (currentNodeDstX < screenRight);
    // assert (currentNodeDstY > screenTop);
    // assert (currentNodeDstY < screenBottom);
    // assert (currentNodeDstX > screenLeft);

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
        renderNodeRainFalling();
        return;
      case NodeType.Rain_Landing:
        renderNodeRainLanding();
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
        // renderNodeWoodenPlank();
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_10);
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

  static void renderNodeRainLanding() {
    if (currentNodeIndex > GameNodes.nodesArea && nodeTypes[currentNodeIndex - GameNodes.nodesArea] == NodeType.Water){
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: AtlasNode.Node_Rain_Landing_Water_X,
        srcY: 72.0 * ((GameAnimation.animationFrame + row + column) % 8), // TODO Expensive Operation
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
  }

  static void renderNodeRainFalling() {
    renderStandardNodeShaded(
      srcX: ClientState.srcXRainFalling,
      srcY: 72.0 * ((GameAnimation.animationFrame + row + row + column) % 6), // TODO Expensive Operation
    );
  }

  static void renderTreeTop() => renderNodeBelowVariation ? renderTreeTopPine() : renderTreeTopOak();

  static void renderTreeBottom() => renderNodeVariation ? renderTreeBottomPine() : renderTreeBottomOak();

  static void renderTreeTopOak(){
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

  static void renderTreeTopPine() {
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

  static void renderTreeBottomOak() {
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

  static void renderTreeBottomPine() {
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

  static void renderNodeTemplateShaded(double srcX) {
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

  static void renderNodeWindow(){
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

  static void renderNodeWater() =>
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

  static void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex << 2;
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

  static void renderStandardNodeShaded({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex << 2;
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

  static void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex << 2;
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

  static int getRenderLayerColor(int layers) =>
      GameLighting.values[getRenderLayerShade(layers)];

  static int getRenderLayerShade(int layers){
    final index = currentNodeIndex + (layers * GameNodes.nodesArea);
    if (index < 0) return Shade.Medium;
    if (index >= GameNodes.nodesTotal) return Shade.Medium;
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
