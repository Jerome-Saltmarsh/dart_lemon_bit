
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/functions/hsv_to_color.dart';
import 'package:gamestream_flutter/library.dart';

class GameNodes {
  static var ambient_color_hsv  = HSVColor.fromColor(Color.fromRGBO(31, 1, 86, 0.5));
  static var ambient_hue        = ((ambient_color_hsv.hue / 360) * 255).round();
  static var ambient_sat        = (ambient_color_hsv.saturation * 255).round();
  static var ambient_val        = (ambient_color_hsv.value * 255).round();
  static var ambient_alp        = (ambient_color_hsv.alpha * 255).round();
  static var ambient_color      = 0;

  static void resetNodeColorsToAmbient() {
    GameNodes.ambient_alp = clamp(GameNodes.ambient_alp, 0, 255);
    ambient_color = hsvToColor(
        hue: ambient_hue,
        saturation: ambient_sat,
        value: ambient_val,
        opacity: ambient_alp
    );
    colorStackIndex = 0;

     if (nodeColors.length != total) {
       nodeColors = Uint32List(total);
       hsv_hue = Uint8List(total);
       hsv_saturation = Uint8List(total);
       hsv_values = Uint8List(total);
       hsv_alphas = Uint8List(total);
     }
     for (var i = 0; i < total; i++) {
       nodeColors[i] = ambient_color;
       hsv_hue[i] = ambient_hue;
       hsv_saturation[i] = ambient_sat;
       hsv_values[i] = ambient_val;
       hsv_alphas[i] = ambient_alp;
     }
  }

  static var nodeColors = Uint32List(0);
  static var hsv_hue = Uint8List(0);
  static var hsv_saturation = Uint8List(0);
  static var hsv_values = Uint8List(0);
  static var hsv_alphas = Uint8List(0);
  static var nodeOrientations = Uint8List(0);
  static var nodeTypes = Uint8List(0);
  static var nodeVariations = Uint8List(0);
  static var colorStack = Uint16List(0);
  static var nodeWind = Uint8List(0);
  static var miniMap = Uint8List(0);
  static var heightMap = Uint16List(0);
  static var colorStackIndex = -1;
  static var total = 0;
  static var area = 0;
  static var area2 = 0;
  static var projection = 0;
  static var projectionHalf = 0;

  static var totalZ = 0;
  static var totalRows = 0;
  static var totalColumns = 0;
  static var lengthRows = 0.0;
  static var lengthColumns = 0.0;
  static var lengthZ = 0.0;

  static var offscreenNodes = 0;
  static var onscreenNodes = 0;

  // METHODS


  static int getHeightAt(int row, int column){
    final index = total - area + ((row * totalColumns) + column);
    var i = index;
    for (var z = totalZ - 1; z >= 0; z--){
      if (nodeOrientations[i] != NodeOrientation.None) return z;
      i -= area;
    }
    return 0;
  }

