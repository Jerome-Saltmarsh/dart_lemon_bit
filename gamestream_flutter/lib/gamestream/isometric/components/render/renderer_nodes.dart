import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/ui/game_isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_mouse.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/library.dart';

class RendererNodes extends IsometricRenderer {

  // VARIABLES
  var previousVisibility = 0;

  final bufferClr = engine.bufferClr;
  final bufferSrc = engine.bufferSrc;
  final bufferDst = engine.bufferDst;
  final atlas_nodes = Images.atlas_nodes;

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
  var playerProjection = 0;

  var playerZ = 0;
  var playerRow = 0;
  var playerColumn = 0;

  var screenTop = 0.0;
  var screenRight = 0.0;
  var screenBottom = 0.0;
  var screenLeft = 0.0;

  var nodeTypes = gamestream.isometric.scene.nodeTypes;
  var nodeOrientations = gamestream.isometric.scene.nodeOrientations;

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

  RendererNodes(super.scene);

  // GETTERS
  double get currentNodeRenderY => IsometricRender.rowColumnZToRenderY(row, column, currentNodeZ);
  int get currentNodeColor => gamestream.isometric.scene.nodeColors[currentNodeIndex];
  int get currentNodeOrientation => nodeOrientations[currentNodeIndex];
  int get currentNodeWind => gamestream.isometric.server.windTypeAmbient.value;
  int get currentNodeVariation => gamestream.isometric.scene.nodeVariations[currentNodeIndex];
  int get renderNodeOrientation => nodeOrientations[currentNodeIndex];
  int get renderNodeWind => gamestream.isometric.server.windTypeAmbient.value;
  int get renderNodeVariation => gamestream.isometric.scene.nodeVariations[currentNodeIndex];
  int get renderNodeBelowIndex => currentNodeIndex - gamestream.isometric.scene.area;
  int get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? gamestream.isometric.scene.nodeVariations[renderNodeBelowIndex] : renderNodeVariation;
  int get renderNodeBelowColor => getNodeColorAtIndex(currentNodeIndex - gamestream.isometric.scene.area);

  int getNodeColorAtIndex(int index){
    if (index < 0) return gamestream.isometric.scene.ambientColor;
    if (index >= gamestream.isometric.scene.total) return gamestream.isometric.scene.ambientColor;
    return gamestream.isometric.scene.nodeColors[index];
  }

  var currentNodeWithinIsland = false;

  // METHODS

