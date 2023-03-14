import 'dart:math';

import 'package:gamestream_flutter/isometric/render/highlight_character_nearest_mouse.dart';
import 'package:gamestream_flutter/library.dart';

class RendererNodes extends Renderer {

  // VARIABLES
  static var previousVisibility = 0;

  static final bufferClr = Engine.bufferClr;
  static final bufferSrc = Engine.bufferSrc;
  static final bufferDst = Engine.bufferDst;
  static final atlas_nodes = GameImages.atlas_nodes;

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
  static var playerProjection = 0;

  static var playerZ = 0;
  static var playerRow = 0;
  static var playerColumn = 0;

  static var screenTop = 0.0;
  static var screenRight = 0.0;
  static var screenBottom = 0.0;
  static var screenLeft = 0.0;

  static var nodeTypes = GameNodes.nodeTypes;
  static var nodeOrientations = GameNodes.nodeOrientations;

  static var visited2DStack = Uint16List(0);
  static var visited2DStackIndex = 0;
  static var visited2D = <bool>[];
  static var island = <bool>[];
  static var zMin = 0;
  static var playerInsideIsland = false;
  static var visible3D = <bool>[];
  static var visible3DStack = Uint16List(10000);
  static var visible3DIndex = 0;
  static var playerIndex = 0;
  static var transparencyGrid = <bool>[];
  static var transparencyGridStack = Uint16List(0);
  static var transparencyGridStackIndex = 0;

  // GETTERS
  static double get currentNodeRenderY => GameConvert.rowColumnZToRenderY(row, column, currentNodeZ);
  static int get currentNodeColor => GameNodes.node_colors[currentNodeIndex];
  static int get currentNodeOrientation => nodeOrientations[currentNodeIndex];
  static int get currentNodeWind => ServerState.windTypeAmbient.value;
  static int get currentNodeVariation => GameNodes.nodeVariations[currentNodeIndex];
  static int get renderNodeOrientation => nodeOrientations[currentNodeIndex];
  static int get renderNodeWind => ServerState.windTypeAmbient.value;
  static int get renderNodeVariation => GameNodes.nodeVariations[currentNodeIndex];
  static int get renderNodeBelowIndex => currentNodeIndex - GameNodes.area;
  static int get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? GameNodes.nodeVariations[renderNodeBelowIndex] : renderNodeVariation;
  static int get renderNodeBelowColor => getNodeColorAtIndex(currentNodeIndex - GameNodes.area);

  static int getNodeColorAtIndex(int index){
    if (index < 0) return GameNodes.ambient_color;
    if (index >= GameNodes.total) return GameNodes.ambient_color;
    return GameNodes.node_colors[index];
  }

  static var currentNodeWithinIsland = false;

  // METHODS