  static void generateHeightMap() {
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

  static int getIndexXYZ(double x, double y, double z) =>
      getIndex(x ~/ Node_Size, y ~/ Node_Size, z ~/ Node_Size_Half);

  static int getIndex(int row, int column, int z) =>
      (row * totalColumns) + column + (z * GameNodes.area);

  static void generateMiniMap(){
      if (miniMap.length != area){
        miniMap = Uint8List(area);
      }

      var index = 0;
      for (var row = 0; row < totalRows; row++){
          for (var column = 0; column < totalColumns; column++){
            var searchIndex = total - area +  index;
            var typeFound = ItemType.Empty;
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

  static void resetNodeColorStack() {
    while (colorStackIndex >= 0) {
      final i = colorStack[colorStackIndex];
      nodeColors[i] = ambient_color;
      hsv_hue[i] = ambient_hue;
      hsv_saturation[i] = ambient_sat;
      hsv_values[i] = ambient_val;
      hsv_alphas[i] = ambient_alp;
      colorStackIndex--;
    }
    colorStackIndex = 0;
  }

  static const interpolations = <double>[
    0,
    0.30555555555555547,
    0.5555555555555555,
    0.75,
    0.8888888888888888,
    0.9722222222222222,
    1,
  ];

  static const interpolationsLength = 6;

  static void emitLightDynamic({
    required int index,
    required int hue,
    required int saturation,
    required int value,
    required int alpha,
    double strength = 1.0,

  }){
    if (index < 0) return;
    if (index >= total) return;

    assert (hue >= 0);
    assert (hue <= 255);
    assert (saturation >= 0);
    assert (saturation <= 255);
    assert (value >= 0);
    assert (value <= 255);
    assert (alpha >= 0);
    assert (alpha <= 255);

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ totalColumns;
    final columnIndex = GameState.convertNodeIndexToIndexY(index);
    final radius = Shade.Pitch_Black;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, totalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, totalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, totalColumns);
    final rowInitInit = totalColumns * rowMin;
    var zTotal = zMin * area;

    const r = 4;
    final dstXLeft = GameConvert.rowColumnZToRenderX(rowIndex + r, columnIndex - r);
    if (dstXLeft < Engine.Screen_Left)    return;
    final dstXRight = GameConvert.rowColumnZToRenderX(rowIndex - r, columnIndex + r);
    if (dstXRight > Engine.Screen_Right)   return;
    final dstYTop = GameConvert.rowColumnZToRenderY(rowIndex + r, columnIndex + r, zIndex);
    if (dstYTop <  Engine.Screen_Top) return;
    final dstYBottom = GameConvert.rowColumnZToRenderY(rowIndex - r, columnIndex - r, zIndex);
    if (dstYBottom >  Engine.Screen_Bottom) return;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += totalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = Engine.clamp(b + (column - columnIndex).abs() - 2, 0, 6);
          if (distanceValue > 5) continue;

          colorStack[colorStackIndex++] = nodeIndex;

          final intensity = (1.0 - interpolations[clamp(distanceValue, 0, 7)]) * strength;
          hsv_hue[nodeIndex] = Engine.linerInterpolationInt(hsv_hue[nodeIndex], hue        , intensity);
          hsv_saturation[nodeIndex] = Engine.linerInterpolationInt(hsv_saturation[nodeIndex], saturation , intensity);
          hsv_values[nodeIndex] = Engine.linerInterpolationInt(hsv_values[nodeIndex], value      , intensity);
          hsv_alphas[nodeIndex] = Engine.linerInterpolationInt(hsv_alphas[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  static void emitLightAmbient({
    required int index,
    required int alpha,
  }){

    if (GameSettings.Dynamic_Shadows) {
      emitLightAmbientDynamicShadows(
        index: index,
        alpha: alpha,
      );
      return;
    }

    if (index < 0) return;
    if (index >= total) return;

    final zIndex = index ~/ area;
    final rowIndex = (index - (zIndex * area)) ~/ totalColumns;
    final columnIndex = GameState.convertNodeIndexToIndexY(index);
    final radius = Shade.Pitch_Black;
    final zMin = max(zIndex - radius, 0);
    final zMax = min(zIndex + radius, totalZ);
    final rowMin = max(rowIndex - radius, 0);
    final rowMax = min(rowIndex + radius, totalRows);
    final columnMin = max(columnIndex - radius, 0);
    final columnMax = min(columnIndex + radius, totalColumns);
    final rowInitInit = totalColumns * rowMin;
    var zTotal = zMin * area;

    const r = 4;
    final dstXLeft = GameConvert.rowColumnZToRenderX(rowIndex + r, columnIndex - r);
    if (dstXLeft < Engine.Screen_Left)    return;
    final dstXRight = GameConvert.rowColumnZToRenderX(rowIndex - r, columnIndex + r);
    if (dstXRight > Engine.Screen_Right)   return;
    final dstYTop = GameConvert.rowColumnZToRenderY(rowIndex + r, columnIndex + r, zIndex);
    if (dstYTop <  Engine.Screen_Top) return;
    final dstYBottom = GameConvert.rowColumnZToRenderY(rowIndex - r, columnIndex - r, zIndex);
    if (dstYBottom >  Engine.Screen_Bottom) return;

    for (var z = zMin; z < zMax; z++) {
      var rowInit = rowInitInit;

      for (var row = rowMin; row <= rowMax; row++){
        final a = (zTotal) + (rowInit);
        rowInit += totalColumns;
        final b = (z - zIndex).abs() + (row - rowIndex).abs();
        for (var column = columnMin; column <= columnMax; column++) {
          final nodeIndex = a + column;
          final distanceValue = Engine.clamp(b + (column - columnIndex).abs() - 2, 0, Shade.Pitch_Black);
          if (distanceValue > 5) continue;

          colorStack[colorStackIndex++] = nodeIndex;

          final intensity = 1.0 - interpolations[clamp(distanceValue, 0, 7)];
          final nodeAlpha = hsv_alphas[nodeIndex];
          if (nodeAlpha < alpha) continue;
          hsv_alphas[nodeIndex] = Engine.linerInterpolationInt(hsv_alphas[nodeIndex], alpha      , intensity);
          refreshNodeColor(nodeIndex);
        }
      }
      zTotal += area;
    }
  }

  static void refreshNodeColor(int index) =>
    nodeColors[index] = hsvToColor(
      hue: hsv_hue[index],
      saturation: hsv_saturation[index],
      value: hsv_values[index],
      opacity: hsv_alphas[index],
    );


  static int getTorchIndex(int nodeIndex){
    final initialSearchIndex = nodeIndex - totalColumns - 1; // shifts the selectIndex - 1 row and - 1 column
    var torchIndex = -1;
    var rowIndex = 0;

    for (var row = 0; row < 3; row++){
      for (var column = 0; column < 3; column++){
        final searchIndex = initialSearchIndex + rowIndex + column;
        if (searchIndex >= total) break;
        if (nodeTypes[searchIndex] != NodeType.Torch) continue;
        torchIndex = searchIndex;
        break;
      }
      rowIndex += totalColumns;
    }
    return torchIndex;
  }

  static void refreshGridMetrics(){
    lengthRows = totalRows * Node_Size;
    lengthColumns = totalColumns * Node_Size;
    lengthZ = totalZ * Node_Height;
  }

  static final shadow = Vector3();

  static void markShadow(Vector3 vector){
    final index = vector.nodeIndex - area;
    if (index < 0) return;
    if (index >= total) return;

    final indexRow = getIndexRow(index);
    final indexColumn = getIndexColumn(index);

    final vectorX = vector.x;
    final vectorY = vector.y;

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
        final alpha = hsv_alphas[searchIndex];
        if (alpha >= GameNodes.ambient_alp) continue;
        final x = (searchRow * Node_Size);
        final y = (searchColumn * Node_Size);

        final distanceX = x - vectorX;
        final distanceY = y - vectorY;
        final distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);
        final distance = sqrt(distanceSquared);
        final distanceChecked = max(distance, Node_Size);

        final angle = getAngleBetween(vectorX, vectorY, x, y);
        final strength = (alpha / distanceChecked) * 4.0;
        vx += (cos(angle) * strength);
        vy += (sin(angle) * strength);
      }
    }

    // final angle = getAngle(vx, vy);
    shadow.x = vx;
    shadow.y = vy;
    shadow.z = getAngle(vx, vy);
 }

  static int getIndexRow(int index) => (index % area) ~/ totalColumns;
  static int getIndexZ(int index) => index ~/ area;
  static int getIndexColumn(int index) => index % totalColumns;


  /// EMIT LIGHT FUNCTIONS

  static void emitLightAmbientDynamicShadows({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= total) return;
    //
    // final row = getIndexRow(index);
    // final column = getIndexColumn(index);
    // final z = getIndexZ(index);

    // final renderX = GameConvert.rowColumnZToRenderX(row, column);
    // final renderY = GameConvert.rowColumnZToRenderY(row, column, z);

    // final xOnscreen = renderX > Engine.Screen_Left && renderX < Engine.Screen_Right;
    // final yOnscreen = renderY > Engine.Screen_Top && renderY < Engine.Screen_Bottom;
    //
    // final nodeOrientation = nodeOrientations[index];

    // if (xOnscreen && yOnscreen){
    //   if (nodeOrientation != NodeOrientation.Half_South && nodeOrientation != NodeOrientation.Half_West){
    //     applyAmbient(
    //       index: index,
    //       alpha: alpha,
    //       interpolation: 0,
    //     );
    //
    //     final nodeIndexBelow = index - area;
    //     if (nodeIndexBelow > 0){
    //       applyAmbient(
    //         index: nodeIndexBelow,
    //         alpha: alpha,
    //         interpolation: 0,
    //       );
    //     }
    //   }
    // }

    for (var z = -1; z <= 1; z++){
      for (var row = -1; row <= 1; row++){
        for (var column = -1; column <= 1; column++){
          shootLightTreeAmbient(
            index: index,
            interpolation: 0,
            alpha: alpha,
            vx: row,
            vy: column,
            vz: z,
          );
        }
      }
    }
  }

  static void shootLightAmbientNorthEast({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    if (interpolation >= interpolationsLength) return;
    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);


    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY < Engine.Screen_Top) return;

    final rX = GameConvert.rowColumnToRenderX(row, column);
    final rxOnScreen = rX > Engine.Screen_Left && rX < Engine.Screen_Right;

    while (interpolation < interpolationsLength) {
      row--;
      if (row < 0) return;
      column--;
      if (column < 0) return;

      index -= (totalColumns + 1);
      rY -= Node_Size;

      if (shootVertical && rxOnScreen) {
        if (rY <= Engine.Screen_Bottom) {
          shootLightAmbientDown(index: index, alpha: alpha, interpolation: interpolation);
        }
        if (rY > Engine.Screen_Top){
          shootLightAmbientUp(index: index, alpha: alpha, interpolation: interpolation);
        }
      }

      if (rY > Engine.Screen_Bottom){
        interpolation += 2;
        continue;
      }

      if (rY > Engine.Screen_Top){
        applyAmbient(
          index: index,
          alpha: alpha,
          interpolation: interpolation,
        );
      }


      interpolation++;
      if (interpolation >= interpolationsLength) return;

      var blocked = false;
      if (nodeBlocksNorthSouth(index)) {
        blocked = true;
      } else {
        shootLightAmbientNorth(index: index, alpha: alpha, interpolation: interpolation, shootBelow: true);
      }
      if (nodeBlocksEastWest(index)) {
        blocked = true;
      } else {
        shootLightAmbientEast(index: index, alpha: alpha, interpolation: interpolation, shootVertical: true);
      }

      if (blocked) return;
      interpolation++;
    }
  }

  static void shootLightAmbientSouthEast({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexColumn(index);

    var rX = GameConvert.rowColumnZToRenderX(row, column);

    if (rX > Engine.Screen_Right) return;

    final rY = GameConvert.rowColumnZToRenderY(row, column, z);
    final rYOnScreen = rY > Engine.Screen_Top && rY < Engine.Screen_Bottom;

    while (interpolation < interpolationsLength) {
      row++;
      if (row >= totalRows) return;
      column--;
      if (column < 0) return;

      index += (totalColumns - 1);
      rX += Node_Size;

      if (rX > Engine.Screen_Right) return;
      if (rX < Engine.Screen_Left) {
        interpolation += 2;
        continue;
      }

      if (shootVertical) {
        shootLightAmbientDown(index: index, alpha: alpha, interpolation: interpolation);
        shootLightAmbientUp(index: index, alpha: alpha, interpolation: interpolation);
      }

      if (rYOnScreen){
        applyAmbient(
          index: index,
          alpha: alpha,
          interpolation: interpolation,
        );
      }

      interpolation++;
      if (interpolation >= interpolationsLength) return;

      var blocked = false;
      if (nodeBlocksNorthSouth(index)) {
        blocked = true;
      } else {
        shootLightAmbientSouth(index: index, alpha: alpha, interpolation: interpolation, shootVertical: true);
      }

      if (nodeBlocksEastWest(index)) {
        blocked = true;
      } else {
        shootLightAmbientEast(index: index, alpha: alpha, interpolation: interpolation, shootVertical: true);
      }


      if (blocked) return;

      interpolation++;
    }
  }

  static void shootLightAmbientSouthWest({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);

    final rX = GameConvert.rowColumnToRenderX(row, column);
    final rxOnScreen = rX > Engine.Screen_Left && rX < Engine.Screen_Right;
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);

    while (interpolation < interpolationsLength) {
      row++;
      if (row >= totalRows) return;
      column++;
      if (column >= totalColumns) return;

      index += (totalColumns + 1);
      rY += Node_Size;

      if (shootVertical && rxOnScreen) {
        if (rY < Engine.Screen_Bottom){
          shootLightAmbientDown(index: index, alpha: alpha, interpolation: interpolation);
        }
        if (rY > Engine.Screen_Top){
          shootLightAmbientUp(index: index, alpha: alpha, interpolation: interpolation);
        }
      }

      if (rY < Engine.Screen_Top){
        interpolation += 2;
        continue;
      }

      if (rY < Engine.Screen_Bottom){
        applyAmbient(
          index: index,
          alpha: alpha,
          interpolation: interpolation,
        );
      }

      interpolation++;
      if (interpolation >= interpolationsLength) return;

      var blocked = false;
      if (nodeBlocksNorthSouth(index)) {
        blocked = true;
      } else {
        shootLightAmbientSouth(index: index, alpha: alpha, interpolation: interpolation, shootVertical: true);
      }
      if (nodeBlocksEastWest(index)) {
        blocked = true;
      } else {
        shootLightAmbientWest(index: index, alpha: alpha, interpolation: interpolation, shootVertical: true);
      }

      if (blocked) return;
      interpolation++;
    }
  }


  static void shootLightAmbientNorthWest({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    var row = getIndexRow(index);
    var column = getIndexColumn(index);

    var rX = GameConvert.rowColumnToRenderX(row, column);
    if (rX < Engine.Screen_Left) return;

    while (interpolation < interpolationsLength) {
      row--;
      if (row < 0) return;
      column++;
      if (column >= totalColumns) return;

      index += (-totalColumns + 1);

      rX -= Node_Size;
      if (rX < Engine.Screen_Left) return;
      if (rX > Engine.Screen_Right) {
        interpolation += 2;
        continue;
      }

      if (shootVertical) {
        shootLightAmbientDown(index: index, alpha: alpha, interpolation: interpolation);
        shootLightAmbientUp(index: index, alpha: alpha, interpolation: interpolation);
      }

      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation,
      );

      interpolation++;
      if (interpolation >= interpolationsLength) return;

      var blocked = false;
      if (nodeBlocksNorthSouth(index)) {
        blocked = true;
      } else {
        shootLightAmbientNorth(index: index, alpha: alpha, interpolation: interpolation, shootBelow: true);
      }
      if (nodeBlocksEastWest(index)) {
        blocked = true;
      } else {
        shootLightAmbientWest(index: index, alpha: alpha, interpolation: interpolation, shootVertical: true);
      }

      if (blocked) return;
      interpolation++;
    }
  }

  /// illuminates the square it reaches then fires consecutive beams for each direction of movement
  static void shootLightTreeAmbient({
    required int index,
    required int interpolation,
    required int alpha,
    int vx = 0,
    int vy = 0,
    int vz = 0,
  }){
    assert (interpolation < interpolationsLength);

    final velocity = vx.abs() + vy.abs() + vz.abs();

    if (velocity == 0) {
      applyAmbient(index: index, alpha: alpha, interpolation: interpolation);
      return;
    }

    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);

    while (interpolation < interpolationsLength) {
      interpolation += velocity;
      if (interpolation >= interpolationsLength) return;

       row += vx;
       if (row < 0 || row >= totalRows) return;
       column += vy;
       if (column < 0 || column >= totalColumns) return;
       z += vz;
       if (z < 0 || z >= totalZ) return;

       index = (z * area) + (row * totalColumns) + column;

       applyAmbient(index: index, alpha: alpha, interpolation: interpolation);

      if (vy == 0){
        if (nodeBlocksNorthSouth(index)) return;
      }
      if (vx == 0){
        if (nodeBlocksEastWest(index)) return;
      }

       if (vz == 0){
         final nodeIndexBelow = index - area;
         if (nodeIndexBelow > 0){
           applyAmbient(
             index: nodeIndexBelow,
             alpha: alpha,
             interpolation: interpolation,
           );
         }
       }

       if (velocity > 1){
         if (vx != 0){
           shootLightTreeAmbient(index: index, interpolation: interpolation, alpha: alpha, vx: vx);
         }
         if (vy != 0){
           shootLightTreeAmbient(index: index, interpolation: interpolation, alpha: alpha, vy: vy);
         }
         if (vz != 0){
           shootLightTreeAmbient(index: index, interpolation: interpolation, alpha: alpha, vz: vz);
         }
       }
    }
  }

  static void shootLightAmbientNorth({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootBelow = false,
  }) {
    assert (interpolation < interpolationsLength);

    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);

    var rX = GameConvert.rowColumnZToRenderX(row, column);
    if (rX < Engine.Screen_Left) return;
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY < Engine.Screen_Top) return;

