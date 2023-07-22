import 'dart:math';

import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_mouse.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/library.dart';

class RendererNodes extends IsometricRenderer {

  static const MapNodeTypeToSrcY = <int, double>{
    NodeType.Brick: 1760,
    NodeType.Grass: 1808,
    NodeType.Soil: 1856,
    NodeType.Wood: 1904,
  };

  static const SrcX_Side_Top = 0.0;
  static const SrcX_Side_West = 49.0;
  static const SrcX_Side_South = 74.0;

  static const Node_Size = 48.0;

  static const Node_Size_Half = 24.0;
  static const Node_Size_Third = 16.0;
  static const Node_Size_Sixth = 8.0;

  static const Node_Sprite_Width = 48.0;

  static const Cell_Size = 16.0;
  static const Cell_Size_Half = 8.0;

  static const Cell_Top_Src_X =  99.0;
  static const Cell_Top_Src_Y =  0.0;
  static const Cell_Top_Width =  8.0;
  static const Cell_Top_Height =  8.0;
  static const Cell_Top_Width_Src =  16.0;
  static const Cell_Top_Height_Src =  16.0;

  static const Cell_South_Src_X = 110.0;
  static const Cell_South_Src_Y = 18.0;
  static const Cell_South_Width = 8.0;
  static const Cell_South_Height = 8.0;
  static const Cell_South_Width_Src = 8.0;
  static const Cell_South_Height_Src = 15.0;

  static const Cell_West_Src_X =  99.0;
  static const Cell_West_Src_Y =  18.0;
  static const Cell_West_Width = 8.0;
  static const Cell_West_Height = 8.0;
  static const Cell_West_Width_Src = 8.0;
  static const Cell_West_Height_Src = 16.0;

  static const Node_South_Height = 24.0;

  // VARIABLES
  var previousVisibility = 0;

  final bufferClr = gamestream.engine.bufferClr;
  final bufferSrc = gamestream.engine.bufferSrc;
  final bufferDst = gamestream.engine.bufferDst;
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
  var z = 0;
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

  RendererNodes(super.scene);

  double get currentNodeRenderY => IsometricRender.rowColumnZToRenderY(row, column, currentNodeZ);

  int get colorCurrent => scene.nodeColors[currentNodeIndex];

  int get colorAbove {
    final nodeAboveIndex = currentNodeIndex + scene.area;
    if (nodeAboveIndex > scene.nodeColors.length)
      return scene.ambientColor;
    return scene.nodeColors[nodeAboveIndex];
  }

  int get colorWest {
    if (column + 1 >= scene.totalColumns){
      return scene.ambientColor;
    }
    return scene.nodeColors[currentNodeIndex + 1];
  }

  int get colorSouth {
    if (row + 1 >= scene.totalRows) {
      return scene.ambientColor;
    }
    return scene.nodeColors[currentNodeIndex + scene.totalColumns];
  }
  int get currentNodeOrientation => scene.nodeOrientations[currentNodeIndex];

  int get windType => gamestream.isometric.server.windTypeAmbient.value;

  int get currentNodeVariation => scene.nodeVariations[currentNodeIndex];

  int get renderNodeOrientation => scene.nodeOrientations[currentNodeIndex];

  int get renderNodeVariation => scene.nodeVariations[currentNodeIndex];

  int get renderNodeBelowIndex => currentNodeIndex - scene.area;

  int get renderNodeBelowVariation => renderNodeBelowIndex > 0 ? scene.nodeVariations[renderNodeBelowIndex] : renderNodeVariation;

  int get renderNodeBelowColor => scene.getNodeColorAtIndex(currentNodeIndex - scene.area);