  @override
  void renderFunction() {
    Engine.bufferImage = atlas_nodes;
    while (
        column >= 0            &&
        row    <= nodesRowsMax &&
        currentNodeDstX   <= screenRight
    ){
      currentNodeType = nodeTypes[currentNodeIndex];
      if (currentNodeType != NodeType.Empty){

        if (!playerInsideIsland){
          renderCurrentNode();
        } else {
          currentNodeWithinIsland = island[row * GameNodes.totalColumns + column];
          if (!currentNodeWithinIsland){
            renderCurrentNode();
          } else if (currentNodeZ <= playerZ || visible3D[currentNodeIndex]) {
            renderCurrentNode();
          }
        }
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
      assert (row < GameNodes.totalRows);
      assert (column < GameNodes.totalColumns);

      trimLeft();

      while (currentNodeRenderY > screenBottom) {
        currentNodeZ++;
        if (currentNodeZ > nodesMaxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      assert (nodesStartRow < GameNodes.totalRows);
      assert (column < GameNodes.totalColumns);
      row = nodesStartRow;
      column = nodeStartColumn;
    }

    currentNodeIndex = (currentNodeZ * GameNodes.area) + (row * GameNodes.totalColumns) + column;
    assert (currentNodeZ >= 0);
    assert (row >= 0);
    assert (column >= 0);
    assert (currentNodeIndex >= 0);
    assert (currentNodeZ < GameNodes.totalZ);
    assert (row < GameNodes.totalRows);
    assert (column < GameNodes.totalColumns);
    assert (currentNodeIndex < GameNodes.total);
    currentNodeDstX = (row - column) * Node_Size_Half;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeType = GameNodes.nodeTypes[currentNodeIndex];
    order = ((row + column) * Node_Size) + Node_Size_Half;
    orderZ = currentNodeZ;
  }

  static int getIndex(int row, int column, int z){
    return (row * GameNodes.totalColumns) + column + (z * GameNodes.area);
  }

  @override
  int getTotal() => GameNodes.total;

  @override
  void reset() {
    nodeTypes = GameNodes.nodeTypes;
    nodeOrientations = GameNodes.nodeOrientations;
    nodesRowsMax = GameNodes.totalRows - 1;
    nodesGridTotalZMinusOne = GameNodes.totalZ - 1;
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
    nodesGridTotalColumnsMinusOne = GameNodes.totalColumns - 1;
    playerZ = GamePlayer.position.indexZ;
    playerRow = GamePlayer.position.indexRow;
    playerColumn = GamePlayer.position.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (GamePlayer.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (GamePlayer.position.indexZ ~/ 2);
    playerProjection = playerIndex % GameNodes.projection;
    GameNodes.offscreenNodes = 0;
    GameNodes.onscreenNodes = 0;

    screenRight = Engine.Screen_Right + Node_Size;
    screenLeft = Engine.Screen_Left - Node_Size;
    screenTop = Engine.Screen_Top - 72;
    screenBottom = Engine.Screen_Bottom + 72;
    var screenTopLeftColumn = GameConvert.convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(GameConvert.convertWorldToRow(screenRight, screenBottom, 0), 0, GameNodes.totalRows - 1);
    nodesScreenTopLeftRow = GameConvert.convertWorldToRow(screenLeft, screenTop, 0);

    if (nodesScreenTopLeftRow < 0){
      screenTopLeftColumn += nodesScreenTopLeftRow;
      nodesScreenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      nodesScreenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= GameNodes.totalColumns){
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
    currentNodeIndex = (currentNodeZ * GameNodes.area) + (row * GameNodes.totalColumns) + column;
    currentNodeType = nodeTypes[currentNodeIndex];
    currentNodeWithinIsland = false;

    updateTransparencyGrid();
    updateHeightMapPerception();

    total = getTotal();
    index = 0;
    remaining = total > 0;
    GameNodes.resetNodeColorStack();
    GameNodes.resetNodeAmbientStack();
    GameState.applyEmissions();


    highlightCharacterNearMouse();
  }

  static void updateTransparencyGrid() {

    if (transparencyGrid.length != GameNodes.projection) {
      transparencyGrid = List.generate(GameNodes.projection, (index) => false, growable: false);
      transparencyGridStack = Uint16List(GameNodes.projection);
    } else {
      for (var i = 0; i < transparencyGridStackIndex; i++){
        transparencyGrid[transparencyGridStack[i]] = false;
      }
    }
    transparencyGridStackIndex = 0;

    const r = 2;

    for (var z = playerZ; z <= playerZ + 1; z++){
      if (z >= GameNodes.totalZ) break;
      final indexZ = z * GameNodes.area;
      for (var row = playerRow - r; row <= playerRow + r; row++){
        if (row < 0) continue;
        if (row >= GameNodes.totalRows) break;
        final rowIndex = row * GameNodes.totalColumns + indexZ;
        for (var column = playerColumn - r; column <= playerColumn + r; column++){
          if (column < 0) continue;
          if (column >= GameNodes.totalColumns) break;
          final index = rowIndex + column;
          final projectionIndex = index % GameNodes.projection;
          transparencyGrid[projectionIndex] = true;
          transparencyGridStack[transparencyGridStackIndex] = projectionIndex;
          transparencyGridStackIndex++;
        }
      }
    }
  }

  static void updateHeightMapPerception() {

    if (visible3D.length != GameNodes.total) {
      visible3D = List.generate(GameNodes.total, (index) => false);
      visible3DIndex = 0;
    }

    for (var i = 0; i < visible3DIndex; i++){
      visible3D[visible3DStack[i]] = false;
    }
    visible3DIndex = 0;

    if (visited2D.length != GameNodes.area) {
      visited2D = List.generate(GameNodes.area, (index) => false, growable: false);
      visited2DStack = Uint16List(GameNodes.area);
      visited2DStackIndex = 0;
      island = List.generate(GameNodes.area, (index) => false, growable: false);
    } else {
      for (var i = 0; i < visited2DStackIndex; i++){
        final j = visited2DStack[i];
        visited2D[j] = false;
        island[j] = false;
      }
    }
    visited2DStackIndex = 0;

    final height = GameNodes.heightMap[GamePlayer.areaNodeIndex];

    if (GamePlayer.indexZ <= 0) {
      zMin = 0;
      playerInsideIsland = false;
      return;
    }

    playerInsideIsland = GamePlayer.indexZ < height;

    if (!playerInsideIsland) {
      for (var z = GamePlayer.indexZ; z <= GamePlayer.indexZ + 1; z++) {

        var projectionRow = GamePlayer.indexRow;
        var projectionColumn = GamePlayer.indexColumn;
        var projectionZ = z;

        while (true) {
          projectionZ += 2;
          projectionColumn++;
          projectionRow++;
          if (projectionZ >= GameNodes.totalZ) return;
          if (projectionColumn >= GameNodes.totalColumns) return;
          if (projectionRow >= GameNodes.totalRows) return;
          final projectionIndex = (projectionRow * GameNodes.totalColumns) + projectionColumn;
          final projectionHeight = GameNodes.heightMap[projectionIndex];
          if (projectionZ > projectionHeight) continue;
          playerInsideIsland = true;
          zMin = max(GamePlayer.indexZ - 1, 0);
          visit2D(projectionIndex);
          return;
        }
      }
    }
    zMin = max(GamePlayer.indexZ - 1, 0);
    visit2D(GamePlayer.areaNodeIndex);
  }

  static void addVisible3D(int i){
    visible3D[i] = true;
    visible3DStack[visible3DIndex] = i;
    visible3DIndex++;
  }

  static void visit2D(int i) {
     if (visited2D[i]) return;
     visited2D[i] = true;
     visited2DStack[visited2DStackIndex] = i;
     visited2DStackIndex++;
     if (GameNodes.heightMap[i] <= zMin) return;
     island[i] = true;

     var searchIndex = i + (GameNodes.area * GamePlayer.indexZ);
     addVisible3D(searchIndex);

     var spaceReached = GameNodes.nodeOrientations[searchIndex] == NodeOrientation.None;
     var gapReached = false;

     while (true) {
       searchIndex += GameNodes.area;
        if (searchIndex >= GameNodes.total) break;
        final nodeOrientation = GameNodes.nodeOrientations[searchIndex];
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
          NodeOrientation.isSlopeSymmetric(nodeOrientation) ||
          NodeOrientation.isSlopeCornerInner(nodeOrientation) ||
          NodeOrientation.isSlopeCornerOuter(nodeOrientation)
        ) break;

        addVisible3D(searchIndex);
     }
     searchIndex = i + (GameNodes.area * GamePlayer.indexZ);
     while (true) {
       addVisible3D(searchIndex);
       if (blocksBeamVertical(searchIndex)) break;
       searchIndex -= GameNodes.area;
       if (searchIndex < 0) break;
     }

     final iAbove = i - GameNodes.totalColumns;
     if (iAbove > 0) {
       visit2D(iAbove);
     }
     final iBelow = i + GameNodes.totalColumns;
     if (iBelow < GameNodes.area) {
       visit2D(iBelow);
     }

     final row = i % GameNodes.totalRows;
     if (row - 1 >= 0) {
       visit2D(i - 1);
     }
     if (row + 1 < GameNodes.totalRows){
       visit2D(i + 1);
     }
  }

  static int getProjectionIndex(int index){
    return index % GameNodes.projection;
  }

  static bool nodeTypeBlocks(int nodeType){
    if (nodeType == NodeType.Window) return false;
    if (nodeType == NodeType.Shopping_Shelf) return false;
    if (nodeType == NodeType.Wooden_Plank) return false;
    if (nodeType == NodeType.Boulder) return false;
    return true;
  }

  static bool blocksBeamHorizontal(int index, int dirRow, int dirColumn){
    assert (dirRow == 0 || dirColumn == 0);
    final nodeOrientation = GameNodes.nodeOrientations[index];
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

    final nodeType = GameNodes.nodeTypes[index];
    if (nodeType == NodeType.Window) return false;
    if (nodeType == NodeType.Shopping_Shelf) return false;
    if (nodeType == NodeType.Wooden_Plank) return false;
    if (nodeType == NodeType.Boulder) return false;

    return true;
  }

  static bool blocksBeamVertical(int index){
    final nodeOrientation = GameNodes.nodeOrientations[index];
    if (nodeOrientation == NodeOrientation.None) return false;
    if (NodeOrientation.isHalf(nodeOrientation)) return false;
    if (NodeOrientation.isRadial(nodeOrientation)) return false;
    if (NodeOrientation.isColumn(nodeOrientation)) return false;
    if (NodeOrientation.isCorner(nodeOrientation)) return false;
    return true;
  }

  static void trimLeft(){
    var currentNodeRenderX = (row - column) * Node_Size_Half;
    final maxRow = GameNodes.totalRows - 1;
    while (currentNodeRenderX < screenLeft && column > 0 && row < maxRow){
      row++;
      column--;
      currentNodeRenderX += Node_Size;
    }
    nodesSetStart();
  }

  static void nodesSetStart(){
    nodesStartRow = clamp(row, 0, GameNodes.totalRows - 1);
    nodeStartColumn = clamp(column, 0, GameNodes.totalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < GameNodes.totalRows);
    assert (nodeStartColumn < GameNodes.totalColumns);
  }

  static void nodesShiftIndexDown(){

    column = row + column + 1;
    row = 0;
    if (column < GameNodes.totalColumns) {
      nodesSetStart();
      return;
    }

    if (column - nodesGridTotalColumnsMinusOne >= GameNodes.totalRows){
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
      if (nodesMinZ >= GameNodes.totalZ){
        GameRender.rendererNodes.remaining = false;
        return;
      }
    }
  }



  static void nodesTrimTop() {
    // TODO optimize
    while (currentNodeRenderY < screenTop){
      nodesShiftIndexDown();
    }
    nodesCalculateMinMaxZ();
    nodesSetStart();
  }

  static void renderNodeTorch(){
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
    if (!ClientState.debugMode.value) return true;
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

  static bool get currentNodeTransparent {
    // if (currentNodeWithinIsland) {
    //   if (currentNodeZ >= playerZ + 2) {
    //     return true;
    //   }
    // }
    if (currentNodeZ <= playerZ) return false;
    final currentNodeProjection = currentNodeIndex % GameNodes.projection;
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

  static void renderCurrentNode() {

    if (currentNodeWithinIsland && currentNodeZ >= playerZ + 2) return;

    Engine.bufferImage = currentNodeTransparent ? GameImages.atlas_nodes_transparent : GameImages.atlas_nodes;


    switch (currentNodeType) {
      case NodeType.Grass:
        renderNodeGrass();
        break;
      case NodeType.Brick:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_2);
        return;
      case NodeType.Bricks_Red:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_13);
        return;
      case NodeType.Bricks_Brown:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_14);
        return;
      case NodeType.Wood:
        const index_grass = 5;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
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
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_8);
        return;
      case NodeType.Metal:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_4);
        return;
      case NodeType.Road:
        renderNodeTemplateShadedOffset(GameConstants.Sprite_Width_Padded_9, offsetY: 7);
        return;
      case NodeType.Tree_Bottom:
        renderTreeBottom();
        break;
      case NodeType.Tree_Top:
        renderTreeTop();
        break;
      case NodeType.Scaffold:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_15);
        break;
      case NodeType.Road_2:
        renderNodeShadedOffset(srcX: 1490, srcY: 305, offsetX: 0, offsetY: 7);
        return;
      case NodeType.Wooden_Plank:
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_10);
        return;
      case NodeType.Torch:
        renderNodeTorch();
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
        renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_16);
        return;
      case NodeType.Bau_Haus:
        const index_grass = 6;
        const srcX = GameConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        break;
      case NodeType.Sunflower:
        if (currentNodeOrientation == NodeOrientation.Destroyed) return;
        renderStandardNode(
          srcX: 1753.0,
          srcY: 867.0,
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
        renderStandardNode(
          srcX: AtlasNodeX.Boulder,
          srcY: AtlasNodeY.Boulder,
        );
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
      case NodeType.Respawning:
        return;
      default:
        throw Exception('renderNode(index: ${currentNodeIndex}, type: ${NodeType.getName(currentNodeType)}, orientation: ${NodeOrientation.getName(nodeOrientations[currentNodeIndex])}');
    }
  }

  static void renderNodeShoppingShelf() {
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

  static void renderNodeBookShelf() {
    renderStandardNode(
      srcX: 1392,
      srcY: 233,
    );
  }

  static void renderNodeGrass() {
    if (currentNodeOrientation == NodeOrientation.Solid){
      final variation = currentNodeVariation;
      if (variation == 0) {
        renderStandardNode(
          srcX: 147,
          srcY: 0,
        );
        return;
      }
      if (variation == 1) {
        renderStandardNode(
          srcX: 1168,
          srcY: 0,
        );
        return;
      }
      if (variation == 2) {
        renderStandardNode(
          srcX: 1119,
          srcY: 0,
        );
        return;
      }
      if (variation == 3) {
        renderStandardNode(
          srcX: 1070,
          srcY: 0,
        );
        return;
      }
    }
    renderNodeTemplateShaded(GameConstants.Sprite_Width_Padded_3);
  }

  static void renderNodeGrassLong() {
    if (currentNodeOrientation == NodeOrientation.Destroyed) return;
    switch (currentNodeWind) {
      case WindType.Calm:
        renderStandardNode(
          srcX: AtlasNodeX.Grass_Long,
          srcY: 0,
        );
        return;
      default:
        renderStandardNode(
          srcX: AtlasNodeX.Grass_Long + ((((row - column) + GameAnimation.animationFrameGrass) % 6) * 48), // TODO Expensive Operation
          srcY: 0,
        );
        return;
    }
  }

  static void renderNodeRainLanding() {
    if (currentNodeIndex > GameNodes.area && nodeTypes[currentNodeIndex - GameNodes.area] == NodeType.Water){
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
    renderStandardNode(
      srcX: ClientState.srcXRainLanding,
      srcY: 72.0 * ((GameAnimation.animationFrame + row + column) % 6), // TODO Expensive Operation
    );
  }

  static void renderNodeRainFalling() {
    renderStandardNode(
      srcX: ClientState.srcXRainFalling,
      srcY: 72.0 * ((GameAnimation.animationFrame + row + row + column) % 6), // TODO Expensive Operation
    );
  }

  static void renderTreeTop() => renderNodeBelowVariation == 0 ? renderTreeTopPine() : renderTreeTopOak();

  static void renderTreeBottom() => renderNodeVariation == 0 ? renderTreeBottomPine() : renderTreeBottomOak();

  static void renderTreeTopOak(){
    var shift = GameAnimation.treeAnimation[((row - column) + GameAnimation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.Tree_Top,
      srcY: 433.0,
      srcWidth: AtlasNode.Node_Tree_Top_Width,
      srcHeight: AtlasNode.Node_Tree_Top_Height,
      dstX: currentNodeDstX + (shift * 0.5),
      dstY: currentNodeDstY,
      // color: getNodeColorAtIndex(currentNodeIndex - (GameNodes.area + GameNodes.area)),
      // color: getNodeColorAtIndex(currentNodeIndex),
      color: renderNodeBelowColor,
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
      // color: getNodeColorAtIndex(currentNodeIndex - (GameNodes.area + GameNodes.area)),
      // color: getNodeColorAtIndex(currentNodeIndex),
      color: renderNodeBelowColor,
    );
  }

  static void renderTreeBottomOak() {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: AtlasNodeX.Tree_Bottom,
      srcY: 433.0,
      srcWidth: AtlasNode.Width_Tree_Bottom,
      srcHeight: AtlasNode.Node_Tree_Bottom_Height,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      // color: renderNodeBelowColor,
      color: getNodeColorAtIndex(currentNodeIndex),
    );
  }

  static void renderTreeBottomPine() {
    Engine.renderSprite(
      image: GameImages.atlas_nodes,
      srcX: 1216,
      srcY: 80,
      srcWidth: 45,
      srcHeight: 72,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      // color: renderNodeBelowColor,
      color: getNodeColorAtIndex(currentNodeIndex),
      anchorY: 0.5,
    );
  }

  static void renderNodeTemplateShadedOffset(double srcX, {double offsetX = 0, double offsetY = 0}) {
    switch (currentNodeOrientation){
      case NodeOrientation.Solid:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_00,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;

      case NodeOrientation.Corner_Top:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
        );

        return;
      case NodeOrientation.Corner_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Slope_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_03,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_04,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_05,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_06,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_07,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_08,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_09,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_10,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_11,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_12,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_13,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_14,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Radial:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_15,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -9 + offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -1 + offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: 2 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: -16 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: -16 + offsetX,
          offsetY: 0 + offsetY,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 0 + offsetY,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 16 + offsetY,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 16 + offsetX,
          offsetY: 0 + offsetY,
        );
        return;
    }
  }

  static void renderNodeTemplateShaded(double srcX) {
    switch (currentNodeOrientation){
      case NodeOrientation.Solid:
        renderStandardNode(
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
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16,
          offsetY: -8,
          srcWidth: 32,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
          srcWidth: 32,
        );
        return;
      case NodeOrientation.Corner_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Slope_North:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_03,
        );
        return;
      case NodeOrientation.Slope_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_04,
        );
        return;
      case NodeOrientation.Slope_South:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_05,
        );
        return;
      case NodeOrientation.Slope_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_06,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_07,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_08,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_09,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_10,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_11,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_12,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_13,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_14,
        );
        return;
      case NodeOrientation.Radial:
        renderStandardNode(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_15,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: -8,
          color: GameNodes.node_colors[currentNodeIndex + GameNodes.area < GameNodes.total ? currentNodeIndex + GameNodes.area : currentNodeIndex],
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: -16,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: -16,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: -8,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 0,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: 8,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 16,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameConstants.Sprite_Height_Padded_17,
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

  static void renderNodeDust() =>
      Engine.renderSprite(
        image: GameImages.atlas_nodes,
        srcX: 1552,
        srcY: 432 + (GameAnimation.animationFrame6 * 72.0), // TODO Optimize
        srcWidth: GameConstants.Sprite_Width,
        srcHeight: GameConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: 0.3334,
        color: currentNodeColor,
      );

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
        color: currentNodeColor,
      );

  static void renderStandardNode({
    required double srcX,
    required double srcY,
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

  static void renderNodeShadedCustom({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
    int? color,
    double? srcWidth,
    double? srcHeight
  }){
    onscreenNodes++;
    final f = Engine.bufferIndex << 2;
    bufferClr[Engine.bufferIndex] = color ?? currentNodeColor;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + (srcWidth ?? GameConstants.Sprite_Width);
    bufferSrc[f + 3] = srcY + (srcHeight ?? GameConstants.Sprite_Height);
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (GameConstants.Sprite_Height_Third) + offsetY;
    Engine.incrementBufferIndex();
  }
}