  @override
  void renderFunction() {
    engine.bufferImage = atlas_nodes;
    while (
        column >= 0            &&
        row    <= nodesRowsMax &&
        currentNodeDstX   <= screenRight
    ){
      currentNodeType = nodeTypes[currentNodeIndex];
      if (currentNodeType != NodeType.Empty){

        if (!gamestream.isometric.player.playerInsideIsland){
          renderCurrentNode();
        } else {
          currentNodeWithinIsland = island[row * gamestream.isometric.scene.totalColumns + column];
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
      orderZ = currentNodeZ;
      currentNodeIndex += nodesGridTotalColumnsMinusOne;
      currentNodeDstX += GameIsometricConstants.Sprite_Width;
    }
  }

  @override
  void updateFunction() {
    final nodes = gamestream.isometric.scene;
    currentNodeZ++;
    if (currentNodeZ > nodesMaxZ) {
      currentNodeZ = 0;
      nodesShiftIndexDown();
      if (!remaining) return;
      nodesCalculateMinMaxZ();
      if (!remaining) return;

      assert (column >= 0);
      assert (row >= 0);
      assert (row < nodes.totalRows);
      assert (column < nodes.totalColumns);

      trimLeft();

      while (currentNodeRenderY > screenBottom) {
        currentNodeZ++;
        if (currentNodeZ > nodesMaxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      assert (nodesStartRow < nodes.totalRows);
      assert (column < nodes.totalColumns);
      row = nodesStartRow;
      column = nodeStartColumn;
    }

    currentNodeIndex = (currentNodeZ * nodes.area) + (row * nodes.totalColumns) + column;
    assert (currentNodeZ >= 0);
    assert (row >= 0);
    assert (column >= 0);
    assert (currentNodeIndex >= 0);
    assert (currentNodeZ < nodes.totalZ);
    assert (row < nodes.totalRows);
    assert (column < nodes.totalColumns);
    assert (currentNodeIndex < nodes.total);
    currentNodeDstX = (row - column) * Node_Size_Half;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeType = nodes.nodeTypes[currentNodeIndex];
    orderZ = currentNodeZ;
    orderRowColumn = (row + column).toDouble() - 0.5;
  }

  int getIndex(int row, int column, int z){
    return (row * gamestream.isometric.scene.totalColumns) + column + (z * gamestream.isometric.scene.area);
  }

  @override
  int getTotal() => gamestream.isometric.scene.total;

  @override
  void reset() {
    nodeTypes = gamestream.isometric.scene.nodeTypes;
    nodeOrientations = gamestream.isometric.scene.nodeOrientations;
    nodesRowsMax = gamestream.isometric.scene.totalRows - 1;
    nodesGridTotalZMinusOne = gamestream.isometric.scene.totalZ - 1;
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    offscreenNodes = 0;
    onscreenNodes = 0;
    nodesMinZ = 0;
    orderZ = 0;
    currentNodeZ = 0;
    nodesGridTotalColumnsMinusOne = gamestream.isometric.scene.totalColumns - 1;
    playerZ = gamestream.isometric.player.position.indexZ;
    playerRow = gamestream.isometric.player.position.indexRow;
    playerColumn = gamestream.isometric.player.position.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (gamestream.isometric.player.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (gamestream.isometric.player.position.indexZ ~/ 2);
    playerProjection = playerIndex % gamestream.isometric.scene.projection;
    gamestream.isometric.scene.offscreenNodes = 0;
    gamestream.isometric.scene.onscreenNodes = 0;

    screenRight = engine.Screen_Right + Node_Size;
    screenLeft = engine.Screen_Left - Node_Size;
    screenTop = engine.Screen_Top - 72;
    screenBottom = engine.Screen_Bottom + 72;
    var screenTopLeftColumn = IsometricRender.convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(IsometricRender.convertWorldToRow(screenRight, screenBottom, 0), 0, gamestream.isometric.scene.totalRows - 1);
    nodesScreenTopLeftRow = IsometricRender.convertWorldToRow(screenLeft, screenTop, 0);

    if (nodesScreenTopLeftRow < 0){
      screenTopLeftColumn += nodesScreenTopLeftRow;
      nodesScreenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      nodesScreenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= gamestream.isometric.scene.totalColumns){
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
    currentNodeIndex = (currentNodeZ * gamestream.isometric.scene.area) + (row * gamestream.isometric.scene.totalColumns) + column;
    currentNodeType = nodeTypes[currentNodeIndex];
    currentNodeWithinIsland = false;

    updateTransparencyGrid();
    updateHeightMapPerception();

    total = getTotal();
    index = 0;
    remaining = total > 0;
    gamestream.isometric.scene.resetNodeColorStack();
    gamestream.isometric.scene.resetNodeAmbientStack();
    gamestream.isometric.client.applyEmissions();

    // highlightCharacterNearMouse();
  }

  void updateTransparencyGrid() {

    if (transparencyGrid.length != gamestream.isometric.scene.projection) {
      transparencyGrid = List.generate(gamestream.isometric.scene.projection, (index) => false, growable: false);
      transparencyGridStack = Uint16List(gamestream.isometric.scene.projection);
    } else {
      for (var i = 0; i < transparencyGridStackIndex; i++){
        transparencyGrid[transparencyGridStack[i]] = false;
      }
    }
    transparencyGridStackIndex = 0;

    const r = 2;

    final nodes = gamestream.isometric.scene;
    for (var z = playerZ; z <= playerZ + 1; z++){
      if (z >= nodes.totalZ) break;
      final indexZ = z * nodes.area;
      for (var row = playerRow - r; row <= playerRow + r; row++){
        if (row < 0) continue;
        if (row >= nodes.totalRows) break;
        final rowIndex = row * nodes.totalColumns + indexZ;
        for (var column = playerColumn - r; column <= playerColumn + r; column++){
          if (column < 0) continue;
          if (column >= nodes.totalColumns) break;
          final index = rowIndex + column;
          final projectionIndex = index % nodes.projection;
          transparencyGrid[projectionIndex] = true;
          transparencyGridStack[transparencyGridStackIndex] = projectionIndex;
          transparencyGridStackIndex++;
        }
      }
    }
  }

  void updateHeightMapPerception() {

    if (visible3D.length != gamestream.isometric.scene.total) {
      visible3D = List.generate(gamestream.isometric.scene.total, (index) => false);
      visible3DIndex = 0;
    }

    for (var i = 0; i < visible3DIndex; i++){
      visible3D[visible3DStack[i]] = false;
    }
    visible3DIndex = 0;

    if (visited2D.length != gamestream.isometric.scene.area) {
      visited2D = List.generate(gamestream.isometric.scene.area, (index) => false, growable: false);
      visited2DStack = Uint16List(gamestream.isometric.scene.area);
      visited2DStackIndex = 0;
      island = List.generate(gamestream.isometric.scene.area, (index) => false, growable: false);
    } else {
      for (var i = 0; i < visited2DStackIndex; i++){
        final j = visited2DStack[i];
        visited2D[j] = false;
        island[j] = false;
      }
    }
    visited2DStackIndex = 0;

    final height = gamestream.isometric.scene.heightMap[gamestream.isometric.player.areaNodeIndex];

    if (gamestream.isometric.player.indexZ <= 0) {
      zMin = 0;
      gamestream.isometric.player.playerInsideIsland = false;
      return;
    }

    gamestream.isometric.player.playerInsideIsland = gamestream.isometric.player.indexZ < height;

    if (!gamestream.isometric.player.playerInsideIsland) {
      ensureIndexPerceptible(gamestream.isometric.player.nodeIndex);
    }

    if (IsometricMouse.inBounds){
      ensureIndexPerceptible(IsometricMouse.nodeIndex);
    }

    zMin = max(gamestream.isometric.player.indexZ - 1, 0);
    visit2D(gamestream.isometric.player.areaNodeIndex);
  }

  void ensureIndexPerceptible(int index){
    var projectionRow     = gamestream.isometric.scene.getIndexRow(index);
    var projectionColumn  = gamestream.isometric.scene.getIndexColumn(index);
    var projectionZ       = gamestream.isometric.scene.getIndexZ(index);

    while (true) {
      projectionZ += 2;
      projectionColumn++;
      projectionRow++;
      if (projectionZ >= gamestream.isometric.scene.totalZ) return;
      if (projectionColumn >= gamestream.isometric.scene.totalColumns) return;
      if (projectionRow >= gamestream.isometric.scene.totalRows) return;
      final projectionIndex =
          (projectionRow * gamestream.isometric.scene.totalColumns) + projectionColumn;
      final projectionHeight = gamestream.isometric.scene.heightMap[projectionIndex];
      if (projectionZ > projectionHeight) continue;
      gamestream.isometric.player.playerInsideIsland = true;
      zMin = max(gamestream.isometric.player.indexZ - 1, 0);
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
     if (gamestream.isometric.scene.heightMap[i] <= zMin) return;
     island[i] = true;

     var searchIndex = i + (gamestream.isometric.scene.area * gamestream.isometric.player.indexZ);
     addVisible3D(searchIndex);

     var spaceReached = gamestream.isometric.scene.nodeOrientations[searchIndex] == NodeOrientation.None;
     var gapReached = false;

     while (true) {
       searchIndex += gamestream.isometric.scene.area;
        if (searchIndex >= gamestream.isometric.scene.total) break;
        final nodeOrientation = gamestream.isometric.scene.nodeOrientations[searchIndex];
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
     searchIndex = i + (gamestream.isometric.scene.area * gamestream.isometric.player.indexZ);
     while (true) {
       addVisible3D(searchIndex);
       if (blocksBeamVertical(searchIndex)) break;
       searchIndex -= gamestream.isometric.scene.area;
       if (searchIndex < 0) break;
     }

     final iAbove = i - gamestream.isometric.scene.totalColumns;
     if (iAbove > 0) {
       visit2D(iAbove);
     }
     final iBelow = i + gamestream.isometric.scene.totalColumns;
     if (iBelow < gamestream.isometric.scene.area) {
       visit2D(iBelow);
     }

     final row = i % gamestream.isometric.scene.totalRows;
     if (row - 1 >= 0) {
       visit2D(i - 1);
     }
     if (row + 1 < gamestream.isometric.scene.totalRows){
       visit2D(i + 1);
     }
  }

  int getProjectionIndex(int index){
    return index % gamestream.isometric.scene.projection;
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
    final nodeOrientation = gamestream.isometric.scene.nodeOrientations[index];
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

    final nodeType = gamestream.isometric.scene.nodeTypes[index];
    if (nodeType == NodeType.Window) return false;
    if (nodeType == NodeType.Shopping_Shelf) return false;
    if (nodeType == NodeType.Wooden_Plank) return false;
    if (nodeType == NodeType.Boulder) return false;

    return true;
  }

  bool blocksBeamVertical(int index){
    final nodeOrientation = gamestream.isometric.scene.nodeOrientations[index];
    if (nodeOrientation == NodeOrientation.None) return false;
    if (NodeOrientation.isHalf(nodeOrientation)) return false;
    if (NodeOrientation.isRadial(nodeOrientation)) return false;
    if (NodeOrientation.isColumn(nodeOrientation)) return false;
    if (NodeOrientation.isCorner(nodeOrientation)) return false;
    return true;
  }

  void trimLeft(){
    var currentNodeRenderX = (row - column) * Node_Size_Half;
    final maxRow = gamestream.isometric.scene.totalRows - 1;
    while (currentNodeRenderX < screenLeft && column > 0 && row < maxRow){
      row++;
      column--;
      currentNodeRenderX += Node_Size;
    }
    nodesSetStart();
  }

  void nodesSetStart(){
    nodesStartRow = clamp(row, 0, gamestream.isometric.scene.totalRows - 1);
    nodeStartColumn = clamp(column, 0, gamestream.isometric.scene.totalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < gamestream.isometric.scene.totalRows);
    assert (nodeStartColumn < gamestream.isometric.scene.totalColumns);
  }

  void nodesShiftIndexDown(){

    column = row + column + 1;
    row = 0;
    if (column < gamestream.isometric.scene.totalColumns) {
      nodesSetStart();
      return;
    }

    if (column - nodesGridTotalColumnsMinusOne >= gamestream.isometric.scene.totalRows){
      gamestream.isometric.renderer.rendererNodes.remaining = false;
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
      if (nodesMinZ >= gamestream.isometric.scene.totalZ){
        gamestream.isometric.renderer.rendererNodes.remaining = false;
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

  void renderNodeTorch(){
    if (renderNodeWind == WindType.Calm){
      engine.renderSprite(
        image: Images.atlas_nodes,
        srcX: AtlasNodeX.Torch,
        srcY: AtlasNodeY.Torch + AtlasNode.Height_Torch + (((row + (gamestream.animation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
        srcWidth: AtlasNode.Width_Torch,
        srcHeight: AtlasNode.Height_Torch,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: AtlasNodeAnchorY.Torch,
        color: currentNodeColor,
      );
      return;
    }
    engine.renderSprite(
      image: Images.atlas_nodes,
      srcX: AtlasNode.X_Torch_Windy,
      srcY: AtlasNode.Y_Torch_Windy + AtlasNode.Height_Torch + (((row + (gamestream.animation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
      color: currentNodeColor,
    );
    return;
  }

  bool assertOnScreen(){
    if (!gamestream.isometric.client.debugMode.value) return true;
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
    // if (currentNodeWithinIsland) {
    //   if (currentNodeZ >= playerZ + 2) {
    //     return true;
    //   }
    // }
    if (currentNodeZ <= playerZ) return false;
    final currentNodeProjection = currentNodeIndex % gamestream.isometric.scene.projection;
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

  void renderCurrentNode() {

    if (currentNodeWithinIsland && currentNodeZ >= playerZ + 2) return;

    engine.bufferImage = currentNodeTransparent ? Images.atlas_nodes_transparent : Images.atlas_nodes;


    switch (currentNodeType) {
      case NodeType.Grass:
        renderNodeGrass();
        break;
      case NodeType.Brick:
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_2);
        return;
      case NodeType.Bricks_Red:
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_13);
        return;
      case NodeType.Bricks_Brown:
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_14);
        return;
      case NodeType.Wood:
        const index_grass = 5;
        const srcX = GameIsometricConstants.Sprite_Width_Padded * index_grass;
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
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_8);
        return;
      case NodeType.Metal:
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_4);
        return;
      case NodeType.Road:
        renderNodeTemplateShadedOffset(GameIsometricConstants.Sprite_Width_Padded_9, offsetY: 7);
        return;
      case NodeType.Tree_Bottom:
        renderTreeBottom();
        break;
      case NodeType.Tree_Top:
        renderTreeTop();
        break;
      case NodeType.Scaffold:
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_15);
        break;
      case NodeType.Road_2:
        renderNodeShadedOffset(srcX: 1490, srcY: 305, offsetX: 0, offsetY: 7);
        return;
      case NodeType.Wooden_Plank:
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_10);
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
        renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_16);
        return;
      case NodeType.Bau_Haus:
        const index_grass = 6;
        const srcX = GameIsometricConstants.Sprite_Width_Padded * index_grass;
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
        const srcX = GameIsometricConstants.Sprite_Width_Padded * index_grass;
        renderNodeTemplateShaded(srcX);
        return;
      case NodeType.Fireplace:
        renderStandardNode(
          srcX: AtlasNode.Campfire_X,
          srcY: AtlasNode.Node_Campfire_Y + ((gamestream.animation.animationFrame % 6) * 72),
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
        if (gamestream.isometric.client.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_X,
          srcY: AtlasNode.Spawn_Y,
        );
        break;
      case NodeType.Spawn_Weapon:
        if (gamestream.isometric.client.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_Weapon_X,
          srcY: AtlasNode.Spawn_Weapon_Y,
        );
        break;
      case NodeType.Spawn_Player:
        if (gamestream.isometric.client.playMode) return;
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

  void renderNodeGrass() {
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
    renderNodeTemplateShaded(GameIsometricConstants.Sprite_Width_Padded_3);
  }

  void renderNodeGrassLong() {
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
          srcX: AtlasNodeX.Grass_Long + ((((row - column) + gamestream.animation.animationFrameGrass) % 6) * 48), // TODO Expensive Operation
          srcY: 0,
        );
        return;
    }
  }

  void renderNodeRainLanding() {
    if (currentNodeIndex > gamestream.isometric.scene.area && nodeTypes[currentNodeIndex - gamestream.isometric.scene.area] == NodeType.Water){
      engine.renderSprite(
        image: Images.atlas_nodes,
        srcX: AtlasNode.Node_Rain_Landing_Water_X,
        srcY: 72.0 * ((gamestream.animation.animationFrame + row + column) % 8), // TODO Expensive Operation
        srcWidth: GameIsometricConstants.Sprite_Width,
        srcHeight: GameIsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + gamestream.animation.animationFrameWaterHeight + 14,
        anchorY: 0.3,
        color: currentNodeColor,
      );
      return;
    }
    renderStandardNode(
      srcX: gamestream.isometric.client.srcXRainLanding,
      srcY: 72.0 * ((gamestream.animation.animationFrame + row + column) % 6), // TODO Expensive Operation
    );
  }

  void renderNodeRainFalling() {
    renderStandardNode(
      srcX: gamestream.isometric.client.srcXRainFalling,
      srcY: 72.0 * ((gamestream.animation.animationFrame + row + row + column) % 6), // TODO Expensive Operation
    );
  }

  void renderTreeTop() => renderNodeBelowVariation == 0 ? renderTreeTopPine() : renderTreeTopOak();

  void renderTreeBottom() => renderNodeVariation == 0 ? renderTreeBottomPine() : renderTreeBottomOak();

  void renderTreeTopOak(){
    var shift = GameAnimation.treeAnimation[((row - column) + gamestream.animation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    engine.renderSprite(
      image: Images.atlas_nodes,
      srcX: AtlasNodeX.Tree_Top,
      srcY: 433.0,
      srcWidth: AtlasNode.Node_Tree_Top_Width,
      srcHeight: AtlasNode.Node_Tree_Top_Height,
      dstX: currentNodeDstX + (shift * 0.5),
      dstY: currentNodeDstY,
      // color: getNodeColorAtIndex(currentNodeIndex - (gamestream.isometricEngine.nodes.area + gamestream.isometricEngine.nodes.area)),
      // color: getNodeColorAtIndex(currentNodeIndex),
      color: renderNodeBelowColor,
    );
  }

  void renderTreeTopPine() {
    var shift = GameAnimation.treeAnimation[((row - column) + gamestream.animation.animationFrame) % GameAnimation.treeAnimation.length] * renderNodeWind;
    engine.renderSprite(
      image: Images.atlas_nodes,
      srcX: 1262,
      srcY: 80 ,
      srcWidth: 45,
      srcHeight: 58,
      dstX: currentNodeDstX + (shift * 0.5),
      dstY: currentNodeDstY,
      // color: getNodeColorAtIndex(currentNodeIndex - (gamestream.isometricEngine.nodes.area + gamestream.isometricEngine.nodes.area)),
      // color: getNodeColorAtIndex(currentNodeIndex),
      color: renderNodeBelowColor,
    );
  }

  void renderTreeBottomOak() {
    engine.renderSprite(
      image: Images.atlas_nodes,
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

  void renderTreeBottomPine() {
    engine.renderSprite(
      image: Images.atlas_nodes,
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

  void renderNodeTemplateShadedOffset(double srcX, {double offsetX = 0, double offsetY = 0}) {
    switch (currentNodeOrientation){
      case NodeOrientation.Solid:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_00,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;

      case NodeOrientation.Corner_Top:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
          srcWidth: 32,
        );

        return;
      case NodeOrientation.Corner_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Slope_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_03,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_04,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_05,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_06,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_07,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_08,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_09,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_10,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_11,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_12,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_13,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_14,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Radial:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_15,
          offsetX: offsetX,
          offsetY: offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -9 + offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: -1 + offsetY,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0 + offsetX,
          offsetY: 2 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: -16 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: -8 + offsetY,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: -16 + offsetX,
          offsetY: 0 + offsetY,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: -8 + offsetY,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 0 + offsetY,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8 + offsetX,
          offsetY: 8 + offsetY,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0 + offsetX,
          offsetY: 16 + offsetY,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8 + offsetX,
          offsetY: 8 + offsetY,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
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
          srcY: GameIsometricConstants.Sprite_Height_Padded_00,
        );
        return;
      case NodeOrientation.Half_North:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Half_East:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_West:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Top:
        renderNodeShadedCustom(
          srcX: srcX + 16,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8 + 16,
          offsetY: -8,
          srcWidth: 32,
        );
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
          srcWidth: 32,
        );
        return;
      case NodeOrientation.Corner_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: 8,
          offsetY: -8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Corner_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_01,
          offsetX: -8,
          offsetY: -8,
        );
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_02,
          offsetX: -8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Slope_North:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_03,
        );
        return;
      case NodeOrientation.Slope_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_04,
        );
        return;
      case NodeOrientation.Slope_South:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_05,
        );
        return;
      case NodeOrientation.Slope_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_06,
        );
        return;
      case NodeOrientation.Slope_Outer_South_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_07,
        );
        return;
      case NodeOrientation.Slope_Outer_North_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_08,
        );
        return;
      case NodeOrientation.Slope_Outer_North_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_09,
        );
        return;
      case NodeOrientation.Slope_Outer_South_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_10,
        );
        return;
      case NodeOrientation.Slope_Inner_South_East:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_11,
        );
        return;
      case NodeOrientation.Slope_Inner_North_East :
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_12,
        );
        return;
      case NodeOrientation.Slope_Inner_North_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_13,
        );
        return;
      case NodeOrientation.Slope_Inner_South_West:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_14,
        );
        return;
      case NodeOrientation.Radial:
        renderStandardNode(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_15,
        );
        return;
      case NodeOrientation.Half_Vertical_Top:
        renderNodeShadedCustom(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: -8,
          color: gamestream.isometric.scene.nodeColors[currentNodeIndex + gamestream.isometric.scene.area < gamestream.isometric.scene.total ? currentNodeIndex + gamestream.isometric.scene.area : currentNodeIndex],
        );
        return;
      case NodeOrientation.Half_Vertical_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Half_Vertical_Bottom:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_16,
          offsetX: 0,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Top_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: -16,
        );
        return;
      case NodeOrientation.Column_Top_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Column_Top_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: -16,
          offsetY: 0,
        );
        return;
      case NodeOrientation.Column_Center_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: -8,
        );
        break;
      case NodeOrientation.Column_Center_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 0,
        );
        break;
      case NodeOrientation.Column_Center_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: -8,
          offsetY: 8,
        );
        break;

