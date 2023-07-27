
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../isometric/classes/position.dart';

mixin IsometricScene {

  var ambientResetIndex = 0;
  var emissionAlphaCharacter = 50;

  var ambientColorRGB = Color.fromRGBO(31, 1, 86, 0.5);
  var ambientColor = 0;

  var nodesLightSources = Uint16List(1000);
  var nodesLightSourcesTotal = 0;
  var nodeColors = Uint32List(0);
  var hsvHue = Uint16List(0);
  var hsvSaturation = Uint8ClampedList(0);
  var hsvValues = Uint8ClampedList(0);
  var hsvAlphas = Uint8ClampedList(0);
  var nodeOrientations = Uint8List(0);
  var nodeTypes = Uint8List(0);
  var nodeVariations = Uint8List(0);
  var colorStack = Uint16List(0);
  var ambientStack = Uint16List(0);
  var miniMap = Uint8List(0);
  var heightMap = Uint16List(0);
  var colorStackIndex = -1;
  var ambientStackIndex = -1;
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
  var torchEmissionIntensity = 1.0;

  late var ambientColorHSV = HSVColor.fromColor(ambientColorRGB);
  late var ambientHue = ((ambientColorHSV.hue)).round();
  late var ambientSaturation = (ambientColorHSV.saturation * 100).round();
  late var ambientValue = (ambientColorHSV.value * 100).round();
  late var _ambientAlpha = (ambientColorHSV.alpha * 255).round();
  late var interpolationLength = 6;

  final nodesChangedNotifier = Watch(0);

  int get ambientAlpha => _ambientAlpha;

  set ambientAlpha(int value){
     final clampedValue = clamp(value, 0, 255);

     if (clampedValue == _ambientAlpha)
       return;

     _ambientAlpha = clampedValue;
     ambientResetIndex = 0;

     ambientColor = hsvToColor(
         hue: ambientHue,
         saturation: ambientSaturation,
         value: ambientValue,
         opacity: ambientAlpha
     );
  }

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
    hsvHue = Uint16List(totalNodes);
    hsvSaturation = Uint8ClampedList(totalNodes);
    hsvValues = Uint8ClampedList(totalNodes);
    hsvAlphas = Uint8ClampedList(totalNodes);
  }

  void resetNodeColorsToAmbient() {
    print('isometric_scene.resetNodeColorsToAmbient() - EXPENSIVE CALL');
    ambientResetIndex = 0;
    colorStackIndex = -1;

    if (nodeColors.length != totalNodes) {
      generateStacks();
    }
    for (var i = 0; i < totalNodes; i++) {
      nodeColors[i] = ambientColor;
      hsvHue[i] = ambientHue;
      hsvSaturation[i] = ambientSaturation;
      hsvValues[i] = ambientValue;
      hsvAlphas[i] = _ambientAlpha;
    }
  }

  void jobBatchResetNodeColorsToAmbient() {

    if (ambientResetIndex >= totalNodes)
      return;

    const ambientResetBatchSize = 1000;
    final targetEnd = ambientResetIndex + ambientResetBatchSize;
    final end = min(targetEnd, totalNodes);

    nodeColors.fillRange(ambientResetIndex, end, ambientColor);
    hsvHue.fillRange(ambientResetIndex, end, ambientHue);
    hsvSaturation.fillRange(ambientResetIndex, end, ambientSaturation);
    hsvValues.fillRange(ambientResetIndex, end, ambientValue);
    hsvAlphas.fillRange(ambientResetIndex, end, _ambientAlpha);
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
      hsvHue[i] = ambientHue;
      hsvSaturation[i] = ambientSaturation;
      hsvValues[i] = ambientValue;
      hsvAlphas[i] = _ambientAlpha;
      colorStackIndex--;
    }
    colorStackIndex = -1;
  }

  void resetNodeAmbientStack() {
    while (ambientStackIndex >= 0) {
      final i = ambientStack[ambientStackIndex];
      nodeColors[i] = ambientColor;
      hsvAlphas[i] = _ambientAlpha;
      ambientStackIndex--;
    }
    ambientStackIndex = -1;
  }

  void refreshNodeColor(int index) =>
      nodeColors[index] = hsvToColor(
        hue: hsvHue[index],
        saturation: hsvSaturation[index],
        value: hsvValues[index],
        opacity: hsvAlphas[index],
      );

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
    if (nodeVariations.length < totalNodes) {
      nodeVariations = Uint8List(totalNodes);
    }
    assert (nodeTypes.length == totalNodes);
    for (var i = 0; i < totalNodes; i++){
      final nodeType = nodeTypes[i];
      switch (nodeType) {
        case NodeType.Grass:
          nodeVariations[i] = randomInt(0, 4);
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
      IsometricRender.getRenderXOfRowAndColumn(
          getIndexRow(index),
          getIndexColumn(index),
      );

  double getIndexRenderY(int index) =>
      IsometricRender.getRenderYOfRowColumnZ(getIndexRow(index), getIndexColumn(index), getIndexZ(index));


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

  void refreshLightSources() {
    nodesLightSourcesTotal = 0;
    for (var i = 0; i < totalNodes; i++){
      if (!NodeType.emitsLight(nodeTypes[i])) continue;
      if (nodesLightSourcesTotal >= nodesLightSources.length) {
        nodesLightSources = Uint16List(nodesLightSources.length + 100);
        refreshLightSources();
        return;
      }
      nodesLightSources[nodesLightSourcesTotal] = i;
      nodesLightSourcesTotal++;
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

     for (var i = 0; i < nodesLightSourcesTotal; i++){
       final lightSourceIndex = nodesLightSources[i];
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

}



