
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/library.dart';

import '../classes/isometric_position.dart';

mixin IsometricScene {

  var emissionAlphaCharacter = 50;
  var dynamicShadows = true;

  var ambientColorRGB  = Color.fromRGBO(31, 1, 86, 0.5);
  late var ambientColorHSV  = HSVColor.fromColor(ambientColorRGB);
  late var ambientHue        = ((ambientColorHSV.hue)).round();
  late var ambientSaturation        = (ambientColorHSV.saturation * 100).round();
  late var ambientValue        = (ambientColorHSV.value * 100).round();
  late var ambientAlpha        = (ambientColorHSV.alpha * 255).round();
  var ambientColor      = 0;

  var nodesLightSources = Uint16List(0);
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
  var torch_emission_intensity = 1.0;

  final nodesChangedNotifier = Watch(0);
  final shadow = IsometricPosition();
  late var interpolationLength = 6;

  late final Watch<EaseType> interpolationEaseType = Watch(EaseType.Out_Quad, onChanged: (EaseType easeType){
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

  void resetNodeColorsToAmbient() {
    ambientAlpha = clamp(ambientAlpha, 0, 255);
    ambientColor = hsvToColor(
        hue: ambientHue,
        saturation: ambientSaturation,
        value: ambientValue,
        opacity: ambientAlpha
    );
    colorStackIndex = -1;

    if (nodeColors.length != totalNodes) {
      colorStack = Uint16List(totalNodes);
      nodeColors = Uint32List(totalNodes);
      hsvHue = Uint16List(totalNodes);
      hsvSaturation = Uint8ClampedList(totalNodes);
      hsvValues = Uint8ClampedList(totalNodes);
      hsvAlphas = Uint8ClampedList(totalNodes);
    }
    for (var i = 0; i < totalNodes; i++) {
      nodeColors[i] = ambientColor;
      hsvHue[i] = ambientHue;
      hsvSaturation[i] = ambientSaturation;
      hsvValues[i] = ambientValue;
      hsvAlphas[i] = ambientAlpha;
    }
  }

  bool isPerceptiblePosition(IsometricPosition position) {
    if (!gamestream.player.playerInsideIsland)
      return true;
    if (outOfBoundsPosition(position))
      return false;

    final index = getIndexPosition(position);
    final indexRow = getIndexRow(index);
    final indexColumn = getIndexRow(index);
    final i = indexRow * totalColumns + indexColumn;
    // TODO REFACTOR
    if (!gamestream.renderer.rendererNodes.island[i])
      return true;
    final indexZ = getIndexZ(index);
    if (indexZ > gamestream.player.indexZ + 2)
      return false;

    // TODO REFACTOR
    return gamestream.renderer.rendererNodes.visible3D[index];
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
      hsvAlphas[i] = ambientAlpha;
      colorStackIndex--;
    }
    colorStackIndex = -1;
  }

  void resetNodeAmbientStack() {
    while (ambientStackIndex >= 0) {
      final i = ambientStack[ambientStackIndex];
      nodeColors[i] = ambientColor;
      hsvAlphas[i] = ambientAlpha;
      ambientStackIndex--;
    }
    ambientStackIndex = -1;
  }

  void emitLightAmbient({
    required int index,
    required int alpha,
  }){

    if (dynamicShadows) {
      emitLightAmbientShadows(
        index: index,
        alpha: alpha,
      );
      return;
    }

    if (index < 0) return;
    if (index >= totalNodes) return;

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ totalColumns;
    final columnIndex = convertNodeIndexToIndexY(index);
    final radius = 6;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, totalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, totalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, totalColumns);
    final rowInitInit = totalColumns * rowMin;
    var zTotal = zMin * area;

    const r = 4;
    final dstXLeft = IsometricRender.rowColumnZToRenderX(rowIndex + r, columnIndex - r);
    if (dstXLeft < gamestream.engine.Screen_Left)    return;
    final dstXRight = IsometricRender.rowColumnZToRenderX(rowIndex - r, columnIndex + r);
    if (dstXRight > gamestream.engine.Screen_Right)   return;
    final dstYTop = IsometricRender.rowColumnZToRenderY(rowIndex + r, columnIndex + r, zIndex);
    if (dstYTop <  gamestream.engine.Screen_Top) return;
    final dstYBottom = IsometricRender.rowColumnZToRenderY(rowIndex - r, columnIndex - r, zIndex);
    if (dstYBottom >  gamestream.engine.Screen_Bottom) return;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += totalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = clamp(b + (column - columnIndex).abs() - 2, 0, 6);
          if (distanceValue > 5) continue;
          ambientStackIndex++;
          ambientStack[ambientStackIndex] = nodeIndex;

          final intensity = 1.0 - interpolations[clamp(distanceValue, 0, 7)];
          final nodeAlpha = hsvAlphas[nodeIndex];
          if (nodeAlpha < alpha) continue;
          hsvAlphas[nodeIndex] = linearInterpolateInt(hsvAlphas[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  void refreshNodeColor(int index) =>
      nodeColors[index] = hsvToColor(
        hue: hsvHue[index],
        saturation: hsvSaturation[index],
        value: hsvValues[index],
        opacity: hsvAlphas[index],
      );


  void refreshNodeColor2(int index) =>
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

  void markShadow(IsometricPosition position){
    final index = getIndexPosition(position) - area;
    if (index < 0) return;
    if (index >= totalNodes) return;

    final indexRow = getIndexRow(index);
    final indexColumn = getIndexColumn(index);

    final vectorX = position.x;
    final vectorY = position.y;

    var vx = 0.0;
    var vy = 0.0;
    const r = 1;

    for (var row = -r; row <= r; row++) {
      final searchRow = indexRow + row;
      if (searchRow < 0) continue;
      if (searchRow >= totalRows) break;
      final rowAddition = index + (row * totalColumns);
      for (var column = -r; column <= r; column++){
        final searchColumn = indexColumn + column;
        if (searchColumn < 0) continue;
        if (searchColumn >= totalColumns) break;
        final searchIndex = rowAddition + column;
        final alpha = hsvAlphas[searchIndex];
        if (alpha >= ambientAlpha) continue;
        final x = (searchRow * Node_Size);
        final y = (searchColumn * Node_Size);

        final distanceX = x - vectorX;
        final distanceY = y - vectorY;
        final distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
        final distance = sqrt(distanceSquared);
        final distanceChecked = max(distance, Node_Size);

        final angle = angleBetween(vectorX, vectorY, x, y);
        final strength = (alpha / distanceChecked) * 4.0;
        vx += (cos(angle) * strength);
        vy += (sin(angle) * strength);
      }
    }

    shadow.x = vx;
    shadow.y = vy;
    shadow.z = rad(vx, vy);
  }

  void applyEmissionsLightSources() {
    for (var i = 0; i < nodesLightSourcesTotal; i++){
      final nodeIndex = nodesLightSources[i];
      final nodeType = nodeTypes[nodeIndex];

      switch (nodeType){
        case NodeType.Torch:
          emitLightAmbient(
            index: nodeIndex,
            alpha: linearInterpolateInt(
              ambientHue,
              0,
              torch_emission_intensity,
            ),
          );
          break;
      }
    }
  }

  int getIndexRow(int index) => (index % area) ~/ totalColumns;

  int getIndexZ(int index) => index ~/ area;

  int getIndexColumn(int index) => index % totalColumns;

  void emitLightAHSVShadowed({
    required int index,
    required int alpha,
    required int hue,
    required int saturation,
    required int value,
    double intensity = 1.0,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final padding = gamestream.interpolationPadding;
    final rx = getIndexRenderX(index);
    if (rx < gamestream.engine.Screen_Left - padding) return;
    if (rx > gamestream.engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < gamestream.engine.Screen_Top - padding) return;
    if (ry > gamestream.engine.Screen_Bottom + padding) return;

    gamestream.totalActiveLights++;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final z = getIndexZ(index);

    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!isNodeTypeTransparent(nodeType)){
      if (const [
        NodeOrientation.Half_North,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vxStart = 0;
      }

      if (const [
        NodeOrientation.Half_South,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vxEnd = 0;
      }

      if (const [
        NodeOrientation.Half_East,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vyStart = 0;
      }

      if (const [
        NodeOrientation.Half_West,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vyEnd = 0;
      }
    }

    final h = linearInterpolateInt(ambientHue, hue , intensity);
    final s = linearInterpolateInt(ambientSaturation, saturation, intensity);
    final v = linearInterpolateInt(ambientValue, value, intensity);
    final a = linearInterpolateInt(ambientAlpha, alpha, intensity);

    applyAHSV(
      index: index,
      alpha: a,
      hue: h,
      saturation: s,
      value: v,
      interpolation: 0,
    );

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAHSV(
            row: row,
            column: column,
            z: z,
            interpolation: -1,
            alpha: a,
            hue: h,
            saturation: s,
            value: v,
            vx: vx,
            vy: vy,
            vz: vz,
          );
        }
      }
    }
  }

  void emitLightAmbientShadows({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final padding = gamestream.interpolationPadding;
    final rx = getIndexRenderX(index);
    if (rx < gamestream.engine.Screen_Left - padding) return;
    if (rx > gamestream.engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < gamestream.engine.Screen_Top - padding) return;
    if (ry > gamestream.engine.Screen_Bottom + padding) return;
    gamestream.totalActiveLights++;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final z = getIndexZ(index);

    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!isNodeTypeTransparent(nodeType)){
      if (const [
        NodeOrientation.Half_North,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vxStart = 0;
      }

      if (const [
        NodeOrientation.Half_South,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vxEnd = 0;
      }

      if (const [
        NodeOrientation.Half_East,
        NodeOrientation.Corner_North_East,
        NodeOrientation.Corner_South_East
      ].contains(nodeOrientation)) {
        vyStart = 0;
      }

      if (const [
        NodeOrientation.Half_West,
        NodeOrientation.Corner_South_West,
        NodeOrientation.Corner_North_West
      ].contains(nodeOrientation)) {
        vyEnd = 0;
      }
    }

    applyAmbient(
      index: index,
      alpha: alpha,
      interpolation: 0,
    );

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAmbient(
            row: row,
            column: column,
            z: z,
            interpolation: -1,
            alpha: alpha,
            vx: vx,
            vy: vy,
            vz: vz,
          );
        }
      }
    }
  }

  /// illuminates the square it reaches then fires consecutive beams for each direction of movement
  void shootLightTreeAmbient({
    required int row,
    required int column,
    required int z,
    required int interpolation,
    required int alpha,
    required int vx,
    required int vy,
    required int vz,
  }){

    assert (interpolation < interpolationLength);
    var velocity = vx.abs() + vy.abs() + vz.abs();

    interpolation += velocity;

    if (interpolation >= interpolationLength) {
      return;
    }

    if (vx != 0) {
      row += vx;
      if (row < 0 || row >= totalRows)
        return;
    }

    if (vy != 0) {
      column += vy;
      if (column < 0 || column >= totalColumns)
        return;
    }

    if (vz != 0) {
      z += vz;
      if (z < 0 || z >= totalZ)
        return;
    }

    final index = (z * area) + (row * totalColumns) + column;
    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    if (!isNodeTypeTransparent(nodeType)) {
      if (nodeOrientation == NodeOrientation.Solid)
        return;

      if (vx < 0) {
        if (const [
          NodeOrientation.Half_South,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Slope_South,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_North,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Slope_North,
        ].contains(nodeOrientation)) vx = 0;
      } else if (vx > 0) {
        if (const [
          NodeOrientation.Half_North,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Slope_North,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_South,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Slope_South,
        ].contains(nodeOrientation)) vx = 0;
      }

      if (vy < 0) {
        if (const [
          NodeOrientation.Half_West,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Slope_West,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_East,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Slope_East,
        ].contains(nodeOrientation)) vy = 0;
      } else if (vy > 0) {
        if (const [
          NodeOrientation.Half_East,
          NodeOrientation.Corner_South_East,
          NodeOrientation.Corner_North_East,
          NodeOrientation.Slope_East,
        ].contains(nodeOrientation)) return;

        if (const [
          NodeOrientation.Half_West,
          NodeOrientation.Corner_South_West,
          NodeOrientation.Corner_North_West,
          NodeOrientation.Slope_West,
        ].contains(nodeOrientation)) vy = 0;
      }

      if (vz < 0) {
        if (const [
          NodeOrientation.Half_Vertical_Bottom,
        ].contains(nodeOrientation)) {
          return;
        }

        if (const [
          NodeOrientation.Half_Vertical_Bottom,
          NodeOrientation.Half_Vertical_Center,
        ].contains(nodeOrientation)) {
          vz = 0;
        }
      }

      if (vz > 0) {
        if (const [NodeOrientation.Half_Vertical_Top]
            .contains(nodeOrientation)) {
          return;
        }

        if (const [
          NodeOrientation.Half_Vertical_Top,
          NodeOrientation.Half_Vertical_Center,
        ].contains(nodeOrientation)) {
          vz = 0;
        }
      }
    }

    applyAmbient(index: index, alpha: alpha, interpolation: interpolation);

    if (const [
      NodeType.Grass_Long,
      NodeType.Tree_Bottom,
      NodeType.Tree_Top,
    ].contains(nodeType)) {
      interpolation++;
      if (interpolation >= interpolationLength)
        return;
    }

    velocity = vx.abs() + vy.abs() + vz.abs();

    if (velocity == 0)
      return;

    if (vx.abs() + vy.abs() + vz.abs() == 3) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: vx,
        vy: vy,
        vz: vz,
      );
    }

    if (vx.abs() + vy.abs() == 2) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: vx,
        vy: vy,
        vz: 0,
      );
    }

    if (vx.abs() + vz.abs() == 2) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: vx,
        vy: 0,
        vz: vz,
      );
    }

    if (vy.abs() + vz.abs() == 2) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: 0,
        vy: vy,
        vz: vz,
      );
    }

    if (vy != 0) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: 0,
        vy: vy,
        vz: 0,
      );
    }

    if (vx != 0) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: vx,
        vy: 0,
        vz: 0,
      );
    }

    if (vz != 0) {
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        interpolation: interpolation,
        alpha: alpha,
        vx: 0,
        vy: 0,
        vz: vz,
      );
    }
  }

  void shootLightTreeAHSV({
    required int row,
    required int column,
    required int z,
    required int interpolation,
    required int alpha,
    required int hue,
    required int saturation,
    required int value,
    int vx = 0,
    int vy = 0,
    int vz = 0,

  }){
    assert (interpolation < interpolationLength);

    var velocity = vx.abs() + vy.abs() + vz.abs();
    var paintBehindZ = vz == 0;
    var paintBehindRow = vx == 0;
    var paintBehindColumn = vy == 0;

    while (interpolation < interpolationLength) {

      if (velocity == 0) return;

      interpolation += velocity;
      if (interpolation >= interpolationLength) return;

      if (vx != 0){
        row += vx;
        if (row < 0 || row >= totalRows) return;
      }

      if (vy != 0){
        column += vy;
        if (column < 0 || column >= totalColumns) return;
      }

      if (vz != 0){
        z += vz;
        if (z < 0 || z >= totalZ) return;
      }

      final index = (z * area) + (row * totalColumns) + column;
      final nodeType = nodeTypes[index];

      if (!isNodeTypeTransparent(nodeType)) {

        final nodeOrientation = nodeOrientations[index];

        if (vz != 0 && nodeOrientationBlocksVertical(nodeOrientation)){
          if (vz > 0) {
            if (nodeOrientation != NodeOrientation.Half_Vertical_Top){
              if (vx == 0 && vy == 0) return;
              final previousNodeIndex = index - (vy) - (vx * totalColumns);
              final previousNodeOrientation = nodeOrientations[previousNodeIndex];
              if (nodeOrientationBlocksVertical(previousNodeOrientation)) return;
            }
          }
          velocity = vx.abs() + vy.abs();
          vz = 0;
        }

        final vx2 = vx;
        final xBehind = vx > 0;
        final yBehind = vy > 0;

        if (vx != 0 && nodeOrientationBlocksNorthSouth(nodeOrientation)) {
          if (xBehind && yBehind)  {
            if (const [
              NodeOrientation.Corner_South_West,
              NodeOrientation.Half_South,
              NodeOrientation.Half_West,
            ].contains(nodeOrientation)){
              applyAHSV(
                index: index - area,
                alpha: alpha,
                hue: hue,
                saturation: saturation,
                value: value,
                interpolation: interpolation,
              );
            }
            return;
          }
          velocity = vy.abs() + vz.abs();
          paintBehindColumn = false;
          paintBehindZ = false;
          if (vx < 0){
            if (nodeOrientation == NodeOrientation.Half_North){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_North_East && vy < 0){
              paintBehindZ = true;
            }
          } else {
            if (nodeOrientation == NodeOrientation.Half_South){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_South_East && vy <= 0){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_South_West && vy >= 0){
              paintBehindZ = true;
            }
          }
          vx = 0;
        }

        if (vy != 0 && nodeOrientationBlocksEastWest(nodeOrientation)) {
          if (xBehind && yBehind)  return;
          velocity = vx.abs() + vz.abs();
          paintBehindRow = false;
          paintBehindZ = false;

          if (vy < 0) {
            if (nodeOrientation == NodeOrientation.Half_East){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_North_East && vx2 <= 0){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_South_West && vx2 >= 0){
              paintBehindZ = true;
            }
          } else {
            if (nodeOrientation == NodeOrientation.Half_West){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_North_West && vx2 <= 2){
              paintBehindZ = true;
            } else
            if (nodeOrientation == NodeOrientation.Corner_South_West && vx2 >= 0){
              paintBehindZ = true;
            }
          }
          vy = 0;
        }

        if (vx == 1 && vy == 1 && vz == 0 && nodeOrientation == NodeOrientation.Column_Top_Left){
          return;
        }
      }

      applyAHSV(
        index: index,
        alpha: alpha,
        hue: hue,
        saturation: saturation,
        value: value,
        interpolation: interpolation,
      );

      if (paintBehindZ) {
        applyAHSV(
          index: index - area,
          alpha: alpha,
          hue: hue,
          saturation: saturation,
          value: value,
          interpolation: interpolation,
        );
      }

      if (paintBehindRow) {
        applyAHSV(
          index: index - totalColumns,
          alpha: alpha,
          hue: hue,
          saturation: saturation,
          value: value,
          interpolation: interpolation,
        );
      }

      if (paintBehindColumn) {
        applyAHSV(
          index: index - 1,
          alpha: alpha,
          hue: hue,
          saturation: saturation,
          value: value,
          interpolation: interpolation,
        );
      }

      if (const [
        NodeType.Grass_Long,
        NodeType.Tree_Bottom,
        NodeType.Tree_Top,
      ].contains(nodeType)) {
        interpolation += 2;
        if (interpolation >= interpolationLength) return;
      }

      if (velocity > 1) {
        if (vx != 0){
          shootLightTreeAHSV(
            row: row,
            column: column,
            z: z,
            interpolation: interpolation,
            alpha: alpha,
            hue: hue,
            saturation: saturation,
            value: value,
            vx: vx,
          );
        }
        if (vy != 0) {
          shootLightTreeAHSV(
            row: row,
            column: column,
            z: z,
            interpolation: interpolation,
            alpha: alpha,
            hue: hue,
            saturation: saturation,
            value: value,
            vy: vy,
          );
        }
        if (vz != 0){
          shootLightTreeAHSV(
            row: row,
            column: column,
            z: z,
            interpolation: interpolation,
            alpha: alpha,
            hue: hue,
            saturation: saturation,
            value: value,
            vz: vz,
          );
        }
      }
    }
  }


  bool isValidIndex(int index) => index >= 0 && index < totalNodes;

  double getIndexRenderX(int index) =>
      IsometricRender.rowColumnToRenderX(
          getIndexRow(index),
          getIndexColumn(index),
      );

  double getIndexRenderY(int index) =>
      IsometricRender.rowColumnZToRenderY(getIndexRow(index), getIndexColumn(index), getIndexZ(index));

  void applyAmbient({
    required int index,
    required int alpha,
    required int interpolation,
  }){
    assert (index >= 0);
    assert (index < totalNodes);

    final intensity = interpolations[interpolation < 0 ? 0 : interpolation];
    final interpolatedAlpha = linearInterpolateInt(alpha, ambientAlpha, intensity);;
    final currentAlpha = hsvAlphas[index];
    if (currentAlpha <= interpolatedAlpha) {
      return;
    }
    final currentHue = hsvHue[index];
    if (currentHue != ambientHue)
      return;

    ambientStackIndex++;
    ambientStack[ambientStackIndex] = index;
    hsvAlphas[index] = interpolatedAlpha;
    refreshNodeColor(index);
  }

  bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
      NodeType.isRainOrEmpty(getTypeZRC(z, row, column));

  void applyAHSV({
    required int index,
    required int alpha,
    required int hue,
    required int saturation,
    required int value,
    required int interpolation,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final intensity = interpolations[interpolation < 0 ? 0 : interpolation];

    var hueA = hue;
    var hueB = hsvHue[index];
    int hueI;

    if ((hueA - hueB).abs() > 180){
      if (hueA < hueB){
        hueA += 360;
      } else {
        hueB += 360;
      }
      hueI = linearInterpolateInt(hueA, hueB, intensity) % 360;
    } else {
      hueI = linearInterpolateInt(hueA, hueB, intensity);
    }

    final interpolatedA = linearInterpolateInt(alpha, hsvAlphas[index], intensity);
    final interpolatedS = linearInterpolateInt(saturation, hsvSaturation[index], intensity);
    final interpolatedV = linearInterpolateInt(value, hsvValues[index], intensity);
    colorStackIndex++;
    colorStack[colorStackIndex] = index;
    hsvAlphas[index] = interpolatedA;
    hsvHue[index] = hueI;
    hsvSaturation[index] = interpolatedS;
    hsvValues[index] = interpolatedV;
    refreshNodeColor2(index);
  }

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

  bool isIndexOnScreen(int index){

    final row = getIndexRow(index);
    final column = getIndexColumn(index);

    final renderX = IsometricRender.rowColumnToRenderX(row, column);
    if (renderX < gamestream.engine.Screen_Left) return false;
    if (renderX > gamestream.engine.Screen_Right) return false;

    final renderY = IsometricRender.rowColumnZToRenderY(row, column, getIndexZ(index));
    if (renderY < gamestream.engine.Screen_Top) return false;
    if (renderY > gamestream.engine.Screen_Bottom) return false;

    return true;
  }

  int getTypeBelow(int index){
    if (index < area) return NodeType.Boundary;
    final indexBelow = index - area;
    if (indexBelow >= totalNodes) return NodeType.Boundary;
    return nodeTypes[indexBelow];
  }

  int getIndexBelow(int index) => index - area;

  int getIndexBelowPosition(IsometricPosition position) =>
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

  int getRenderColorPosition(IsometricPosition position) =>
      outOfBoundsPosition(position)
          ? ambientColor
          : nodeColors[getIndexPosition(position)];

  void refreshBakeMapLightSources() {
    nodesLightSourcesTotal = 0;
    for (var i = 0; i < totalNodes; i++){
      if (!NodeType.emitsLight(nodeTypes[i])) continue;
      if (nodesLightSourcesTotal >= nodesLightSources.length) {
        nodesLightSources = Uint16List(nodesLightSources.length + 100);
        refreshBakeMapLightSources();
        return;
      }
      nodesLightSources[nodesLightSourcesTotal] = i;
      nodesLightSourcesTotal++;
    }
  }

  bool outOfBoundsPosition(IsometricPosition position) =>
      outOfBoundsXYZ(position.x, position.y, position.z);

  int getTypeXYZSafe(double x, double y, double z) =>
      inBoundsXYZ(x, y, z) ? getTypeXYZ(x, y, z) : NodeType.Boundary;

  int getTypeXYZ(double x, double y, double z) =>
      nodeTypes[getIndexXYZ(x, y, z)];

  bool inBoundsPosition(IsometricPosition position) =>
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


  int getIndexPosition(IsometricPosition position) =>
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

  int getNearestLightSourcePosition(IsometricPosition position, {int maxDistance = 5}) => getNearestLightSource(
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

  /// @hue a number between 0 and 360
  /// @saturation a number between 0 and 100
  /// @value a number between 0 and 100
  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void applyVector3Emission(IsometricPosition v, {
    required int hue,
    required int saturation,
    required int value,
    required int alpha,
    double intensity = 1.0,
  }){
    if (!inBoundsPosition(v)) return;
    emitLightAHSVShadowed(
      index: getIndexPosition(v),
      hue: hue,
      saturation: saturation,
      value: value,
      alpha: alpha,
      intensity: intensity,
    );
  }

  /// @alpha a number between 0 and 255
  /// @intensity a number between 0.0 and 1.0
  void applyVector3EmissionAmbient(IsometricPosition v, {
    required int alpha,
    double intensity = 1.0,
  }){
    assert (intensity >= 0);
    assert (intensity <= 1);
    assert (alpha >= 0);
    assert (alpha <= 255);
    if (!inBoundsPosition(v)) return;
    emitLightAmbient(
      index: getIndexPosition(v),
      alpha: linearInterpolateInt(ambientHue, alpha , intensity),
    );
  }

  void toggleDynamicShadows() => dynamicShadows = !dynamicShadows;
}