      case NodeOrientation.Column_Bottom_Left:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 0,
          offsetY: 16,
        );
        return;
      case NodeOrientation.Column_Bottom_Center:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
          offsetX: 8,
          offsetY: 8,
        );
        return;
      case NodeOrientation.Column_Bottom_Right:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: GameIsometricConstants.Sprite_Height_Padded_17,
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
          srcY: 80 + GameIsometricConstants.Sprite_Height_Padded,
          offsetX: -8,
          offsetY: -8,
        );
        return;
      case NodeOrientation.Half_South:
        renderNodeShadedOffset(
          srcX: srcX,
          srcY: 80 + GameIsometricConstants.Sprite_Height_Padded,
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
        image: Images.atlas_nodes,
        srcX: 1552,
        srcY: 432 + (gamestream.animation.animationFrame6 * 72.0), // TODO Optimize
        srcWidth: GameIsometricConstants.Sprite_Width,
        srcHeight: GameIsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: 0.3334,
        color: currentNodeColor,
      );

  void renderNodeWater() =>
      engine.renderSprite(
        image: Images.atlas_nodes,
        srcX: AtlasNodeX.Water,
        srcY: AtlasNodeY.Water + (((gamestream.animation.animationFrameWater + ((row + column) * 3)) % 10) * 72.0), // TODO Optimize
        srcWidth: GameIsometricConstants.Sprite_Width,
        srcHeight: GameIsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + gamestream.animation.animationFrameWaterHeight + 14,
        anchorY: 0.3334,
        color: currentNodeColor,
      );

  void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = engine.bufferIndex * 4;
    bufferClr[engine.bufferIndex] = currentNodeColor;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameIsometricConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameIsometricConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameIsometricConstants.Sprite_Width_Half);
    bufferDst[f + 3] = currentNodeDstY - (GameIsometricConstants.Sprite_Height_Third);
    engine.incrementBufferIndex();
  }

  void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }){
    onscreenNodes++;
    final f = engine.bufferIndex << 2;
    bufferClr[engine.bufferIndex] = currentNodeColor;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + GameIsometricConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + GameIsometricConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameIsometricConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (GameIsometricConstants.Sprite_Height_Third) + offsetY;
    engine.incrementBufferIndex();
  }

  void renderNodeShadedCustom({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
    int? color,
    double? srcWidth,
    double? srcHeight
  }){
    onscreenNodes++;
    final f = engine.bufferIndex << 2;
    bufferClr[engine.bufferIndex] = color ?? currentNodeColor;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + (srcWidth ?? GameIsometricConstants.Sprite_Width);
    bufferSrc[f + 3] = srcY + (srcHeight ?? GameIsometricConstants.Sprite_Height);
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (GameIsometricConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (GameIsometricConstants.Sprite_Height_Third) + offsetY;
    engine.incrementBufferIndex();
  }
}
