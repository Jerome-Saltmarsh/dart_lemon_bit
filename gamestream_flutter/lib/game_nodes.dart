
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:gamestream_flutter/functions/hsv_to_color.dart';
import 'package:gamestream_flutter/library.dart';

class GameNodes {

  // VARIABLES

  static var ambient_color_hsv  = HSVColor.fromColor(Color.fromRGBO(31, 1, 86, 0.5));
  static var ambient_hue        = ((ambient_color_hsv.hue / 360) * 255).round();
  static var ambient_sat        = (ambient_color_hsv.saturation * 255).round();
  static var ambient_val        = (ambient_color_hsv.value * 255).round();
  static var ambient_alp        = (ambient_color_hsv.alpha * 255).round();
  static var ambient_color      = 0;

  static var node_colors = Uint32List(0);
  static var hsv_hue = Uint8List(0);
  static var hsv_saturation = Uint8List(0);
  static var hsv_values = Uint8List(0);
  static var hsv_alphas = Uint8List(0);
  static var nodeOrientations = Uint8List(0);
  static var nodeTypes = Uint8List(0);
  static var nodeVariations = Uint8List(0);
  static var colorStack = Uint16List(0);
  static var ambientStack = Uint16List(0);
  static var miniMap = Uint8List(0);
  static var heightMap = Uint16List(0);
  static var colorStackIndex = -1;
  static var ambientStackIndex = -1;
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

  // CONSTANTS

  static var interpolation_length = 6;
  static final Watch<EaseType> interpolation_ease_type = Watch(EaseType.Out_Quad, onChanged: (EaseType easeType){
    interpolations = easeType.generate(
      length: interpolation_length,
    );
  });

  static var interpolations = interpolation_ease_type.value.generate(
      length: interpolation_length,
  );

  static void setInterpolationLength(int value){
     if (value < 1) return;
     if (interpolation_length == value) return;
     interpolation_length = value;
     interpolations = interpolation_ease_type.value.generate(
       length: interpolation_length,
     );
  }

  // FUNCTIONS

  static void resetNodeColorsToAmbient() {
    GameNodes.ambient_alp = clamp(GameNodes.ambient_alp, 0, 255);
    ambient_color = hsvToColor(
        hue: ambient_hue,
        saturation: ambient_sat,
        value: ambient_val,
        opacity: ambient_alp
    );
    colorStackIndex = -1;

    if (node_colors.length != total) {
      colorStack = Uint16List(total);
      node_colors = Uint32List(total);
      hsv_hue = Uint8List(total);
      hsv_saturation = Uint8List(total);
      hsv_values = Uint8List(total);
      hsv_alphas = Uint8List(total);
    }
    for (var i = 0; i < total; i++) {
      node_colors[i] = ambient_color;
      hsv_hue[i] = ambient_hue;
      hsv_saturation[i] = ambient_sat;
      hsv_values[i] = ambient_val;
      hsv_alphas[i] = ambient_alp;
    }
  }

