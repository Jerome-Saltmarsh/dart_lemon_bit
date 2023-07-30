
import 'dart:math';
import 'dart:ui';

import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../isometric/classes/position.dart';

class IsometricScene {

  var _ambientAlpha = 0;

  int get ambientAlpha => _ambientAlpha;

  set ambientAlpha(int value){
    final clampedValue = value.clamp(0, 255);

    if (clampedValue == _ambientAlpha)
      return;

    ambientResetIndex = 0;
    _ambientAlpha = clampedValue;
    ambientColor = setAlpha(color: ambientColor, alpha: clampedValue);
  }

  late var ambientRGB = getRGB(ambientColor);
  var ambientColor = Color.fromRGBO(31, 1, 86, 0.5).value;
  var ambientResetIndex = 0;
  var ambientStack = Uint16List(0);
  var ambientStackIndex = -1;

  var colorStack = Uint16List(0);
  var colorStackIndex = -1;

  /// contains a list of indexes of nodes which emit smoke
  /// for example a fireplace
  var smokeSources = Uint16List(500);
  var smokeSourcesTotal = 0;
  var nodeLightSources = Uint16List(1000);
  var nodeLightSourcesTotal = 0;
  var nodeColors = Uint32List(0);
  var nodeOrientations = Uint8List(0);
  var nodeTypes = Uint8List(0);
  var nodeVariations = Uint8List(0);
  var miniMap = Uint8List(0);
  var heightMap = Uint16List(0);
  var totalNodes = 0;
  var area = 0;
  var area2 = 0;
  var projection = 0;
  var projectionHalf = 0;
  var totalZ = 0;
  var totalRows = 0;
  var totalColumns = 0;
  var lengthRows = 0.0;
  var lengthColumns = 0.0;
  var lengthZ = 0.0;
  var offscreenNodes = 0;
  var onscreenNodes = 0;

  late var interpolationLength = 6;

  final nodesChangedNotifier = Watch(0);


  late final Watch<EaseType> interpolationEaseType = Watch(EaseType.In_Quad, onChanged: (EaseType easeType){
    interpolations = interpolateEaseType(
      length: interpolationLength,
      easeType: EaseType.In_Out_Quad,
    );
  });

  late var interpolations = interpolateEaseType(
    length: interpolationLength,
    easeType: interpolationEaseType.value,
  );

  void setInterpolationLength(int value){
    if (value < 1) return;
    if (interpolationLength == value) return;
    interpolationLength = value;
    interpolations = interpolateEaseType(
      length: interpolationLength,
      easeType: interpolationEaseType.value,
    );
  }

  // FUNCTIONS