    while (interpolation < interpolationsLength) {
      row--;
      if (row < 0) return;
      rX -= Node_Size_Half;
      if (rX < Engine.Screen_Left) return;
      rY -= Node_Size_Half;
      if (rY < Engine.Screen_Top) return;

      index -= totalColumns;

      if (rX > Engine.Screen_Right) {
        interpolation++;
        continue;
      }
      if (rY > Engine.Screen_Bottom) {
        interpolation++;
        continue;
      }

      if (shootBelow && rY + Node_Size_Half < Engine.Screen_Bottom) {
        final nodeIndexBelow = index - area;
        if (nodeIndexBelow > 0){
          applyAmbient(
            index: nodeIndexBelow,
            alpha: alpha,
            interpolation: interpolation,
          );
        }
      }

      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation++,
      );
      if (nodeBlocksNorthSouth(index)) return;
    }
  }

  static void shootLightAmbientEast({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    assert (interpolation < interpolationsLength);

    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);

    var rX = GameConvert.rowColumnZToRenderX(row, column);
    if (rX > Engine.Screen_Right) return;
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY < Engine.Screen_Top) return;


    while (interpolation < interpolationsLength) {
      column--;
      if (column < 0) return;

      rX += Node_Size_Half;
      if (rX > Engine.Screen_Right) return;
      rY -= Node_Size_Half;
      if (rY < Engine.Screen_Top) return;

      index--;

      if (rY > Engine.Screen_Bottom) {
        interpolation++;
        continue;
      }
      if (rX < Engine.Screen_Left) {
        interpolation++;
        continue;
      }

      if (shootVertical && rY + Node_Size_Half < Engine.Screen_Bottom) {
        final nodeIndexBelow = index - area;
        if (nodeIndexBelow > 0){
          applyAmbient(
            index: nodeIndexBelow,
            alpha: alpha,
            interpolation: interpolation,
          );
        }
      }

      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation++,
      );
      if (nodeBlocksEastWest(index)) return;
    }
  }

  static void shootLightAmbientSouth({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    assert (interpolation < interpolationsLength);

    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);

    var rX = GameConvert.rowColumnZToRenderX(row, column);
    if (rX > Engine.Screen_Right) return;
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY > Engine.Screen_Bottom) return;

    while (interpolation < interpolationsLength) {
      row++;
      if (row >= totalRows) return;

      rX += Node_Size_Half;
      if (rX > Engine.Screen_Right) return;
      rY += Node_Size_Half;
      if (rY > Engine.Screen_Bottom) return;

      index += totalColumns;
      if (nodeBlocksNorthSouth(index)) return;

      if (rX < Engine.Screen_Left) {
        interpolation++;
        continue;
      };
      if (rY < Engine.Screen_Top) {
        interpolation++;
        continue;
      }

      if (shootVertical && rY + Node_Size_Half < Engine.Screen_Bottom) {
        final nodeIndexBelow = index - area;
        if (nodeIndexBelow > 0){
          applyAmbient(
            index: nodeIndexBelow,
            alpha: alpha,
            interpolation: interpolation,
          );
        }
      }

      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation++,
      );
    }
  }

  static void shootLightAmbientWest({
    required int index,
    required int alpha,
    required int interpolation,
    bool shootVertical = false,
  }) {
    assert (interpolation < interpolationsLength);

    var row = getIndexRow(index);
    var column = getIndexColumn(index);
    var z = getIndexZ(index);

    var rX = GameConvert.rowColumnZToRenderX(row, column);
    if (rX < Engine.Screen_Left) return;
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY > Engine.Screen_Bottom) return;

    while (interpolation < interpolationsLength) {
      column++;
      if (column >= totalColumns) return;

      rX -= Node_Size_Half;
      if (rX < Engine.Screen_Left) return;
      rY += Node_Size_Half;
      if (rY > Engine.Screen_Bottom) return;

      index++;
      if (nodeBlocksEastWest(index)) return;

      if (rX > Engine.Screen_Right) {
        interpolation++;
        continue;
      };
      if (rY < Engine.Screen_Top) {
        interpolation++;
        continue;
      }

      if (shootVertical && rY + Node_Size_Half < Engine.Screen_Bottom) {
        final nodeIndexBelow = index - area;
        if (nodeIndexBelow > 0){
          applyAmbient(
            index: nodeIndexBelow,
            alpha: alpha,
            interpolation: interpolation,
          );
        }
      }
      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation++,
      );
    }
  }

  static void shootLightAmbientDown({
    required int index,
    required int alpha,
    required int interpolation,
  }) {

    if (interpolation >= interpolationsLength) return;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final rX = GameConvert.rowColumnZToRenderX(row, column);

    if (rX < Engine.Screen_Left) {
      // TODO REMOVE
      return;
    }
    if (rX > Engine.Screen_Right) {
      // TODO REMOVE
      return;
    }

    final z = getIndexZ(index);
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY > Engine.Screen_Bottom) {
      return;
    }

    while (interpolation < interpolationsLength) {
      index -= area;
      if (index < 0) return;
      rY += Node_Size_Half;

      if (rY > Engine.Screen_Bottom) return;

      if (rY < Engine.Screen_Top) {
        interpolation++;
        continue;
      }

      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation++,
      );
      if (nodeBlocksVertical(index)) return;
    }
  }

  static void shootLightAmbientUp({
    required int index,
    required int alpha,
    required int interpolation,
  }) {

    final row = getIndexRow(index);
    final column = getIndexColumn(index);

    // var rX = GameConvert.rowColumnZToRenderX(row, column);
    // assert (rX >= Engine.Screen_Left);
    // assert (rX <= Engine.Screen_Right);

    final z = getIndexZ(index);
    var rY = GameConvert.rowColumnZToRenderY(row, column, z);
    if (rY < Engine.Screen_Top) {
      return;
    };

    while (interpolation < interpolationsLength) {
      index += area;
      if (index >= total) return;
      rY -= GameConstants.Node_Height;
      if (rY < Engine.Screen_Top) return;
      if (rY > Engine.Screen_Bottom) continue;

      if (nodeBlocksVertical(index)) return;
      applyAmbient(
        index: index,
        alpha: alpha,
        interpolation: interpolation++,
      );
    }
  }

  static double getIndexRenderX(int index) =>
      GameConvert.rowColumnToRenderX(getIndexRow(index), getIndexColumn(index));

  static double getIndexRenderY(int index) =>
      GameConvert.rowColumnZToRenderY(getIndexRow(index), getIndexColumn(index), getIndexZ(index));

  static void applyAmbient({
    required int index,
    required int alpha,
    required int interpolation,
  }){

    // if (index < 0) return;
    // if (index >= total - 1) return;
    // if (index >= 19999) return;
    // assert (isIndexOnScreen(index));

    // final row = getIndexRow(index);
    // final column = getIndexColumn(index);

    // final renderX = GameConvert.rowColumnToRenderX(row, column);
    // if (renderX < Engine.Screen_Left) {
    //   // TODO Remove
    //   return;
    // }
    // if (renderX > Engine.Screen_Right) {
    //   // TODO Remove
    //   return;
    // }
    //
    // final renderY = GameConvert.rowColumnZToRenderY(row, column, getIndexZ(index));
    // if (renderY < Engine.Screen_Top) {
    //   // TODO Remove
    //   return;
    // }
    // if (renderY > Engine.Screen_Bottom) {
    //   // TODO Remove
    //   return;
    // }
    //
    // if (!isIndexOnScreen(index)){
    //   offscreenNodes++;
    //   return;
    // } else {
    //   onscreenNodes++;
    // }
    colorStack[colorStackIndex++] = index;
    final intensity = 1.0 - interpolations[interpolation];
    final interpolatedAlpha = alpha * intensity;
    final currentAlpha = hsv_alphas[index];
    if (currentAlpha < interpolatedAlpha) return;
    hsv_alphas[index] = Engine.linerInterpolationInt(hsv_alphas[index], alpha, intensity);
    refreshNodeColor(index);
  }

  static bool nodeBlocksNorthSouth(int index) => (const [
        NodeOrientation.Solid,
        NodeOrientation.Half_North,
        NodeOrientation.Half_South,
        NodeOrientation.Slope_North,
        NodeOrientation.Slope_South,
        NodeOrientation.Radial,
  ].contains(nodeOrientations[index])) && !nodeTypeTransient(index);

  static bool nodeBlocksEastWest(int index) => (const [
    NodeOrientation.Solid,
    NodeOrientation.Half_East,
    NodeOrientation.Half_West,
    NodeOrientation.Slope_East,
    NodeOrientation.Slope_West,
    NodeOrientation.Radial,
  ].contains(nodeOrientations[index])) && !nodeTypeTransient(index);

  static bool nodeTypeTransient(int index){
    return const [
      NodeType.Window,
      NodeType.Wooden_Plank,
      NodeType.Torch,
    ].contains(nodeTypes[index]);
  }

  static bool nodeBlocksVertical(int index) => (const [
      NodeOrientation.Solid,
      NodeOrientation.Radial,
      NodeOrientation.Half_Vertical_Top,
      NodeOrientation.Half_Vertical_Center,
      NodeOrientation.Half_Vertical_Bottom,
  ].contains(nodeOrientations[index])) && !nodeTypeTransient(index);

  static bool isIndexOnScreen(int index){

    final row = getIndexRow(index);
    final column = getIndexColumn(index);

    final renderX = GameConvert.rowColumnToRenderX(row, column);
    if (renderX < Engine.Screen_Left) return false;
    if (renderX > Engine.Screen_Right) return false;

    final renderY = GameConvert.rowColumnZToRenderY(row, column, getIndexZ(index));
    if (renderY < Engine.Screen_Top) return false;
    if (renderY > Engine.Screen_Bottom) return false;

    return true;
  }
}