  static int getHeightAt(int row, int column){
    var i = total - area + ((row * totalColumns) + column);
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
      node_colors[i] = ambient_color;
      hsv_hue[i] = ambient_hue;
      hsv_saturation[i] = ambient_sat;
      hsv_values[i] = ambient_val;
      hsv_alphas[i] = ambient_alp;
      colorStackIndex--;
    }
    colorStackIndex = -1;
  }

  static void resetNodeAmbientStack() {
    while (ambientStackIndex >= 0) {
      final i = ambientStack[ambientStackIndex];
      node_colors[i] = ambient_color;
      hsv_alphas[i] = ambient_alp;
      ambientStackIndex--;
    }
    ambientStackIndex = -1;
  }



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

    if (GameSettings.Dynamic_Shadows) {
      emitLightAHSV(
        index: index,
        alpha: alpha,
        hue: hue,
        saturation: saturation,
        value: value,
      );
      return;
    }

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

          colorStackIndex++;
          colorStack[colorStackIndex] = nodeIndex;

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
      emitLightAmbientShadows(
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
          ambientStackIndex++;
          ambientStack[ambientStackIndex] = nodeIndex;

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
    node_colors[index] = hsvToColor(
      hue: hsv_hue[index],
      saturation: hsv_saturation[index],
      value: hsv_values[index],
      opacity: hsv_alphas[index],
    );

  static void refreshNodeColor2(int index) =>
      node_colors[index] = hsvToColor2(
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

    shadow.x = vx;
    shadow.y = vy;
    shadow.z = getAngle(vx, vy);
 }

  static int getIndexRow(int index) => (index % area) ~/ totalColumns;
  static int getIndexZ(int index) => index ~/ area;
  static int getIndexColumn(int index) => index % totalColumns;


  /// EMIT LIGHT FUNCTIONS

  static void emitLightAHSV({
    required int index,
    required int alpha,
    required int hue,
    required int saturation,
    required int value,
  }){
    if (index < 0) return;
    if (index >= total) return;

    final padding = ClientState.interpolation_padding;
    final rx = getIndexRenderX(index);
    if (rx < Engine.Screen_Left - padding) return;
    if (rx > Engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < Engine.Screen_Top - padding) return;
    if (ry > Engine.Screen_Bottom + padding) return;

    ClientState.lights_active++;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final z = getIndexZ(index);

    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!isNodeTypeTransient(nodeType)){
      if (const [
        NodeOrientation.Half_North,
        NodeOrientation.Corner_Top,
        NodeOrientation.Corner_Left
      ].contains(nodeOrientation)) {
        vxStart = 0;
      }

      if (const [
        NodeOrientation.Half_South,
        NodeOrientation.Corner_Bottom,
        NodeOrientation.Corner_Right
      ].contains(nodeOrientation)) {
        vxEnd = 0;
      }

      if (const [
        NodeOrientation.Half_East,
        NodeOrientation.Corner_Top,
        NodeOrientation.Corner_Right
      ].contains(nodeOrientation)) {
        vyStart = 0;
      }

      if (const [
        NodeOrientation.Half_West,
        NodeOrientation.Corner_Bottom,
        NodeOrientation.Corner_Left
      ].contains(nodeOrientation)) {
        vyEnd = 0;
      }
    }

    applyAHSV(
      index: index,
      alpha: alpha,
      interpolation: 0,
      hue: hue,
      saturation: saturation,
      value: value,
    );

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAHSV(
            row: row,
            column: column,
            z: z,
            interpolation: -1,
            alpha: alpha,
            hue: hue,
            saturation: saturation,
            value: value,
            vx: vx,
            vy: vy,
            vz: vz,
          );
        }
      }
    }
  }

  static void emitLightAmbientShadows({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= total) return;

    final padding = ClientState.interpolation_padding;
    final rx = getIndexRenderX(index);
    if (rx < Engine.Screen_Left - padding) return;
    if (rx > Engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < Engine.Screen_Top - padding) return;
    if (ry > Engine.Screen_Bottom + padding) return;

    ClientState.lights_active++;

    final row = getIndexRow(index);
    final column = getIndexColumn(index);
    final z = getIndexZ(index);

    final nodeType = nodeTypes[index];
    final nodeOrientation = nodeOrientations[index];

    var vxStart = -1;
    var vxEnd = 1;
    var vyStart = -1;
    var vyEnd = 1;

    if (!isNodeTypeTransient(nodeType)){
      if (const [
        NodeOrientation.Half_North,
        NodeOrientation.Corner_Top,
        NodeOrientation.Corner_Left
      ].contains(nodeOrientation)) {
        vxStart = 0;
      }

      if (const [
        NodeOrientation.Half_South,
        NodeOrientation.Corner_Bottom,
        NodeOrientation.Corner_Right
      ].contains(nodeOrientation)) {
        vxEnd = 0;
      }

      if (const [
        NodeOrientation.Half_East,
        NodeOrientation.Corner_Top,
        NodeOrientation.Corner_Right
      ].contains(nodeOrientation)) {
        vyStart = 0;
      }

      if (const [
        NodeOrientation.Half_West,
        NodeOrientation.Corner_Bottom,
        NodeOrientation.Corner_Left
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
  static void shootLightTreeAmbient({
    required int row,
    required int column,
    required int z,
    required int interpolation,
    required int alpha,
    int vx = 0,
    int vy = 0,
    int vz = 0,
  }){
    assert (interpolation < interpolation_length);

    var velocity = vx.abs() + vy.abs() + vz.abs();
    var paintBehindZ = vz == 0;
    var paintBehindRow = vx == 0;
    var paintBehindColumn = vy == 0;

    while (interpolation < interpolation_length) {

      if (velocity == 0) return;

      interpolation += velocity;
      if (interpolation >= interpolation_length) return;

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

       if (!isNodeTypeTransient(nodeType)) {

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
               NodeOrientation.Corner_Bottom,
               NodeOrientation.Half_South,
               NodeOrientation.Half_West,
             ].contains(nodeOrientation)){
               applyAmbient(
                 index: index - area,
                 alpha: alpha,
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
             if (nodeOrientation == NodeOrientation.Corner_Top && vy < 0){
               paintBehindZ = true;
             }
           } else {
             if (nodeOrientation == NodeOrientation.Half_South){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Right && vy <= 0){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Bottom && vy >= 0){
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
             if (nodeOrientation == NodeOrientation.Corner_Top && vx2 <= 0){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Bottom && vx2 >= 0){
               paintBehindZ = true;
             }
           } else {
             if (nodeOrientation == NodeOrientation.Half_West){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Left && vx2 <= 2){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Bottom && vx2 >= 0){
               paintBehindZ = true;
             }
           }
           vy = 0;
         }

         if (vx == 1 && vy == 1 && vz == 0 && nodeOrientation == NodeOrientation.Column_Top_Left){
           return;
         }
       }

      applyAmbient(index: index, alpha: alpha, interpolation: interpolation);

      if (paintBehindZ) {
        applyAmbient(
          index: index - area,
          alpha: alpha,
          interpolation: interpolation,
        );
      }


      if (paintBehindRow) {
        applyAmbient(
          index: index - totalColumns,
          alpha: alpha,
          interpolation: interpolation,
        );
      }

      if (paintBehindColumn) {
        applyAmbient(
          index: index - 1,
          alpha: alpha,
          interpolation: interpolation,
        );
      }


        if (const [
        NodeType.Grass_Long,
        NodeType.Tree_Bottom,
        NodeType.Tree_Top,
      ].contains(nodeType)){
        interpolation += 2;
        if (interpolation >= interpolation_length) return;
      }

      if (velocity > 1) {
         if (vx != 0){
           shootLightTreeAmbient(row: row, column: column, z: z, interpolation: interpolation, alpha: alpha, vx: vx);
         }
         if (vy != 0){
           shootLightTreeAmbient(row: row, column: column, z: z, interpolation: interpolation, alpha: alpha, vy: vy);
         }
         if (vz != 0){
           shootLightTreeAmbient(row: row, column: column, z: z, interpolation: interpolation, alpha: alpha, vz: vz);
         }
       }
    }
  }

  static void shootLightTreeAHSV({
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
    assert (interpolation < interpolation_length);

    var velocity = vx.abs() + vy.abs() + vz.abs();
    var paintBehindZ = vz == 0;
    var paintBehindRow = vx == 0;
    var paintBehindColumn = vy == 0;

    while (interpolation < interpolation_length) {

      if (velocity == 0) return;

      interpolation += velocity;
      if (interpolation >= interpolation_length) return;

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

       if (!isNodeTypeTransient(nodeType)) {

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
               NodeOrientation.Corner_Bottom,
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
             if (nodeOrientation == NodeOrientation.Corner_Top && vy < 0){
               paintBehindZ = true;
             }
           } else {
             if (nodeOrientation == NodeOrientation.Half_South){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Right && vy <= 0){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Bottom && vy >= 0){
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
             if (nodeOrientation == NodeOrientation.Corner_Top && vx2 <= 0){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Bottom && vx2 >= 0){
               paintBehindZ = true;
             }
           } else {
             if (nodeOrientation == NodeOrientation.Half_West){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Left && vx2 <= 2){
               paintBehindZ = true;
             } else
             if (nodeOrientation == NodeOrientation.Corner_Bottom && vx2 >= 0){
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
        if (interpolation >= interpolation_length) return;
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
         if (vy != 0){
           shootLightTreeAHSV(row: row, column: column, z: z, interpolation: interpolation, alpha: alpha, hue: hue, saturation: saturation, value: value,  vy: vy);
         }
         if (vz != 0){
           shootLightTreeAHSV(row: row, column: column, z: z, interpolation: interpolation, alpha: alpha, hue: hue, saturation: saturation, value: value, vz: vz);
         }
       }
    }
  }

  static bool isValidIndex(int index) => index >= 0 && index < total;


  static double getIndexRenderX(int index) =>
      GameConvert.rowColumnToRenderX(getIndexRow(index), getIndexColumn(index));

  static double getIndexRenderY(int index) =>
      GameConvert.rowColumnZToRenderY(getIndexRow(index), getIndexColumn(index), getIndexZ(index));

  static void applyAmbient({
    required int index,
    required int alpha,
    required int interpolation,
  }){
    if (index < 0) return;
    if (index >= total) return;

    final intensity = interpolations[interpolation < 0 ? 0 : interpolation];
    final interpolatedAlpha = Engine.linerInterpolationInt(alpha, ambient_alp, intensity);;
    final currentAlpha = hsv_alphas[index];
    if (currentAlpha <= interpolatedAlpha) return;
    final currentHue = hsv_hue[index];
    if (currentHue != ambient_hue) return;
    ambientStackIndex++;
    ambientStack[ambientStackIndex] = index;
    hsv_alphas[index] = interpolatedAlpha;
    refreshNodeColor(index);
  }

  static void applyAHSV({
    required int index,
    required int alpha,
    required int hue,
    required int saturation,
    required int value,
    required int interpolation,
  }){
    if (index < 0) return;
    if (index >= total) return;

    final intensity = interpolations[interpolation < 0 ? 0 : interpolation];

    // var a = hsv_alphas[index];
    // final indexHue = hsv_hue[index];
    // if (indexHue == ambient_hue){
    //   a = ambient_alp;
    // }

    final interpolatedA = Engine.linerInterpolationInt(alpha, hsv_alphas[index], intensity);
    final interpolatedH = Engine.linerInterpolationInt(hue, hsv_hue[index], intensity);
    final interpolatedS = Engine.linerInterpolationInt(saturation, hsv_saturation[index], intensity);
    final interpolatedV = Engine.linerInterpolationInt(value, hsv_values[index], intensity);
    colorStackIndex++;
    colorStack[colorStackIndex] = index;
    hsv_alphas[index] = interpolatedA;
    hsv_hue[index] = interpolatedH;
    hsv_saturation[index] = interpolatedS;
    hsv_values[index] = interpolatedV;
    refreshNodeColor2(index);
  }

  static bool nodeOrientationBlocksNorthSouth(int nodeOrientation) => const [
        NodeOrientation.Solid,
        NodeOrientation.Half_North,
        NodeOrientation.Half_South,
        NodeOrientation.Slope_North,
        NodeOrientation.Slope_South,
        NodeOrientation.Corner_Top,
        NodeOrientation.Corner_Right,
        NodeOrientation.Corner_Bottom,
        NodeOrientation.Corner_Left,
        NodeOrientation.Radial,
  ].contains(nodeOrientation);

  static bool nodeOrientationBlocksEastWest(int value) => const [
    NodeOrientation.Solid,
    NodeOrientation.Half_East,
    NodeOrientation.Half_West,
    NodeOrientation.Slope_East,
    NodeOrientation.Slope_West,
    NodeOrientation.Corner_Top,
    NodeOrientation.Corner_Right,
    NodeOrientation.Corner_Bottom,
    NodeOrientation.Corner_Left,
    NodeOrientation.Radial,
  ].contains(value);

  static bool isNodeTypeTransient(int nodeType) => const [
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

  static bool nodeOrientationBlocksVertical(int nodeOrientation) => (const [
      NodeOrientation.Solid,
      NodeOrientation.Radial,
      NodeOrientation.Half_Vertical_Top,
      NodeOrientation.Half_Vertical_Center,
      NodeOrientation.Half_Vertical_Bottom,
  ]).contains(nodeOrientation);

  static bool nodeOrientationBlocksVerticalDown(int nodeOrientation) => (const [
    NodeOrientation.Solid,
    NodeOrientation.Half_Vertical_Top,
    NodeOrientation.Half_Vertical_Center,
    NodeOrientation.Half_Vertical_Bottom,
  ]).contains(nodeOrientation);

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