  void rainStart(){
    final rows = totalRows;
    final columns = totalColumns;
    final zs = totalZ - 1;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        for (var z = zs; z >= 0; z--) {
          final index = getIndexZRC(z, row, column);
          final type = nodeTypes[index];
          if (type != NodeType.Empty) {
            if (type == NodeType.Water || nodeOrientations[index] == NodeOrientation.Solid) {
              setNodeType(z + 1, row, column, NodeType.Rain_Landing);
            }
            setNodeType(z + 2, row, column, NodeType.Rain_Falling);
            break;
          }
          if (
          column == 0 ||
              row == 0 ||
              !gridNodeZRCTypeRainOrEmpty(z, row - 1, column) ||
              !gridNodeZRCTypeRainOrEmpty(z, row, column - 1)
          ){
            setNodeType(z, row, column, NodeType.Rain_Falling);
          }
        }
      }
    }
  }

  void rainStop() {
    for (var i = 0; i < totalNodes; i++) {
      if (!NodeType.isRain(nodeTypes[i])) continue;
      nodeTypes[i] = NodeType.Empty;
      nodeOrientations[i] = NodeOrientation.None;
    }
  }

  void generateStacks(){
    print('isometric_scene.generateStacks() - EXPENSIVE CALL');
    colorStack = Uint16List(totalNodes);
    nodeColors = Uint32List(totalNodes);
  }

  void resetNodeColorsToAmbient() {
    print('isometric_scene.resetNodeColorsToAmbient() - EXPENSIVE CALL');
    ambientResetIndex = 0;
    colorStackIndex = -1;

    if (nodeColors.length != totalNodes) {
      generateStacks();
    }

    final cacheAmbient = ambientColor;
    for (var i = 0; i < totalNodes; i++) {
      nodeColors[i] = cacheAmbient;
    }
  }

  void update(){
    jobBatchResetNodeColorsToAmbient();
  }

  void jobBatchResetNodeColorsToAmbient() {

    if (ambientResetIndex >= totalNodes)
      return;

    const ambientResetBatchSize = 5000;
    final targetEnd = ambientResetIndex + ambientResetBatchSize;
    final end = min(targetEnd, totalNodes);
    nodeColors.fillRange(ambientResetIndex, end, ambientColor);
    ambientResetIndex += ambientResetBatchSize;
  }

  int getHeightAt(int row, int column){
    var i = totalNodes - area + ((row * totalColumns) + column);
    for (var z = totalZ - 1; z >= 0; z--){
      if (nodeOrientations[i] != NodeOrientation.None) return z;
      i -= area;
    }
    return 0;
  }

  void generateHeightMap() {
    if (heightMap.length != area) {
      heightMap = Uint16List(area);
    }
    for (var row = 0; row < totalRows; row++) {
      final rowIndex = row * totalColumns;
      for (var column = 0; column < totalColumns; column++) {
        heightMap[rowIndex + column] = getHeightAt(row, column);
      }
    }
  }

  void generateMiniMap(){
    if (miniMap.length != area){
      miniMap = Uint8List(area);
    }

    var index = 0;
    for (var row = 0; row < totalRows; row++){
      for (var column = 0; column < totalColumns; column++){
        var searchIndex = totalNodes - area +  index;
        var typeFound = NodeType.Empty;
        while (true) {
          if (searchIndex < 0) break;
          final type = nodeTypes[searchIndex];
          searchIndex -= area;
          if (NodeType.isRainOrEmpty(type)) continue;
          typeFound = type;
          break;
        }
        miniMap[index] = typeFound;
        index++;
      }
    }
  }

  void resetNodeColorStack() {
    while (colorStackIndex >= 0) {
      final i = colorStack[colorStackIndex];
      nodeColors[i] = ambientColor;
      colorStackIndex--;
    }
    colorStackIndex = -1;
  }

  void resetNodeAmbientStack() {
    while (ambientStackIndex >= 0) {
      final i = ambientStack[ambientStackIndex];
      nodeColors[i] = ambientColor;
      ambientStackIndex--;
    }
    ambientStackIndex = -1;
  }

  int getTorchIndex(int nodeIndex){
    final initialSearchIndex = nodeIndex - totalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;
    var rowIndex = 0;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + rowIndex + column;
        if (searchIndex >= totalNodes) break;
        if (nodeTypes[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
      rowIndex += totalColumns;
    }
    return torchIndex;
  }

  void refreshGridMetrics(){
    lengthRows = totalRows * Node_Size;
    lengthColumns = totalColumns * Node_Size;
    lengthZ = totalZ * Node_Height;
  }

  void refreshNodeVariations() {
    print('scene.refreshNodeVariations()');
    if (nodeVariations.length < totalNodes) {
      nodeVariations = Uint8List(totalNodes);
    }
    assert (nodeTypes.length == totalNodes);
    for (var i = 0; i < totalNodes; i++){
      final nodeType = nodeTypes[i];
      switch (nodeType) {
        case NodeType.Grass:
          nodeVariations[i] = randomInt(0, 2);
          break;
        case NodeType.Shopping_Shelf:
          nodeVariations[i] = randomInt(0, 2);
          break;
        case NodeType.Tree_Bottom:
          nodeVariations[i] = randomInt(0, 2);
          break;
      }
    }
  }

  int getIndexRow(int index) => (index % area) ~/ totalColumns;

  int getIndexZ(int index) => index ~/ area;

  int getIndexColumn(int index) => index % totalColumns;


  bool isValidIndex(int index) => index >= 0 && index < totalNodes;

  double getIndexRenderX(int index) =>
      getRenderXOfRowAndColumn(
          getIndexRow(index),
          getIndexColumn(index),
      );

  double getIndexRenderY(int index) =>
      getRenderYOfRowColumnZ(getIndexRow(index), getIndexColumn(index), getIndexZ(index));


  bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
      NodeType.isRainOrEmpty(getTypeZRC(z, row, column));

  bool nodeOrientationBlocksNorthSouth(int nodeOrientation) => const [
    NodeOrientation.Solid,
    NodeOrientation.Half_North,
    NodeOrientation.Half_South,
    NodeOrientation.Slope_North,
    NodeOrientation.Slope_South,
    NodeOrientation.Corner_North_East,
    NodeOrientation.Corner_South_East,
    NodeOrientation.Corner_South_West,
    NodeOrientation.Corner_North_West,
  ].contains(nodeOrientation);

  bool nodeOrientationBlocksNorthSouthPos(int nodeOrientation) => const [
    NodeOrientation.Solid,
    NodeOrientation.Half_North,
    NodeOrientation.Half_South,
    NodeOrientation.Slope_North,
    NodeOrientation.Slope_South,
    NodeOrientation.Corner_North_East,
    NodeOrientation.Corner_South_East,
    NodeOrientation.Corner_South_West,
    NodeOrientation.Corner_North_West,
  ].contains(nodeOrientation);

  bool nodeOrientationBlocksEastWest(int value) => const [
    NodeOrientation.Solid,
    NodeOrientation.Half_East,
    NodeOrientation.Half_West,
    NodeOrientation.Slope_East,
    NodeOrientation.Slope_West,
    NodeOrientation.Corner_North_East,
    NodeOrientation.Corner_South_East,
    NodeOrientation.Corner_South_West,
    NodeOrientation.Corner_North_West,
  ].contains(value);

  bool isNodeTypeTransparent(int nodeType) => const [
    NodeType.Empty,
    NodeType.Rain_Landing,
    NodeType.Rain_Falling,
    NodeType.Window,
    NodeType.Wooden_Plank,
    NodeType.Torch,
    NodeType.Grass_Long,
    NodeType.Tree_Bottom,
    NodeType.Tree_Top,
  ].contains(nodeType);

  bool nodeOrientationBlocksVertical(int nodeOrientation) => (const [
    NodeOrientation.Solid,
    NodeOrientation.Half_Vertical_Top,
    NodeOrientation.Half_Vertical_Center,
    NodeOrientation.Half_Vertical_Bottom,
  ]).contains(nodeOrientation);

  bool nodeOrientationBlocksVerticalDown(int nodeOrientation) => (const [
    NodeOrientation.Solid,
    NodeOrientation.Half_Vertical_Top,
    NodeOrientation.Half_Vertical_Center,
    NodeOrientation.Half_Vertical_Bottom,
  ]).contains(nodeOrientation);

  int getProjectionIndex(int nodeIndex) => nodeIndex % projection;

  int getTypeBelow(int index){
    if (index < area) return NodeType.Boundary;
    final indexBelow = index - area;
    if (indexBelow >= totalNodes) return NodeType.Boundary;
    return nodeTypes[indexBelow];
  }

  int getIndexBelow(int index) => index - area;

  int getIndexBelowPosition(Position position) =>
      getIndexZRC(
        position.indexZ - 1,
        position.indexRow,
        position.indexColumn,
      );

  void setNodeType(int z, int row, int column, int type){
    if (z < 0)
      return;
    if (row < 0)
      return;
    if (column < 0)
      return;
    if (z >= totalZ)
      return;
    if (row >= totalRows)
      return;
    if (column >= totalColumns)
      return;

    nodeTypes[getIndexZRC(z, row, column)] = type;
  }

  int convertNodeIndexToIndexY(int index) =>
      index -
      ((convertNodeIndexToIndexZ(index) * area) +
          (convertNodeIndexToIndexX(index) * totalColumns));

  int convertNodeIndexToIndexX(int index) =>
      (index - ((index ~/ area) * area)) ~/ totalColumns;

  int convertNodeIndexToIndexZ(int index) =>
      index ~/ area;

  int getRenderColorPosition(Position position) =>
      outOfBoundsPosition(position)
          ? ambientColor
          : nodeColors[getIndexPosition(position)];

  void refreshSmokeSources(){
    print('scene.refreshSmokeSources()');
    smokeSourcesTotal = 0;
    for (var i = 0; i < totalNodes; i++){
      if (!const [
        NodeType.Fireplace
      ].contains(nodeTypes[i]))
        continue;
      smokeSources[smokeSourcesTotal] = i;
      smokeSourcesTotal++;

      if (smokeSourcesTotal >= smokeSources.length)
        return;
    }
  }

  void refreshLightSources() {
    print('scene.refreshLightSources()');
    nodeLightSourcesTotal = 0;
    for (var i = 0; i < totalNodes; i++){
      if (!const [
        NodeType.Torch,
        NodeType.Torch_Blue,
        NodeType.Torch_Red,
        NodeType.Fireplace
      ].contains(nodeTypes[i]))
        continue;
      nodeLightSources[nodeLightSourcesTotal] = i;
      nodeLightSourcesTotal++;

      if (nodeLightSourcesTotal >= nodeLightSources.length)
        return;
    }
  }

  bool outOfBoundsPosition(Position position) =>
      outOfBoundsXYZ(position.x, position.y, position.z);

  int getTypeXYZSafe(double x, double y, double z) =>
      inBoundsXYZ(x, y, z) ? getTypeXYZ(x, y, z) : NodeType.Boundary;

  int getTypeXYZ(double x, double y, double z) =>
      nodeTypes[getIndexXYZ(x, y, z)];

  bool inBoundsPosition(Position position) =>
      inBoundsXYZ(position.x, position.y, position.z);

  bool inBoundsXYZ(double x, double y, double z) =>
      x >= 0 &&
          y >= 0 &&
          z >= 0 &&
          x < lengthRows &&
          y < lengthColumns &&
          z < lengthZ;


  bool inBoundsZRC(int z, int row, int column) =>
      z >= 0 &&
          z < totalZ &&
          row >= 0 &&
          row < totalRows &&
          column >= 0 &&
          column < totalColumns;


  int getIndexPosition(Position position) =>
      getIndexZRC(
        position.indexZ,
        position.indexRow,
        position.indexColumn,
      );

  int getIndexXYZ(double x, double y, double z) =>
      getIndexZRC(
        z ~/ Node_Size_Half,
        x ~/ Node_Size,
        y ~/ Node_Size,
      );

  int getTypeZRC(int z, int row, int column) =>
      nodeTypes[getIndexZRC(z, row, column)];

  int getIndexZRC(int z, int row, int column) =>
      (z * area) + (row * totalColumns) + column;

  bool outOfBoundsXYZ(double x, double y, double z) =>
      z < 0 ||
      y < 0 ||
      z < 0 ||
      z >= lengthZ ||
      x >= lengthRows ||
      y >= lengthColumns;

  int getNearestLightSourcePosition(Position position, {int maxDistance = 5}) => getNearestLightSource(
        row: position.indexRow,
        column: position.indexColumn,
        z: position.indexZ,
        maxDistance: maxDistance,
    );

  int getNearestLightSource({
    required int row,
    required int column,
    required int z,
    int maxDistance = 5,
  }) {
     var nearestLightSourceIndex = -1;
     var nearestLightSourceDistance = maxDistance;

     for (var i = 0; i < nodeLightSourcesTotal; i++){
       final lightSourceIndex = nodeLightSources[i];
       final lightSourceRow = getIndexRow(lightSourceIndex);
       final lightSourceColumn = getIndexColumn(lightSourceIndex);
       final lightSourceZ = getIndexZ(lightSourceIndex);

       final distance =
           (row - lightSourceRow).abs() +
           (column - lightSourceColumn).abs()  +
           (z - lightSourceZ).abs();

       if (distance > nearestLightSourceDistance)
         continue;

       nearestLightSourceDistance = distance;
       nearestLightSourceIndex = lightSourceIndex;
     }

    return nearestLightSourceIndex;
  }

  int getNodeColorAtIndex(int index )=>
      index < 0 || index >= totalNodes ? ambientColor : nodeColors[index];

  double getIndexPositionX(int index) =>
      (getIndexRow(index) * Node_Size) + Node_Size_Half;

  double getIndexPositionY(int index) =>
      (getIndexColumn(index) * Node_Size) + Node_Size_Half;

  double getIndexPositionZ(int index) =>
      (getIndexZ(index) * Node_Height) + Node_Height_Half;

  void applyColor({
    required int index,
    required double intensity,
    required int color,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final ambientIntensity = intensity * (ambientAlpha / 255);

    final currentColor = nodeColors[index];
    final currentRed = getRed(currentColor);
    final currentGreen = getGreen(currentColor);
    final currentBlue = getBlue(currentColor);
    final currentAlpha = getAlpha(currentColor);

    final colorRed = getRed(color);
    final colorGreen = getGreen(color);
    final colorBlue = getBlue(color);
    final colorAlpha = interpolateByte(0, getAlpha(color), ambientIntensity);

    final interpolatedRed = interpolateByte(currentRed, colorRed, ambientIntensity);
    final interpolatedGreen = interpolateByte(currentGreen, colorGreen, ambientIntensity);
    final interpolatedBlue = interpolateByte(currentBlue, colorBlue, ambientIntensity);
    final interpolatedAlpha = interpolateByte(currentAlpha, colorAlpha, ambientIntensity);

    colorStackIndex++;
    colorStack[colorStackIndex] = index;
    nodeColors[index] = aRGBToColor(
      interpolatedAlpha,
      interpolatedRed,
      interpolatedGreen,
      interpolatedBlue,
    );
  }


  void applyAmbient({
    required int index,
    required int alpha,
  }){
    assert (index >= 0);
    assert (index < totalNodes);

    final currentColor = nodeColors[index];
    final currentAlpha = getAlpha(currentColor);
    if (currentAlpha <= alpha) {
      return;
    }

    final currentRGB = getRGB(currentColor);
    if (currentRGB != ambientRGB){
      final currentIntensity = (ambientAlpha - currentAlpha) / 128;
      final alphaBlend = 1.0 - currentIntensity;
      alpha = interpolate(currentAlpha, alpha, alphaBlend).toInt();
    }

    ambientStackIndex++;
    ambientStack[ambientStackIndex] = index;
    nodeColors[index] = setAlpha(color: currentColor, alpha: alpha);
  }
}



