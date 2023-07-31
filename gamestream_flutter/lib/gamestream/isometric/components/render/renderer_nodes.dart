import 'dart:math';

import 'dart:ui' as ui;
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_scene.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/gamestream/isometric/atlases/atlas_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/library.dart';

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

  static const MapNodeTypeToSrcY = <int, double>{
    NodeType.Brick: 1760,
    NodeType.Grass: 1808,
    NodeType.Soil: 1856,
    NodeType.Wood: 1904,
  };

  var dynamicResolutionEnabled = true;
  var totalNodes = 0;
  var totalRows = 0;
  var totalColumns = 0;
  var totalZ = 0;
  var nodeSideTopSrcX = 0.0;
  var nodeSideWestSrcX = 0.0;
  var nodeSize = Node_Size;
  var nodeScale = 1.0;
  var highResolution = true;
  var plainIndex = 0;
  var plainStartRow = 0;
  var plainStartColumn = 0;
  var plainStartZ = 0;
  var totalPlains = 0;
  var orderShiftY = 151.0;

  /// see engine.incrementBufferIndex
  /// cached to save engine lookup for each render
  late final Function incrementBufferIndex;


  // VARIABLES
  var previousVisibility = 0;

  late final Int32List bufferClr;
  late final Float32List bufferSrc;
  late final Float32List bufferDst;

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
  var atlasNodesLoaded = false;
  var ambientColor = 0;

  late Uint32List nodeColors;
  late Uint8List nodeOrientations;

  late IsometricScene scene;

  late final ui.Image atlasNodes;

  RendererNodes(super.isometric) : super(){
    print('RendererNodes()');
    this.scene = isometric.scene;
    bufferClr = isometric.engine.bufferClr;
    bufferDst = isometric.engine.bufferDst;
    bufferSrc = isometric.engine.bufferSrc;
    incrementBufferIndex = isometric.engine.incrementBufferIndex;
  }

  double get currentNodeRenderY => getRenderYOfRowColumnZ(row, column, currentNodeZ);

  int get colorCurrent => nodeColors[currentNodeIndex];

  int get colorAbove {
    final nodeAboveIndex = currentNodeIndex + scene.area;
    if (nodeAboveIndex >= totalNodes)
      return ambientColor;
    return nodeColors[nodeAboveIndex];
  }

  int get colorWest {
    if (column + 1 >= totalColumns){
      return ambientColor;
    }
    return nodeColors[currentNodeIndex + 1];
  }

  int get colorEast {
    if (column - 1 < 0){
      return ambientColor;
    }
    return nodeColors[currentNodeIndex - 1];
  }

  int get colorNorth {
    if (row - 1 < 0) {
      return ambientColor;
    }
    return nodeColors[currentNodeIndex - totalColumns];
  }

  int get colorSouth {
    if (row + 1 >= totalRows) {
      return ambientColor;
    }
    return nodeColors[currentNodeIndex + totalColumns];
  }

  int get currentNodeOrientation => nodeOrientations[currentNodeIndex];

  int get wind => isometric.windTypeAmbient.value;

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


    // final playerInsideIsland = gamestream.isometric.player.playerInsideIsland;
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

  void updatePlain(){

  }

  void onPlainIndexChanged(){
    final columns = isometric.scene.totalColumns;
    final rows = isometric.scene.totalRows;
    final height = isometric.scene.totalZ;
    final rowMax = rows - 1;
    final columnMax = columns - 1;
    final heightMax = height - 1;
    plainStartRow = clamp(plainIndex - (height + columns), 0, rowMax);
    plainStartColumn = clamp(plainIndex - height + 1, 0, columnMax);
    plainStartZ = clamp(plainIndex, 0, heightMax);
    order = (plainStartRow * Node_Size) + (plainStartColumn * Node_Size) + (plainStartZ * Node_Height) + orderShiftY;

  }

  void renderPlain(){

    final nodeTypes = scene.nodeTypes;
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
      z = lineZ;
      currentNodeDstY = ((row + column) * Node_Size_Half) - (lineZ * Node_Height);

      if (currentNodeDstY > screenTop) {
        if (currentNodeDstY > screenBottom){
          break;
        }

        currentNodeIndex = isometric.scene.getIndexZRC(lineZ, lineRow, lineColumn);
        currentNodeDstX = (row - column) * Node_Size_Half;

        while (true) {
          if (currentNodeDstX > screenLeft &&
              currentNodeDstX < screenRight
          ) {
            currentNodeType = nodeTypes[currentNodeIndex];
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
    //   assert (row < isometric.totalRows);
    //   assert (column < isometric.totalColumns);
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
    //   assert (nodesStartRow < isometric.totalRows);
    //   assert (column < isometric.totalColumns);
    //   row = nodesStartRow;
    //   column = nodeStartColumn;
    // }
    //
    // currentNodeIndex = (currentNodeZ * isometric.area) + (row * isometric.totalColumns) + column;
    // assert (currentNodeZ >= 0);
    // assert (row >= 0);
    // assert (column >= 0);
    // assert (currentNodeIndex >= 0);
    // assert (currentNodeZ < isometric.totalZ);
    // assert (row < isometric.totalRows);
    // assert (column < isometric.totalColumns);
    // assert (currentNodeIndex < isometric.totalNodes);
    // currentNodeDstX = (row - column) * Node_Size_Half;
    // currentNodeDstY = ((row + column) * Node_Size_Half) - (currentNodeZ * Node_Height);
    // currentNodeType = isometric.nodeTypes[currentNodeIndex];
    // // orderZ = currentNodeZ;
    // order = (row + column).toDouble() - 0.5;
  }

  @override
  int getTotal() => atlasNodesLoaded ? scene.totalNodes : 0;

  @override
  void reset() {
    ambientColor = isometric.scene.ambientColor;
    nodeColors = scene.nodeColors;
    totalNodes = scene.totalNodes;
    totalRows = scene.totalRows;
    totalColumns = scene.totalColumns;
    totalZ = scene.totalZ;
    highResolution = !dynamicResolutionEnabled || engine.zoom >= 0.8;
    nodeScale = highResolution ? 1.0 : 1.5;
    nodeSize = Node_Size / nodeScale;
    nodeSideTopSrcX = highResolution ? 0.0 : 128.0;
    nodeSideWestSrcX = highResolution ? 49.0 : 161.0;


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
    playerZ = isometric.player.position.indexZ;
    playerRow = isometric.player.position.indexRow;
    playerColumn = isometric.player.position.indexColumn;
    nodesPlayerColumnRow = playerRow + playerColumn;
    playerRenderRow = playerRow - (isometric.player.position.indexZ ~/ 2);
    playerRenderColumn = playerColumn - (isometric.player.position.indexZ ~/ 2);
    playerProjection = playerIndex % scene.projection;
    scene.offscreenNodes = 0;
    scene.onscreenNodes = 0;

    screenRight = engine.Screen_Right + Node_Size;
    screenLeft = engine.Screen_Left - Node_Size;
    screenTop = engine.Screen_Top - 72;
    screenBottom = engine.Screen_Bottom + 72;
    var screenTopLeftColumn = convertWorldToColumn(screenLeft, screenTop, 0);
    nodesScreenBottomRightRow = clamp(convertWorldToRow(screenRight, screenBottom, 0), 0, scene.totalRows - 1);
    nodesScreenTopLeftRow = convertWorldToRow(screenLeft, screenTop, 0);

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
    isometric.scene.applyEmissions();

    // highlightCharacterNearMouse();
  }

  void increaseOrderShiftY(){
    orderShiftY++;
  }

  void decreaseOrderShiftY(){
    orderShiftY--;
  }

  void toggleDynamicResolutionEnabled(){
    dynamicResolutionEnabled = !dynamicResolutionEnabled;
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

    final height = scene.heightMap[isometric.player.areaNodeIndex];

    if (isometric.player.indexZ <= 0) {
      zMin = 0;
      isometric.player.playerInsideIsland = false;
      return;
    }

    isometric.player.playerInsideIsland = isometric.player.indexZ < height;

    if (!isometric.player.playerInsideIsland) {
      ensureIndexPerceptible(isometric.player.nodeIndex);
    }

    if (isometric.mouse.inBounds){
      ensureIndexPerceptible(isometric.mouse.nodeIndex);
    }

    zMin = max(isometric.player.indexZ - 1, 0);
    visit2D(isometric.player.areaNodeIndex);
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
      isometric.player.playerInsideIsland = true;
      zMin = max(isometric.player.indexZ - 1, 0);
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

     var searchIndex = i + (scene.area * isometric.player.indexZ);
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
     searchIndex = i + (scene.area * isometric.player.indexZ);
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
      if (nodesMinZ >= scene.totalZ){
        isometric.compositor.rendererNodes.remaining = false;
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

    final frame = (row + (isometric.animation.frame)) % 6;
    const Flame_Src_Y = 372.0;
    const Flame_Width = 32.0;
    const Flame_Height = 32.0;

    engine.renderSprite(
      image: isometric.images.atlas_nodes,
      srcX: 1247.0 + (frame * Flame_Width),
      srcY: wind == WindType.Calm ? Flame_Src_Y : Flame_Src_Y + Flame_Height,
      srcWidth: Flame_Width,
      srcHeight: Flame_Height,
      dstX: dstX,
      dstY: dstY + 8,
      anchorY: AtlasNodeAnchorY.Torch,
      color: 0,
    );
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

    // assert (isometric.indexOnscreen(currentNodeIndex));
    // assert((){}())
    // if (isometric.indexOnscreen(currentNodeIndex)) {
    //   onscreenNodes++;
    // } else {
    //   offscreenNodes++;
    // }

    if (currentNodeWithinIsland && currentNodeZ >= playerZ + 2) return;

    final transparent = currentNodeTransparent;
    if (previousNodeTransparent != transparent) {
      previousNodeTransparent = transparent;
      engine.bufferImage = transparent ? isometric.images.atlas_nodes_transparent : isometric.images.atlas_nodes;
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
            srcX: 1343 + (isometric.animation.frame6 * 16),
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
            srcX: 1343 + (isometric.animation.frame6 * 16),
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
        if (currentNodeOrientation == NodeOrientation.Destroyed) return;
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
      case NodeType.Spawn:
        if (isometric.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_X,
          srcY: AtlasNode.Spawn_Y,
        );
        break;
      case NodeType.Spawn_Weapon:
        if (isometric.playMode) return;
        renderStandardNode(
          srcX: AtlasNode.Spawn_Weapon_X,
          srcY: AtlasNode.Spawn_Weapon_Y,
        );
        break;
      case NodeType.Spawn_Player:
        if (isometric.playMode) return;
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

  void renderFireplace() => engine.renderSprite(
      image: atlasNodes,
      srcX: AtlasNode.Src_Fireplace_X,
      srcY: AtlasNode.Src_Fireplace_Y + (isometric.animation.frame6 * AtlasNode.Src_Fireplace_Height),
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
    if (currentNodeOrientation == NodeOrientation.Destroyed)
      return;

    final frame = wind == WindType.Calm
        ? 0
        : (((row - column) + isometric.animation.frame6) % 6);
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
        srcY: 72.0 * ((isometric.animation.frame + row + column) % 8), // TODO Expensive Operation
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + isometric.animation.frameWaterHeight + 14,
        anchorY: 0.3,
        color: colorCurrent,
      );
      return;
    }
    renderStandardNode(
      srcX: isometric.srcXRainLanding,
      srcY: 72.0 * ((isometric.animation.frame + row + column) % 6), // TODO Expensive Operation
    );
  }

  void renderNodeRainFalling() {
    renderStandardNode(
      srcX: isometric.srcXRainFalling,
      srcY: 72.0 * ((isometric.animation.frame + row + row + column) % 6), // TODO Expensive Operation
    );
  }

  void renderTreeTop() => renderNodeBelowVariation == 0 ? renderTreeTopPine() : renderTreeTopOak();

  void renderTreeBottom() => currentNodeVariation == 0 ? renderTreeBottomPine() : renderTreeBottomOak();

  void renderTreeTopOak(){
    final animation = isometric.animation;
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

    final animation = isometric.animation;
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

    final animation = isometric.animation;
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
    final animation = isometric.animation;
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
        srcY: 432 + (isometric.animation.frame6 * 72.0), // TODO Optimize
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
        srcY: AtlasNodeY.Water + (((isometric.animation.frameWater + ((row + column) * 3)) % 10) * 72.0), // TODO Optimize
        srcWidth: IsometricConstants.Sprite_Width,
        srcHeight: IsometricConstants.Sprite_Height,
        dstX: currentNodeDstX,
        dstY: currentNodeDstY + isometric.animation.frameWaterHeight + 14,
        anchorY: 0.3334,
        color: colorCurrent,
      );

  void renderStandardNode({
    required double srcX,
    required double srcY,
  }){
    onscreenNodes++;
    final f = engine.bufferIndex * 4;
    bufferClr[engine.bufferIndex] = colorCurrent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + IsometricConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + IsometricConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (IsometricConstants.Sprite_Width_Half);
    bufferDst[f + 3] = currentNodeDstY - (IsometricConstants.Sprite_Height_Third);
    engine.incrementBufferIndex();
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

  void renderCustomNode({
    required double srcX,
    required double srcY,
    required double srcWidth,
    required double srcHeight,
    required double dstX,
    required double dstY,
    required int color,
    double scale = 1.0,
  }){
    final f = engine.bufferIndex * 4;
    bufferClr[engine.bufferIndex] = color;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + srcWidth;
    bufferSrc[f + 3] = srcY + srcHeight;
    bufferDst[f] = scale; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = dstX;
    bufferDst[f + 3] = dstY;
    engine.incrementBufferIndex();
  }

  void someMethod(int i, Float32List bufferSrc){
    bufferSrc[i] = 0;
    bufferSrc[i + 1] = 10;
    bufferSrc[i + 2] = 20;
    bufferSrc[i + 3] = 20;
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
    bufferClr[engine.bufferIndex] = color ?? colorCurrent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + (srcWidth ?? IsometricConstants.Sprite_Width);
    bufferSrc[f + 3] = srcY + (srcHeight ?? IsometricConstants.Sprite_Height);
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (IsometricConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (IsometricConstants.Sprite_Height_Third) + offsetY;
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
    bufferClr[engine.bufferIndex] = colorCurrent;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + IsometricConstants.Sprite_Width;
    bufferSrc[f + 3] = srcY + IsometricConstants.Sprite_Height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - (IsometricConstants.Sprite_Width_Half) + offsetX;
    bufferDst[f + 3] = currentNodeDstY - (IsometricConstants.Sprite_Height_Third) + offsetY;
    engine.incrementBufferIndex();
  }

  void renderCellTop({
    required double dstX,
    required double dstY,
    required int color,
  }) {
    final bufferIndex = engine.bufferIndex;
    final f = bufferIndex * 4;
    bufferClr[bufferIndex] = color;
    bufferSrc[f] = Src_X_Cell_Top;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = Src_X_Cell_Top + Src_Width_Cell_Top;
    bufferSrc[f + 3] = srcY + Src_Height_Cell_Top;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX + dstX;
    bufferDst[f + 3] = currentNodeDstY + dstY;
    incrementBufferIndex();
  }

  void renderCellWest({
    required double dstX,
    required double dstY,
    required int color,
  }) {
    final _srcY = srcY + Src_Y_Cell_West;
    final bufferIndex = engine.bufferIndex;
    final f = bufferIndex * 4;
    bufferClr[bufferIndex] = color;
    bufferSrc[f] = Src_X_Cell_West;
    bufferSrc[f + 1] = _srcY;
    bufferSrc[f + 2] = Src_X_Cell_West + Src_Width_Cell_West;
    bufferSrc[f + 3] = _srcY + Src_Height_Cell_West;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX + dstX;
    bufferDst[f + 3] = currentNodeDstY + dstY;
    incrementBufferIndex();
  }

  void renderCellSouth({
    required double dstX,
    required double dstY,
    required int color,
  }) {
    final bufferIndex = engine.bufferIndex;
    final f = bufferIndex * 4;
    final _srcY = srcY + Src_Y_Cell_South;

    bufferClr[bufferIndex] = color;
    bufferSrc[f] = Src_X_Cell_South;
    bufferSrc[f + 1] = _srcY;
    bufferSrc[f + 2] = Src_X_Cell_South + Src_Width_Cell_South;
    bufferSrc[f + 3] = _srcY + Src_Height_Cell_South;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX + dstX;
    bufferDst[f + 3] = currentNodeDstY + dstY;
    incrementBufferIndex();
  }

  void renderNodeSideTop() {

    final srcX = currentNodeVariation == 0 ? 0.0 : 128.0;
    final bufferIndex = engine.bufferIndex;
    final f = bufferIndex * 4;
    bufferClr[bufferIndex] = colorAbove;
    bufferSrc[f] = srcX;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = srcX + Src_Width_Side_Top;
    bufferSrc[f + 3] = srcY + Src_Height_Side_Top;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX - Node_Size_Half;
    bufferDst[f + 3] = currentNodeDstY - Node_Size_Half;
    incrementBufferIndex();
  }

  void renderNodeSideWest({
    required int color,
    double dstX = 0,
    double dstY = 0,
    double width = Src_Width_Side_West,
    double height = Src_Height_Side_West,
  }) {
    final bufferIndex = engine.bufferIndex;
    final f = bufferIndex * 4;
    bufferClr[bufferIndex] = color;
    bufferSrc[f] = Src_X_Side_West;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = Src_X_Side_West + width;
    bufferSrc[f + 3] = srcY + height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX + dstX;
    bufferDst[f + 3] = currentNodeDstY + dstY;
    incrementBufferIndex();
  }

  void renderNodeSideSouth({
    required double dstX,
    required double dstY,
    required int color,
    double width = Src_Width_Side_South,
    double height = Src_Height_Side_South,
  }) {
    final bufferIndex = engine.bufferIndex;
    final f = bufferIndex * 4;
    bufferClr[bufferIndex] = color;
    bufferSrc[f] = Src_X_Side_South;
    bufferSrc[f + 1] = srcY;
    bufferSrc[f + 2] = Src_X_Side_South + width;
    bufferSrc[f + 3] = srcY + height;
    bufferDst[f] = 1.0; // scale
    bufferDst[f + 1] = 0;
    bufferDst[f + 2] = currentNodeDstX + dstX;
    bufferDst[f + 3] = currentNodeDstY + dstY;
    incrementBufferIndex();
  }
}