  @override
  void renderFunction() {
    gamestream.engine.bufferImage = atlas_nodes;
    previousNodeTransparent = false;
    renderPlain();
    return;


    final playerInsideIsland = gamestream.isometric.player.playerInsideIsland;
    final nodeTypes = scene.nodeTypes;

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
          currentNodeWithinIsland = island[row * scene.totalColumns + column];
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
      currentNodeDstX += IsometricConstants.Sprite_Width;
    }
  }

  var plainIndex = 0;

  var plainStartRow = 0;
  var plainStartColumn = 0;
  var plainStartZ = 0;
  var totalPlains = 0;

  void updatePlain(){

  }

  void onPlainIndexChanged(){
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final height = scene.totalZ;
    final rowMax = rows - 1;
    final columnMax = columns - 1;
    final heightMax = height - 1;
    plainStartRow = clamp(plainIndex - (height + columns), 0, rowMax);
    plainStartColumn = clamp(plainIndex - height + 1, 0, columnMax);
    plainStartZ = clamp(plainIndex, 0, heightMax);
    order = (plainStartRow * Node_Size) + (plainStartColumn * Node_Size) + (plainStartZ * Node_Height);
  }

  void renderPlain(){

    if (plainIndex < 0)
      return;

    final height = scene.totalZ;
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final rowMax = rows - 1;
    final columnMax = columns - 1;
    final heightMax = height - 1;
    final shiftRight = columns - 1;

    plainStartRow = clamp(plainIndex - (height + columns), 0, rowMax);
    plainStartColumn = clamp(plainIndex - height + 1, 0, columnMax);
    plainStartZ = clamp(plainIndex, 0, heightMax);

    var lineColumn = plainStartColumn;
    var lineRow = plainStartRow;
    var lineZ = plainStartZ;

    column = lineColumn;
    row = lineRow;


    while (lineZ >= 0) {
      // increment line
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
            currentNodeType = scene.nodeTypes[currentNodeIndex];
            if (currentNodeType != NodeType.Empty) {
              renderCurrentNode();
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

      if (lineColumn < rowMax){
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
    updatePlain();
    return;

    currentNodeZ++;
    if (currentNodeZ > nodesMaxZ) {
      currentNodeZ = 0;
      nodesShiftIndexDown();
      if (!remaining) return;
      nodesCalculateMinMaxZ();
      if (!remaining) return;

      assert (column >= 0);
      assert (row >= 0);
      assert (row < scene.totalRows);
      assert (column < scene.totalColumns);

      trimLeft();

      while (currentNodeRenderY > screenBottom) {
        currentNodeZ++;
        if (currentNodeZ > nodesMaxZ) {
          remaining = false;
          return;
        }
      }
    } else {
      assert (nodesStartRow < scene.totalRows);
      assert (column < scene.totalColumns);
      row = nodesStartRow;
      column = nodeStartColumn;
    }

    currentNodeIndex = (currentNodeZ * scene.area) + (row * scene.totalColumns) + column;
    assert (currentNodeZ >= 0);
    assert (row >= 0);
    assert (column >= 0);
    assert (currentNodeIndex >= 0);
    assert (currentNodeZ < scene.totalZ);
    assert (row < scene.totalRows);
    assert (column < scene.totalColumns);
    assert (currentNodeIndex < scene.total);
    currentNodeDstX = (row - column) * Node_Size_Half;
    currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    currentNodeType = scene.nodeTypes[currentNodeIndex];
    // orderZ = currentNodeZ;
    order = (row + column).toDouble() - 0.5;
  }

  @override
  int getTotal() => scene.total;

  @override
  void reset() {
    final columns = scene.totalColumns;
    final rows = scene.totalRows;
    final height = scene.totalZ;
    totalPlains = columns + rows + height - 2;
    plainIndex = 0;
    onPlainIndexChanged();
    nodesRowsMax = scene.totalRows - 1;
    nodesGridTotalZMinusOne = scene.totalZ - 1;
    offscreenNodesTop = 0;
    offscreenNodesRight = 0;
    offscreenNodesBottom = 0;
    offscreenNodesLeft = 0;
    offscreenNodes = 0;
    onscreenNodes = 0;
    nodesMinZ = 0;
    // orderZ = 0;
    currentNodeZ = 0;
    nodesGridTotalColumnsMinusOne = scene.totalColumns - 1;
    playerZ = gamestream.isometric.player.position.indexZ;
    playerRow = gamestream.isometric.player.position.indexRow;
    playerColumn = gamestream.isometric.player.position.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (gamestream.isometric.player.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (gamestream.isometric.player.position.indexZ ~/ 2);
    playerProjection = playerIndex % scene.projection;
    scene.offscreenNodes = 0;
    scene.onscreenNodes = 0;

    screenRight = gamestream.engine.Screen_Right + Node_Size;
    screenLeft = gamestream.engine.Screen_Left - Node_Size;
    screenTop = gamestream.engine.Screen_Top - 72;
    screenBottom = gamestream.engine.Screen_Bottom + 72;
    var screenTopLeftColumn = IsometricRender.convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(IsometricRender.convertWorldToRow(screenRight, screenBottom, 0), 0, scene.totalRows - 1);
    nodesScreenTopLeftRow = IsometricRender.convertWorldToRow(screenLeft, screenTop, 0);

    if (nodesScreenTopLeftRow < 0){
      screenTopLeftColumn += nodesScreenTopLeftRow;
      nodesScreenTopLeftRow = 0;
    }
    if (screenTopLeftColumn < 0){
      nodesScreenTopLeftRow += screenTopLeftColumn;
      screenTopLeftColumn = 0;
    }
    if (screenTopLeftColumn >= scene.totalColumns){
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
    currentNodeIndex = (currentNodeZ * scene.area) + (row * scene.totalColumns) + column;
    currentNodeType = scene.nodeTypes[currentNodeIndex];
    currentNodeWithinIsland = false;

    updateTransparencyGrid();
    updateHeightMapPerception();

    total = getTotal();
    index = 0;
    remaining = total > 0;
    scene.resetNodeColorStack();
    scene.resetNodeAmbientStack();
    gamestream.isometric.client.applyEmissions();

    // highlightCharacterNearMouse();
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

    if (visible3D.length != scene.total) {
      visible3D = List.generate(scene.total, (index) => false);
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

    final height = scene.heightMap[gamestream.isometric.player.areaNodeIndex];

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
     if (scene.heightMap[i] <= zMin) return;
     island[i] = true;

     var searchIndex = i + (scene.area * gamestream.isometric.player.indexZ);
     addVisible3D(searchIndex);

     var spaceReached = scene.nodeOrientations[searchIndex] == NodeOrientation.None;
     var gapReached = false;

     while (true) {
       searchIndex += scene.area;
        if (searchIndex >= scene.total) break;
        final nodeOrientation = scene.nodeOrientations[searchIndex];
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
     searchIndex = i + (scene.area * gamestream.isometric.player.indexZ);
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
    final nodeOrientation = scene.nodeOrientations[index];
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
    final nodeOrientation = scene.nodeOrientations[index];
    if (nodeOrientation == NodeOrientation.None) return false;
    if (NodeOrientation.isHalf(nodeOrientation)) return false;
    if (NodeOrientation.isRadial(nodeOrientation)) return false;
    if (NodeOrientation.isColumn(nodeOrientation)) return false;
    if (NodeOrientation.isCorner(nodeOrientation)) return false;
    return true;
  }

  void trimLeft(){
    var currentNodeRenderX = (row - column) * Node_Size_Half;
    final maxRow = scene.totalRows - 1;
    while (currentNodeRenderX < screenLeft && column > 0 && row < maxRow){
      row++;
      column--;
      currentNodeRenderX += Node_Size;
    }
    nodesSetStart();
  }

  void nodesSetStart(){
    nodesStartRow = clamp(row, 0, scene.totalRows - 1);
    nodeStartColumn = clamp(column, 0, scene.totalColumns - 1);

    assert (nodesStartRow >= 0);
    assert (nodeStartColumn >= 0);
    assert (nodesStartRow < scene.totalRows);
    assert (nodeStartColumn < scene.totalColumns);
  }

  void nodesShiftIndexDown(){

    column = row + column + 1;
    row = 0;
    if (column < scene.totalColumns) {
      nodesSetStart();
      return;
    }

    if (column - nodesGridTotalColumnsMinusOne >= scene.totalRows){
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
      if (nodesMinZ >= scene.totalZ){
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

    const torchSrcY = 735;
    const torchSrcXCalm = 1665.0;
    const torchSrcXWindy = 1691.0;

    gamestream.engine.renderSprite(
      image: Images.atlas_nodes,
      srcX: windType == WindType.Calm ? torchSrcXCalm : torchSrcXWindy,
      srcY: torchSrcY + AtlasNode.Height_Torch + (((row + (gamestream.isometric.animation.animationFrame)) % 6) * AtlasNode.Height_Torch), // TODO Optimize
      srcWidth: AtlasNode.Width_Torch,
      srcHeight: AtlasNode.Height_Torch,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      anchorY: AtlasNodeAnchorY.Torch,
      color: colorCurrent,
    );
    return;
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



  var previousNodeTransparent = false;

  void renderCurrentNode() {

    if (currentNodeWithinIsland && currentNodeZ >= playerZ + 2) return;

    final transparent = currentNodeTransparent;
    if (previousNodeTransparent != transparent) {
      previousNodeTransparent = transparent;
      gamestream.engine.bufferImage = transparent ? Images.atlas_nodes_transparent : Images.atlas_nodes;
    }

    final nodeType = currentNodeType;
    final nodeOrientation = currentNodeOrientation;

    if (MapNodeTypeToSrcY.containsKey(nodeType)){
      renderDynamic(nodeType, nodeOrientation);
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
        renderTreeBottom();
        break;
      case NodeType.Tree_Top:
        renderTreeTop();
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
        if (currentNodeOrientation == NodeOrientation.Destroyed) return;
        renderStandardNode(
          srcX: 1753.0,
          srcY: 867.0,
        );
        return;
      case NodeType.Fireplace:
        renderStandardNode(
          srcX: AtlasNode.Campfire_X,
          srcY: AtlasNode.Node_Campfire_Y + ((gamestream.isometric.animation.animationFrame % 6) * 72),
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
        throw Exception('renderNode(index: ${currentNodeIndex}, type: ${NodeType.getName(currentNodeType)}, orientation: ${NodeOrientation.getName(scene.nodeOrientations[currentNodeIndex])}');
    }
  }

  var srcY = 0.0;

  void renderDynamic(int nodeType, int nodeOrientation) {
    srcY = MapNodeTypeToSrcY[nodeType] ??
        (throw Exception('RendererNodes.mapNodeTypeToSrcY(nodeType: $nodeType)'));

    switch (nodeOrientation) {
      case NodeOrientation.Solid:
        renderDynamicSolid(srcY);
        break;
      case NodeOrientation.Half_West:
        renderDynamicHalfWest(
            colorWest: colorWest,
            colorSouth: colorSouth,
        );
        break;
      case NodeOrientation.Half_East:
        renderDynamicHalfEast(
          colorWest: colorWest,
          colorSouth: colorSouth,
        );
        break;
      case NodeOrientation.Half_South:
        renderDynamicHalfSouth(srcY);
        break;
      case NodeOrientation.Half_North:
        renderDynamicHalfNorth(
            srcY: srcY,
            colorSouth: colorSouth,
            colorWest: colorWest,
        );
        break;

      case NodeOrientation.Corner_South_East:
        renderCornerSouthEast(srcY);
        break;

      case NodeOrientation.Corner_North_East:
        renderCornerNorthEast(srcY);
        break;

      case NodeOrientation.Corner_North_West:
        renderCornerNorthWest(srcY);
        break;

      case NodeOrientation.Corner_South_West:
        renderCornerSouthWest(srcY);
        break;

      case NodeOrientation.Slope_East:
        renderSlopeEast(srcY);
        break;

      case NodeOrientation.Slope_West:
        renderSlopeWest(srcY);
        break;

      case NodeOrientation.Slope_South:
        renderSlopeSouth();
        break;

      case NodeOrientation.Slope_North:
        renderSlopeNorth();
        break;
    }
  }

  void renderSlopeNorth() {

    renderCellTopColumn(
      dstX: -Node_Size_Half,
      dstY: -Cell_South_Height,
      color: colorAbove,
    );

    renderCellSouthColumn(
      dstX: -Cell_South_Width - Cell_South_Width,
      dstY: 0,
      color: colorCurrent,
    );

    renderCellTopColumn(
      dstX: -Node_Size_Half + Cell_South_Width,
      dstY: -Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellSouthColumn(
      dstX: -Cell_South_Width - Cell_South_Width + Cell_South_Width,
      dstY: Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellTopColumn(
      dstX: -Node_Size_Half + Cell_South_Width + Cell_South_Width,
      dstY: -Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellSouthColumn(
      dstX: -Cell_South_Width - Cell_South_Width + Cell_South_Width + Cell_South_Width,
      dstY: Cell_South_Height + Cell_South_Height + Cell_South_Height + Cell_South_Height,
      color: colorCurrent,
    );

    renderCellWest(
        dstX: -Node_Size_Half,
        dstY: 0,
        color: colorWest,
    );

    renderCellWest(
        dstX: -Node_Size_Half,
        dstY: Cell_West_Height,
        color: colorWest,
    );

    renderCellWest(
        dstX: -Node_Size_Half,
        dstY: Cell_West_Height + Cell_West_Height,
        color: colorWest,
    );

    // column 2

    renderCellWest(
      dstX: -Node_Size_Half + Cell_West_Width,
      dstY: Cell_West_Height + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      dstX: -Node_Size_Half + Cell_West_Width,
      dstY: Cell_West_Height + Cell_West_Height + Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // column 3

    renderCellWest(
      dstX: -Node_Size_Half + Cell_West_Width + Cell_West_Width,
      dstY: Cell_West_Height + Cell_West_Height + Cell_West_Height + Cell_West_Height,
      color: colorWest,
    );
  }

  void renderCellSouthColumn({
    required double dstX,
    required double dstY,
    required int color,
  }) {
    renderCellSouth(
        dstX: dstX,
        dstY: dstY,
        color: color,
    );
    renderCellSouth(
      dstX: dstX + Cell_South_Width,
      dstY: dstY -Cell_South_Height,
      color: color,
    );
    renderCellSouth(
      dstX: dstX + Cell_South_Width + Cell_South_Width,
      dstY: dstY -Cell_South_Height - Cell_South_Height,
      color: color,
    );
  }

  void renderSlopeSouth() {

    renderNodeSideSouth(
      dstX: 0,
      dstY: 0,
      color: colorSouth,
    );

    // row 3

    renderCellTop(
      dstX: -Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      dstX: -Cell_Top_Width + Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      dstX: -Cell_Top_Width + Cell_Top_Width + Cell_Top_Width - Cell_Top_Width - Cell_Top_Width,
      dstY: Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );


    // row 2

    renderCellTop(
      dstX: -Cell_Top_Width - Cell_Top_Width,
      dstY: Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      dstX: -Cell_Top_Width + Cell_Top_Width - Cell_Top_Width,
      dstY: Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      dstX: -Cell_Top_Width + Cell_Top_Width + Cell_Top_Width - Cell_Top_Width,
      dstY: Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    // column 1

    renderCellWest(
        dstX: -Cell_West_Width,
        dstY: Node_Size_Half + Cell_South_Height,
        color: colorWest,
    );

    renderCellWest(
        dstX: -Cell_West_Width,
        dstY: Node_Size_Half + Cell_South_Height - Cell_West_Height,
        color: colorWest,
    );

    renderCellWest(
        dstX: -Cell_West_Width,
        dstY: Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
        color: colorWest,
    );

    // column 2

    renderCellWest(
      dstX: -Cell_West_Width - Cell_West_Width,
      dstY: Node_Size_Half + Cell_South_Height - Cell_West_Height,
      color: colorWest,
    );

    renderCellWest(
      dstX: -Cell_West_Width - Cell_West_Width,
      dstY: Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // column 3

    renderCellWest(
      dstX: -Cell_West_Width - Cell_West_Width - Cell_West_Width,
      dstY: Node_Size_Half + Cell_South_Height - Cell_West_Height - Cell_West_Height,
      color: colorWest,
    );

    // row 1

    renderCellTop(
        dstX: -Cell_Top_Width,
        dstY: Cell_Top_Height,
        color: colorAbove,
    );

    renderCellTop(
      dstX: -Cell_Top_Width + Cell_Top_Width,
      dstY: Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );

    renderCellTop(
      dstX: -Cell_Top_Width + Cell_Top_Width + Cell_Top_Width,
      dstY: Cell_Top_Height - Cell_Top_Height - Cell_Top_Height,
      color: colorAbove,
    );
  }

  void renderSlopeWest(double srcY) {

    renderCellTop(
      dstX: Cell_Size_Half,
      dstY:  Node_Size_Half + Cell_South_Height -Cell_Size - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      dstX: 0,
      dstY: Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      dstX: - Cell_Size_Half,
      dstY:  Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      dstX: 0,
      dstY:  Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      dstX: - Cell_Size_Half,
      dstY: Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderCellTop(
      dstX: - Cell_Size_Half - Cell_Size_Half,
      dstY: Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
      color: colorCurrent,
    );

    renderNodeSideWest(
      dstX: -Node_Size_Half,
      dstY: 0,
      color: colorWest,
    );

    renderCellSouth(
      dstX: 0,
      dstY: Node_Size_Half + Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      dstX: Cell_South_Width,
      dstY: Node_Size_Half + Cell_South_Height -Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      dstX: Cell_South_Width + Cell_South_Width,
      dstY:  Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      dstX: 0,
      dstY: Node_Size_Half + Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      dstX: Cell_South_Width,
      dstY: Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellSouth(
      dstX: 0,
      dstY: Node_Size_Half + Cell_South_Height - Cell_South_Height - Cell_South_Height,
      color: colorSouth,
    );

    renderCellTop(
        dstX: -Cell_Size_Half,
        dstY: Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half,
        color: colorAbove,
    );

    renderCellTop(
        dstX: -Cell_Size_Half - Cell_Size_Half,
        dstY: Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half,
        color: colorAbove,
    );

    renderCellTop(
        dstX: -Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
        dstY: Node_Size_Half + Cell_South_Height - Cell_Size - Cell_Size_Half - Cell_Size_Half - Cell_Size_Half,
        color: colorAbove,
    );
  }

  void renderCornerSouthWest(double srcY) {
    renderDynamicHalfSouth(srcY);
    renderDynamicHalfWest(
      colorWest: colorWest,
      colorSouth: colorSouth,
    );
  }

  void renderCornerNorthWest(double srcY) {
     renderDynamicHalfNorth(
      srcY: srcY,
      colorSouth: colorCurrent,
      colorWest: colorWest,
    );
    renderDynamicHalfWest(
      colorSouth: colorSouth,
      colorWest: colorWest,
    );
  }

  void renderCornerNorthEast(double srcY) {
     renderDynamicHalfNorth(
        srcY: srcY,
        colorWest: colorWest,
        colorSouth: colorCurrent,
    );

    final dstX = 0.0;
    final dstY = -Cell_Size;

    renderNodeSideWest(
      dstX: dstX,
      dstY: dstY + Node_Size_Sixth,
      width: Cell_Size,
      color: colorCurrent,
    );

    renderNodeSideSouth(
      width: Node_Size_Sixth,
      dstX: dstX + Node_Size_Half - Cell_Size_Half,
      dstY: dstY + Node_Size_Sixth - Cell_Size_Half,
      color: colorSouth,
    );

    renderCellTop(
      dstX: dstX,
      dstY: dstY,
      color: colorAbove,
    );

    renderCellTop(
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderCornerSouthEast(double srcY) {
    final dstX = -Cell_Size_Half;
    final dstY = Cell_Size;

    renderSideEastWest(
      dstX: -Node_Size_Sixth,
      dstY: -Node_Size_Sixth - Node_Size_Sixth - Node_Size_Sixth,
      colorWest: colorCurrent,
      colorSouth: colorSouth,
    );

    renderNodeSideWest(
      dstX: dstX,
      dstY: dstY,
      width: Node_Size_Sixth,
      color: colorWest,
    );

    renderNodeSideSouth(
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half + Node_Size_Sixth,
      color: colorSouth,
    );

    renderCellTop(
      dstX: dstX,
      dstY: dstY - Node_Size_Half + Node_Size_Third,
      color: colorAbove,
    );

    renderCellTop(
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderSlopeEast(double srcY) {
    renderSlopeEastStep(
      srcY: srcY,
      dstX: -Node_Size_Half,
      dstY: Node_South_Height - Cell_South_Height,
      colorWest: colorWest,
      colorTop: colorCurrent,
    );
    renderSlopeEastStep(
      srcY: srcY,
      dstX: -Node_Size_Half + Cell_Size_Half,
      dstY: Node_South_Height - Cell_South_Height - Cell_Size,
      colorWest: colorCurrent,
      colorTop: colorCurrent,
    );
    renderSlopeEastStep(
      srcY: srcY,
      dstX: -Node_Size_Half + Cell_Size_Half + Cell_Size_Half,
      dstY: Node_South_Height - Cell_South_Height - Cell_Size - Cell_Size,
      colorWest: colorCurrent,
      colorTop: colorAbove,
    );
    renderCellSouth(
        dstX: -Node_Size_Half +Cell_Size + Cell_Size,
        dstY: Node_South_Height,
        color: colorSouth,
    );
    renderCellSouth(
        dstX: -Node_Size_Half + Cell_Size + Cell_Size + Cell_South_Width,
        dstY: Node_South_Height -Cell_South_Height,
        color: colorSouth,
    );
    renderCellSouth(
        dstX: -Node_Size_Half + Cell_Size + Cell_Size + Cell_South_Width,
        dstY: Node_South_Height -Cell_South_Height - Cell_South_Height,
        color: colorSouth,
    );
  }

  void renderSlopeEastStep({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorTop,
  }) {

    renderCellWest(
      dstX: dstX,
      dstY: dstY + 1,
      color: colorWest,
    );

    renderCellWest(
      dstX: dstX + Cell_West_Width,
      dstY: dstY + Cell_Size_Half + 1,
      color: colorWest,
    );

    renderCellWest(
      dstX: dstX + Cell_West_Width + Cell_West_Width,
      dstY: dstY + Cell_Size_Half + Cell_Size_Half + 1,
      color: colorWest,
    );

    renderCellTop(
      dstX: dstX,
      dstY: dstY - Cell_Size_Half,
      color: colorTop,
    );

    renderCellTop(
      dstX: dstX + Cell_Size_Half,
      dstY: dstY - Cell_Size_Half + Cell_Size_Half,
      color: colorTop,
    );

    renderCellTop(
      dstX: dstX + Cell_Size_Half + Cell_Size_Half,
      dstY: dstY - Cell_Size_Half + Cell_Size_Half + Cell_Size_Half,
      color: colorTop,
    );

    renderCellSouth(
      dstX: dstX + Cell_Size_Half + Cell_Size_Half + Cell_Size_Half,
      dstY: dstY - Cell_Size_Half + Cell_Size_Half + Cell_Size_Half + Cell_Size_Half,
      color: colorSouth,
    );
  }

  void renderDynamicHalfNorth({
    required double srcY,
    required int colorSouth,
    required int colorWest,
  }) {
    renderDynamicSideNorthSouth(
      srcY: srcY,
      dstX: -Node_Size_Half,
      dstY: 0,
      colorSouth: colorSouth,
      colorWest: colorWest,
    );
  }

  void renderDynamicHalfSouth(double srcY) {
     renderDynamicSideNorthSouth(
      srcY: srcY,
      dstX: -Node_Size_Sixth,
      dstY: Node_Size_Third,
      colorWest: colorWest,
      colorSouth: colorSouth,
    );
  }

  void renderDynamicSolid(double srcY) {
    renderNodeSideTop();
    renderNodeSideWest(
        dstX: -Node_Size_Half,
        color: colorWest,
    );
    renderNodeSideSouth(
      dstX: 0,
      dstY: 0,
      color: colorSouth,
    );
  }

  void renderDynamicHalfWest({
    required int colorWest,
    required int colorSouth,
  }) => renderSideEastWest(
      dstX: -Node_Size_Half,
      dstY: -Node_Size_Sixth,
      colorWest: colorWest,
      colorSouth: colorSouth,
    );

  void renderDynamicHalfEast({
    required int colorWest,
    required int colorSouth,
  }) => renderSideEastWest(
      dstX: -Node_Size_Sixth,
      dstY: -Node_Size_Sixth - Node_Size_Sixth - Node_Size_Sixth,
      colorSouth: colorSouth,
      colorWest: colorWest,
    );

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
    renderNodeTemplateShaded(IsometricConstants.Sprite_Width_Padded_3);
  }

  void renderNodeGrassLong() {
    if (currentNodeOrientation == NodeOrientation.Destroyed) return;
    switch (windType) {
      case WindType.Calm:
        renderStandardNode(
          srcX: AtlasNodeX.Grass_Long,
          srcY: 0,
        );
        return;
      default:
        renderStandardNode(
          srcX: AtlasNodeX.Grass_Long + ((((row - column) + gamestream.isometric.animation.animationFrameGrass) % 6) * 48), // TODO Expensive Operation
          srcY: 0,
        );
        return;
    }
  }

  void renderNodeRainLanding() {
    if (currentNodeIndex > scene.area && scene.nodeTypes[currentNodeIndex - scene.area] == NodeType.Water){
      gamestream.engine.renderSprite(
        image: Images.atlas_nodes,
        srcX: AtlasNode.Node_Rain_Landing_Water_X,
        srcY: 72.0 * ((gamestream.isometric.animation.animationFrame + row + column) % 8), // TODO Expensive Operation
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + gamestream.isometric.animation.animationFrameWaterHeight + 14,
        anchorY: 0.3,
        color: colorCurrent,
      );
      return;
    }
    renderStandardNode(
      srcX: gamestream.isometric.client.srcXRainLanding,
      srcY: 72.0 * ((gamestream.isometric.animation.animationFrame + row + column) % 6), // TODO Expensive Operation
    );
  }

  void renderNodeRainFalling() {
    renderStandardNode(
      srcX: gamestream.isometric.client.srcXRainFalling,
      srcY: 72.0 * ((gamestream.isometric.animation.animationFrame + row + row + column) % 6), // TODO Expensive Operation
    );
  }

  void renderTreeTop() => renderNodeBelowVariation == 0 ? renderTreeTopPine() : renderTreeTopOak();

  void renderTreeBottom() => renderNodeVariation == 0 ? renderTreeBottomPine() : renderTreeBottomOak();

  void renderTreeTopOak(){
    var shift = IsometricAnimation.treeAnimation[((row - column) + gamestream.isometric.animation.animationFrame) % IsometricAnimation.treeAnimation.length] * windType;
    gamestream.engine.renderSprite(
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
    var shift = IsometricAnimation.treeAnimation[((row - column) + gamestream.isometric.animation.animationFrame) % IsometricAnimation.treeAnimation.length] * windType;
    gamestream.engine.renderSprite(
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
    gamestream.engine.renderSprite(
      image: Images.atlas_nodes,
      srcX: AtlasNodeX.Tree_Bottom,
      srcY: 433.0,
      srcWidth: AtlasNode.Width_Tree_Bottom,
      srcHeight: AtlasNode.Node_Tree_Bottom_Height,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      color: scene.getNodeColorAtIndex(currentNodeIndex),
    );
  }

  void renderTreeBottomPine() {
    gamestream.engine.renderSprite(
      image: Images.atlas_nodes,
      srcX: 1216,
      srcY: 80,
      srcWidth: 45,
      srcHeight: 72,
      dstX: currentNodeDstX,
      dstY: currentNodeDstY,
      color: scene.getNodeColorAtIndex(currentNodeIndex),
      anchorY: 0.5,
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
          color: scene.nodeColors[currentNodeIndex + scene.area < scene.total ? currentNodeIndex + scene.area : currentNodeIndex],
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
      gamestream.engine.renderSprite(
        image: Images.atlas_nodes,
        srcX: 1552,
        srcY: 432 + (gamestream.isometric.animation.animationFrame6 * 72.0), // TODO Optimize
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY,
        anchorY: 0.3334,
        color: colorCurrent,
      );

  void renderNodeWater() =>
      gamestream.engine.renderSprite(
        image: Images.atlas_nodes,
        srcX: AtlasNodeX.Water,
        srcY: AtlasNodeY.Water + (((gamestream.isometric.animation.animationFrameWater + ((row + column) * 3)) % 10) * 72.0), // TODO Optimize
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + gamestream.isometric.animation.animationFrameWaterHeight + 14,
        anchorY: 0.3334,
        color: colorCurrent,
      );

  void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = gamestream.engine.bufferIndex * 4;
    bufferClr[gamestream.engine.bufferIndex] = colorCurrent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + IsometricConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + IsometricConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (IsometricConstants.Sprite_Width_Half);
    bufferDst[f + 3] = currentNodeDstY - (IsometricConstants.Sprite_Height_Third);
    gamestream.engine.incrementBufferIndex();
  }

  void renderNodeSideTop() => renderCustomNode(
      srcX: SrcX_Side_Top,
      srcY: srcY,
      srcWidth: Node_Size,
      srcHeight: Node_Size,
      dstX: currentNodeDstX - Node_Size_Half,
      dstY: currentNodeDstY - Node_Size_Half,
      color: colorAbove,
    );

  void renderNodeSideWest({
    required int color,
    double dstX = 0,
    double dstY = 0,
    double width = Node_Size_Half,
    double height = Node_Size,
  }) => renderCustomNode(
    srcX: SrcX_Side_West,
    srcY: srcY,
    srcWidth: width,
    srcHeight: height,
    dstX: currentNodeDstX + dstX,
    dstY: currentNodeDstY + dstY,
    color: color,
  );

  void renderNodeSideSouth({
    required double dstX,
    required double dstY,
    required int color,
    double width = Node_Size_Half,
    double height = Node_Size,
  }) =>
      renderCustomNode(
        srcX: SrcX_Side_South,
        srcY: srcY,
        srcWidth: width,
        srcHeight: height,
        dstX: currentNodeDstX + dstX,
        dstY: currentNodeDstY + dstY,
        color: color,
      );

  void renderNodeShadedOffset({
    required double srcX,
    required double srcY,
    required double offsetX,
    required double offsetY,
  }){
    onscreenNodes++;
    final f = gamestream.engine.bufferIndex << 2;
    bufferClr[gamestream.engine.bufferIndex] = colorCurrent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + IsometricConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + IsometricConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (IsometricConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (IsometricConstants.Sprite_Height_Third) + offsetY;
    gamestream.engine.incrementBufferIndex();
  }

  void renderDynamicSideNorthSouth({
    required double srcY,
    required double dstX,
    required double dstY,
    required int colorWest,
    required int colorSouth,
  }){
    renderNodeSideWest(
      dstX: dstX,
      dstY: dstY,
      width: Node_Size_Sixth,
      color: colorWest
    );

    renderNodeSideSouth(
        dstX: dstX + Node_Size_Sixth,
        dstY: dstY - Node_Size_Half + Node_Size_Sixth,
        color: colorSouth,
    );

    renderCellTop(
        dstX: dstX,
        dstY: dstY - Node_Size_Half + Node_Size_Third,
        color: colorAbove,
    );

    renderCellTop(
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half + Node_Size_Sixth,
      color: colorAbove,
    );

    renderCellTop(
      dstX: dstX + Node_Size_Sixth + Node_Size_Sixth,
      dstY: dstY - Node_Size_Half,
      color: colorAbove,
    );
  }

  void renderSideEastWest({
    required double dstX,
    required double dstY,
    required colorWest,
    required colorSouth,
  }){

    renderNodeSideWest(
      dstX: dstX,
      dstY: dstY + Node_Size_Sixth,
      color: colorWest,
    );

    renderNodeSideSouth(
      width: Node_Size_Sixth,
      dstX: dstX + Node_Size_Half,
      dstY: dstY + Node_Size_Sixth,
      color: colorSouth,
    );

    renderCellTop(
      dstX: dstX,
      dstY: dstY,
      color: colorAbove,
    );

    renderCellTop(
      dstX: dstX + Node_Size_Sixth,
      dstY: dstY + Node_Size_Sixth,
      color: colorAbove,
    );

    renderCellTop(
      dstX: dstX + Node_Size_Sixth + Node_Size_Sixth,
      dstY: dstY + Node_Size_Sixth + Node_Size_Sixth,
      color: colorAbove,
    );
  }

  void renderCellTopColumn({
    required double dstX,
    required double dstY,
    required int color,
  }){

    renderCellTop(
      dstX: dstX,
      dstY: dstY,
      color: color,
    );

    renderCellTop(
      dstX: dstX + Cell_Top_Width,
      dstY: dstY - Cell_Top_Height,
      color: color,
    );

    renderCellTop(
      dstX: dstX + Cell_Top_Width + Cell_Top_Width,
      dstY: dstY - Cell_Top_Height - Cell_Top_Height,
      color: color,
    );
  }

  void renderCellTop({
    required double dstX,
    required double dstY,
    required int color,
  }) => renderCustomNode(
      srcX: Cell_Top_Src_X,
      srcY: srcY,
      srcWidth: Cell_Top_Width_Src,
      srcHeight: Cell_Top_Height_Src,
      dstX: currentNodeDstX + dstX,
      dstY: currentNodeDstY + dstY,
      color: color,
    );

  void renderCellWest({
    required double dstX,
    required double dstY,
    required int color,
  }) => renderCustomNode(
      srcX: Cell_West_Src_X,
      srcY: srcY + Cell_West_Src_Y,
      srcWidth: Cell_West_Width_Src,
      srcHeight: Cell_West_Height_Src,
      dstX: currentNodeDstX + dstX,
      dstY: currentNodeDstY + dstY,
      color: color,
    );

  void renderCellSouth({
    required double dstX,
    required double dstY,
    required int color,
  }) => renderCustomNode(
      srcX: Cell_South_Src_X,
      srcY: srcY + Cell_South_Src_Y,
      srcWidth: Cell_South_Width_Src,
      srcHeight: Cell_South_Height_Src,
      dstX: currentNodeDstX + dstX,
      dstY: currentNodeDstY + dstY,
      color: color,
    );

  void renderCustomNode({
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    required double dstX,
    required double dstY,
    required int color,
  }){
    onscreenNodes++;
    final f = gamestream.engine.bufferIndex * 4;
    bufferClr[gamestream.engine.bufferIndex] = color;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + srcWidth;
    bufferSrc[f + 3] = srcY + srcHeight;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = dstX;
    bufferDst[f + 3] = dstY;
    gamestream.engine.incrementBufferIndex();
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
    final f =gamestream.engine.bufferIndex << 2;
    bufferClr[gamestream.engine.bufferIndex] = color ?? colorCurrent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + (srcWidth ?? IsometricConstants.Sprite_Width);
    bufferSrc[f + 3] = srcY + (srcHeight ?? IsometricConstants.Sprite_Height);
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (IsometricConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (IsometricConstants.Sprite_Height_Third) + offsetY;
    gamestream.engine.incrementBufferIndex();
  }

}
