
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:gamestream_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/renderer_nodes.dart';
import 'package:gamestream_flutter/gamestream/isometric/functions/src.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:gamestream_flutter/packages/common.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_watch/src.dart';
import 'package:gamestream_flutter/isometric/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/packages/lemon_components.dart';

import '../../../isometric/classes/position.dart';
import 'render/classes/bool_list.dart';

class IsometricScene with IsometricComponent implements Updatable {

  var _ambientAlpha = 0;

  var marks = Uint32List(0);
  var interpolationPadding = 0.0;
  var nextLightingUpdate = 0;
  var framesPerSmokeEmission = 10;
  var nextEmissionSmoke = 0;
  var totalProjectiles = 0;
  var bakeStackTotal = 0;
  var bakeStackIndex = Uint16List(100000);
  var bakeStackBrightness = Uint8ClampedList(100000);
  var bakeStackStartIndex = Uint16List(10000);
  var bakeStackTorchIndex = Uint16List(10000);
  var bakeStackTorchSize = Uint16List(10000);
  var bakeStackTorchTotal = 0;
  var totalCharacters = 0;
  var bakeStackRecording = true;
  var totalActiveLights = 0;
  var ambientColor = const Color.fromRGBO(31, 1, 86, 0.5).value;
  var ambientResetIndex = 0;
  var ambientStack = Uint16List(0);
  var ambientStackIndex = -1;
  var colorStack = Uint16List(0);
  var colorStackIndex = -1;
  var smokeSources = Uint16List(500);
  var smokeSourcesTotal = 0;
  var nodeLightSources = Uint16List(1000);
  var nodeLightSourcesTotal = 0;
  var nodeColors = Uint32List(0);
  var nodeOrientations = Uint8List(0);
  var nodeVisibility = Uint8List(0);
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
  var ambientRGB = 0;
  var interpolationLength = 6;
  var interpolations = <double>[];

  final marksChangedNotifier = Watch(0);
  final interpolationEaseType = Watch(EaseType.In_Quad);
  final sceneEditable = Watch(false);
  final nodesChangedNotifier = Watch(0);
  final characters = <Character>[];
  final gameObjects = <GameObject>[];
  final projectiles = <Projectile>[];

  IsometricScene(){
    interpolationEaseType.onChanged(onChangedInterpolationEaseType);
    ambientRGB = getRGB(ambientColor);
    interpolations = interpolateEaseType(
      length: interpolationLength,
      easeType: interpolationEaseType.value,
    );
    marksChangedNotifier.onChanged(onChangedMarks);
  }

  void onChangedMarks(int count){
    final particles = this.particles;
    particles.children.removeWhere((element) => element is ParticleRoam);
    particles.mystIndexes.clear();
    for (final markValue in marks) {
      final markType = MarkType.getType(markValue);
      final markIndex = MarkType.getIndex(markValue);
      final x = getIndexPositionX(markIndex);
      final y = getIndexPositionY(markIndex);
      final z = getIndexPositionZ(markIndex);

      switch (markType){
        case MarkType.Spawn_Whisp:
          particles.spawnWhisp(x: x, y: y, z: z);
          break;
        case MarkType.Glow:
          particles.spawnGlow(x: x, y: y, z: z);
          break;
        case MarkType.Spawn_Myst:
          particles.mystIndexes.add(markIndex);
          break;
        case MarkType.Butterfly:
          particles.spawnButterfly(x: x, y: y, z: z);
          break;
      }
    }
  }

  void onChangedInterpolationEaseType(EaseType easeType){
    interpolations = interpolateEaseType(
      length: interpolationLength,
      easeType: EaseType.In_Out_Quad,
    );
  }

  void setInterpolationLength(int value){
    if (value < 1 || interpolationLength == value)
      return;

    interpolationLength = value;
    interpolations = interpolateEaseType(
      length: interpolationLength,
      easeType: interpolationEaseType.value,
    );
  }

  int get ambientAlpha => _ambientAlpha;

  set ambientAlpha(int value){
    final clampedValue = value.clamp(0, 255);

    if (clampedValue == _ambientAlpha)
      return;

    ambientResetIndex = 0;
    _ambientAlpha = clampedValue;
    ambientColor = setAlpha(color: ambientColor, alpha: clampedValue);
  }

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
    ambientResetIndex = 0;
    colorStackIndex = -1;
  }

  void onComponentUpdate(){
    interpolationPadding = ((scene.interpolationLength + 1) * Node_Size) / engine.zoom;

    jobBatchResetNodeColorsToAmbient();
    updateProjectiles();
    updateGameObjects();
    updateParticleSmokeEmitters();

    if (nextLightingUpdate-- <= 0) {
      nextLightingUpdate = options.framesPerLightingUpdate;
      scene.updateAmbientAlphaAccordingToTime();
    }
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

  // TODO OPTIMIZE
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

  int getHeightAt(int row, int column){
    var i = totalNodes - area + ((row * totalColumns) + column);
    for (var z = totalZ - 1; z >= 0; z--){

      if (nodeOrientations[i] != NodeOrientation.None) {
        if (!const [
          NodeType.Tree_Bottom,
          NodeType.Tree_Top,
          NodeType.Torch,
          NodeType.Boulder,
        ].contains(nodeTypes[i])) {
          return z;
        }
      }

      i -= area;
    }
    return 0;
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
    var stackI = colorStackIndex;
    final ambientColor = this.ambientColor;
    while (stackI >= 0) {
      final i = colorStack[stackI];
      nodeColors[i] = ambientColor;
      stackI--;
    }
    colorStackIndex = -1;
  }

  void resetNodeAmbientStack() {
    var stackI = this.ambientStackIndex; // cache in cpu
    final ambientColor = this.ambientColor; // cache in cpu
    final ambientStack = this.ambientStack; // cache in cpu
    final nodeColors = this.nodeColors;
    while (stackI >= 0) {
      final index = ambientStack[stackI];
      nodeColors[index] = ambientColor;
      stackI--;
    }
    this.ambientStackIndex = -1;
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
      nodeVariations[i] = randomInt(0, 255);
    }
  }

  int getRow(int index) => (index % area) ~/ totalColumns;

  int getIndexZ(int index) => index ~/ area;

  int getColumn(int index) => index % totalColumns;

  int getRowColumn(int index)=> getRow(index) + getColumn(index);

  bool isValidIndex(int index) => index >= 0 && index < totalNodes;

  double getIndexRenderX(int index) =>
      getRenderXOfRowAndColumn(
          getRow(index),
          getColumn(index),
      );

  double getIndexRenderY(int index) =>
      getRenderYOfRowColumnZ(getRow(index), getColumn(index), getIndexZ(index));


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
    print('scene.refreshLightSources() - (EXPENSIVE)');
    nodeLightSourcesTotal = 0;
    for (var i = 0; i < totalNodes; i++) {

      if (!NodeType.isLightSource(nodeTypes[i]))
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
       final lightSourceRow = getRow(lightSourceIndex);
       final lightSourceColumn = getColumn(lightSourceIndex);
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

  int getColor(int index )=>
      index < 0 || index >= totalNodes ? ambientColor : nodeColors[index];

  double getIndexPositionX(int index) =>
      (getRow(index) * Node_Size) + Node_Size_Half;

  double getIndexPositionY(int index) =>
      (getColumn(index) * Node_Size) + Node_Size_Half;

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
    final nodeColors = this.nodeColors;

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
    nodeColors[index] = int32(
      interpolatedAlpha,
      interpolatedRed,
      interpolatedGreen,
      interpolatedBlue,
    );
  }

  void applyAmbient({
    required int index,
    required int alpha,
    required int ambientRGB,
    required int ambientAlpha,
    required Uint32List nodeColors,
    required Uint16List ambientStack,
    required int ambientStackIndex,
  }){
    assert (index >= 0);
    assert (index < totalNodes);

    if (alpha < 0 || alpha > 255){
      print('applyAmbient() invalid alpha: $alpha');
    }

    final currentColor = nodeColors[index];
    final currentAlpha =  (currentColor & 0xFF000000) >> 24;
    if (currentAlpha <= alpha) {
      return;
    }

    final currentRGB = getRGB(currentColor);
    if (currentRGB != ambientRGB){
      final currentIntensity = (ambientAlpha - currentAlpha) / 128;
      final alphaBlend = 1.0 - currentIntensity;
      alpha = interpolate(currentAlpha, alpha, alphaBlend).toInt();
      if (alpha < 0 || alpha > 255){
        print('applyAmbient() invalid alpha: $alpha');
      }
      if (currentAlpha <= alpha) {
        return;
      }
    }

    if (alpha < 0 || alpha > 255){
      print('applyAmbient() invalid alpha: $alpha');
    }

    ambientStack[ambientStackIndex] = index;
    nodeColors[index] = setAlpha(color: currentColor, alpha: alpha);
  }

  void updateCharacterColors(){
    for (var i = 0; i < totalCharacters; i++){
      final character = characters[i];
      character.color =  getRenderColorPosition(character);
    }
  }

  Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  void applyEmissionsCharacters() {
    final alpha = lighting.emissionAlphaCharacter;
    for (var i = 0; i < totalCharacters; i++) {
      final character = characters[i];

      if (const [
        CharacterType.Fallen,
      ].contains(character.characterType))
        continue;

      applyVector3EmissionAmbient(
        character,
        alpha: alpha,
      );
    }
  }

  void applyVector3EmissionAmbient(Position v, {
    required int alpha,
    double intensity = 1.0,
  }){
    assert (intensity >= 0);
    assert (intensity <= 1);
    assert (alpha >= 0);
    assert (alpha <= 255);
    if (!inBoundsPosition(v)) return;
    emitLight(
      index: getIndexPosition(v),
      value: alpha,
      intensity: intensity,
      ambient: true,
    );
  }

  void emitLight({
    required int index,
    required int value,
    required double intensity,
    required bool ambient,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final padding = interpolationPadding;
    final minRenderX = engine.Screen_Left - padding;
    final maxRenderX = engine.Screen_Right + padding;
    final minRenderY = engine.Screen_Top - padding;
    final maxRenderY = engine.Screen_Bottom + padding;

    if (!bakeStackRecording){
      final rx = getIndexRenderX(index);
      if (rx < minRenderX) return;
      if (rx > maxRenderX) return;
      final ry = getIndexRenderY(index);
      if (ry < engine.Screen_Top - padding) return;
      if (ry > engine.Screen_Bottom + padding) return;
    }

    totalActiveLights++;

    final row = getRow(index);
    final column = getColumn(index);
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

    final resursive = options.emitLightsUsingRecursion;
    final brightness = 7;
    final stackA = this.emitLightBeamStackA;
    final stackB = this.emitLightBeamStackB;
    this.emitLightBeamStackTotal = 0;

    var total = 0;

    if (resursive){
      for (var vz = -1; vz <= 1; vz++){
        for (var vx = vxStart; vx <= vxEnd; vx++){
          for (var vy = vyStart; vy <= vyEnd; vy++){
            emitLightBeamRecursive(
                row: row,
                column: column,
                z: z,
                brightness: brightness,
                vx: vx,
                vy: vy,
                vz: vz,
                value: value,
                intensity: intensity,
                minRenderX: minRenderX,
                maxRenderX: maxRenderX,
                minRenderY: minRenderY,
                maxRenderY: maxRenderY,
                recordMode: bakeStackRecording,
                ambient: ambient,
            );
          }
        }
      }
    } else {
      for (var vz = -1; vz <= 1; vz++){
        final vzByte = signToByte(vz) << 4;
        for (var vy = vyStart; vy <= vyEnd; vy++){
          final vyByte = signToByte(vy) << 2;
          for (var vx = vxStart; vx <= vxEnd; vx++){
              stackB[total++] =
                signToByte(vx) |
                vyByte |
                vzByte ;
            }
          }
      }

      stackA.fillRange(0, total, row | column << 8 | z << 16 | brightness << 24);
      emitLightBeamStackTotal = total;

      emitLightBeam(
        value: value,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: bakeStackRecording,
      );
      emitLightBeamStackTotal = 0;
    }
  }

  void applyEmissionBakeStack() {
    final ambientAlpha = this.ambientAlpha;
    final ambientRGB = this.ambientRGB;

    final ambient = ambientAlpha.clamp(0, 255);
    final alpha = interpolate(
      ambient,
      0,
      lighting.torchEmissionIntensityAmbient,
    ).toInt().clamp(0, 255);

    final total =  bakeStackTorchTotal;
    final stack = bakeStackTorchIndex;

    const padding = Node_Size * 6;
    final screenLeft = engine.Screen_Left - padding;
    final screenTop = engine.Screen_Top - padding;
    final screenRight = engine.Screen_Right + padding;
    final screenBottom = engine.Screen_Bottom + padding;
    final bakeStackIndex = this.bakeStackIndex;
    final bakeStackBrightness = this.bakeStackBrightness;
    final interpolations = this.interpolations;
    final nodeColors = this.nodeColors;
    final ambientStack = this.ambientStack;
    final bakeStackStartIndex = this.bakeStackStartIndex;
    final bakeStackTorchSize = this.bakeStackTorchSize;

    var ambientStackIndex = this.ambientStackIndex;

    final totalColumns = this.totalColumns;
    final area = this.area;

    for (var i = 0; i < total; i++){
      final index = stack[i];

      final row = (index % area) ~/ totalColumns;
      final column = index % totalColumns;

      final renderX = (row - column) * Node_Size_Half;
      if (renderX < screenLeft || renderX > screenRight){
        continue;
      }

      final renderY = (row + column) * Node_Size_Half;
      if (renderY > screenBottom && renderY < screenTop){
        continue;
      }

      final start = bakeStackStartIndex[i];
      final size = bakeStackTorchSize[i];
      final end = start + size;

      for (var j = start; j < end; j++){
        final brightness = bakeStackBrightness[j];
        final index = bakeStackIndex[j];
        final intensity = brightness > 5 ? 1.0 : interpolations[brightness];
        ambientStackIndex++;
        applyAmbient(
          index: index,
          alpha: interpolate(ambient, alpha, intensity).toInt().clamp(0, 255),
          ambientAlpha: ambientAlpha,
          ambientRGB: ambientRGB,
          nodeColors: nodeColors,
          ambientStack: ambientStack,
          ambientStackIndex: ambientStackIndex,
        );
      }
    }

    this.ambientStackIndex = ambientStackIndex;
  }

  void applyEmissionEditorSelectedNode() {
    if (!options.editMode) return;
    if (( editor.gameObject.value == null ||  editor.gameObject.value!.colorType == EmissionType.None)){
      emitLight(
        index:  editor.nodeSelectedIndex.value,
        value: 0,
        intensity: 1.0,
        ambient: true,
      );
    }
  }

  final emitLightBeamStackA = Uint32List(100000);
  final emitLightBeamStackB = Uint32List(100000);
  var emitLightBeamStackTotal = 0;

  void emitLightBeam({
    required int value,
    required double intensity,
    required double minRenderX,
    required double maxRenderX,
    required double minRenderY,
    required double maxRenderY,
    required bool recordMode,
    required bool ambient,
  }){
    final area = this.area;
    final rows = totalRows;
    final columns = totalColumns;
    final zs = totalZ;
    final ambientAlpha = this.ambientAlpha;
    final ambientRGB = this.ambientRGB;
    final nodeColors = this.nodeColors;
    final ambientStack = this.ambientStack;
    final interpolations = this.interpolations;
    final nodeTypes = this.nodeTypes;
    final nodeOrientations = this.nodeOrientations;
    final stackA = this.emitLightBeamStackA;
    final stackB = this.emitLightBeamStackB;

    var stackFrame = 0;
    var stackValueA = -1;
    var stackValueB = -1;

    var row = -1;
    var column = -1;
    var z = -1;
    var brightness = -1;
    var vxByte = -1;
    var vyByte = -1;
    var vzByte = -1;

    var vx = -1;
    var vy = -1;
    var vz = -1;
    var stackTotal = this.emitLightBeamStackTotal;

    var velocity = -1;

    var ambientStackIndex = this.ambientStackIndex;

    while (stackFrame < stackTotal) {
      
      stackValueA = stackA[stackFrame];
      stackValueB = stackB[stackFrame++];

      row = stackValueA & 0xFF;
      column = (stackValueA >> 8) & 0xFF;
      z = (stackValueA >> 16) & 0xFF;
      brightness = (stackValueA >> 24) & 0xFF;

      vxByte = (stackValueB) & 0x3;
      vyByte = (stackValueB >> 2) & 0x3;
      vzByte = (stackValueB >> 4) & 0x3;

      vx = vxByte == 2 ? -1 : vxByte;
      vy = vyByte == 2 ? -1 : vyByte;
      vz = vzByte == 2 ? -1 : vzByte;
      
      velocity = vx.abs() + vy.abs() + vz.abs();
      brightness -= velocity;

      if (brightness < 0) {
        continue;
      }

      if (vx != 0) {
        row += vx;
        if (row < 0 || row >= rows) {
          continue;
        }
      }

      if (vy != 0) {
        column += vy;
        if (column < 0 || column >= columns){
          continue;
        }
      }

      if (vz != 0) {
        z += vz;
        if (z < 0 || z >= zs) {
          continue;
        }
      }

      final index = (z * area) + (row * columns) + column;

      if (!recordMode) {
        final row =  (index % area) ~/ columns;
        final column = index % columns;
        final renderX = (row - column) * Node_Size_Half;

        if (renderX < minRenderX && (vx < 0 || vy > 0))
          continue;

        if (renderX > maxRenderX && (vx > 0 || vy < 0))
          continue;

        final renderY = getRenderYOfRowColumnZ(
            row,
            column,
            index ~/ area,
        );

        if (renderY < minRenderY && (vx < 0 || vy < 0 || vz > 0))
          continue;

        if (renderY > maxRenderY && (vx > 0 || vy > 0))
          continue;
      }

      final nodeType = nodeTypes[index];
      final nodeOrientation = nodeOrientations[index];

      if (!isNodeTypeTransparent(nodeType)) {
        if (nodeOrientation == NodeOrientation.Solid){
          continue;
        }

        if (vx < 0) {
          if (const [
            NodeOrientation.Half_South,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_South_West,
          ].contains(nodeOrientation)) continue;

          if (nodeOrientation == NodeOrientation.Slope_South && vz == 0){
            continue;
          }

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
          ].contains(nodeOrientation)) continue;

          if (NodeOrientation.Slope_North == nodeOrientation && vz == 0){
            continue;
          }

          if (const [
            NodeOrientation.Half_South,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_South_West,
            NodeOrientation.Slope_South,
          ].contains(nodeOrientation)){
            vx = 0;
          }
        }

        if (vy < 0) {
          if (const [
            NodeOrientation.Half_West,
            NodeOrientation.Corner_North_West,
            NodeOrientation.Corner_South_West,
          ].contains(nodeOrientation)) {
            continue;
          }

          if (nodeOrientation == NodeOrientation.Slope_West && vz == 0){
            continue;
          }

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
          ].contains(nodeOrientation)) continue;

          if (nodeOrientation == NodeOrientation.Slope_East && vz == 0){
            continue;
          }

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
            continue;
          }

          if (const [
            NodeOrientation.Half_Vertical_Bottom,
            NodeOrientation.Half_Vertical_Center,
          ].contains(nodeOrientation)) {
            vz = 0;
          }
        }

        if (vz > 0) {
          if (const [
            NodeOrientation.Half_Vertical_Top
          ].contains(nodeOrientation)) {
            continue;
          }

          if (const [
            NodeOrientation.Half_Vertical_Top,
            NodeOrientation.Half_Vertical_Center,
          ].contains(nodeOrientation)) {
            vz = 0;
          }
        }
      }

      if (ambient){
        ambientStackIndex++;
        applyAmbient(
          index: index,
          alpha: interpolate(ambientAlpha, value, brightness > 5 ? 1.0 : interpolations[brightness]).toInt(),
          ambientRGB: ambientRGB,
          ambientAlpha: ambientAlpha,
          nodeColors: nodeColors,
          ambientStack: ambientStack,
          ambientStackIndex: ambientStackIndex,
        );
      } else {
        applyColor(
          index: index,
          intensity: (brightness > 5 ? 1.0 : interpolations[brightness]) * intensity,
          color: value,
        );
      }

      if (recordMode) {
        bakeStackIndex[bakeStackTotal] = index;
        bakeStackBrightness[bakeStackTotal] = brightness;
        bakeStackTotal++;
      }

      if (const [
        NodeType.Grass_Long,
        NodeType.Tree_Bottom,
        NodeType.Tree_Top,
      ].contains(nodeType)) {
        brightness--;
        if (brightness < 0){
          continue;
        }
      }

      velocity = vx.abs() + vy.abs() + vz.abs();

      if (velocity <= 0) {
        continue;
      }

      vxByte = vx == -1 ? 2 : vx;
      vyByte = vy == -1 ? 2 : vy;
      vzByte = vz == -1 ? 2 : vz;

      assert (vxByte <= 2);
      assert (vyByte <= 2);
      assert (vzByte <= 2);

      if (vx.abs() + vy.abs() + vz.abs() == 3) {

        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          vxByte << 0 |
          vyByte << 2 |
          vzByte << 4 ;

      }

      if (vx.abs() + vy.abs() == 2) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          vxByte << 0 |
          vyByte << 2 ;
          // signToByte(0) << 4 ;
      }

      if (vx.abs() + vz.abs() == 2) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          vxByte << 0 |
          // signToByte(0) << 2 |
          vzByte << 4 ;
      }

      if (vy.abs() + vz.abs() == 2) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          // signToByte(vx) << 0 |
          vyByte << 2 |
          vzByte << 4 ;
      }

      if (vx != 0) {

        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          vxByte << 0 ;
          // signToByte(0) << 2 |
          // signToByte(vz) << 4 ;
      }

      if (vy != 0) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          // signToByte(vx) << 0 |
          vyByte << 2;
          // signToByte(vz) << 4 ;
      }

      if (vz != 0) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          // signToByte(vx) << 0 |
          // signToByte(0) << 2 |
          vzByte << 4 ;
      }
    }

    this.ambientStackIndex = ambientStackIndex;
  }

  void emitLightBeamRecursive({
    required int row,
    required int column,
    required int z,
    required int brightness,
    required int vx,
    required int vy,
    required int vz,
    required int value,
    required double intensity,
    required double minRenderX,
    required double maxRenderX,
    required double minRenderY,
    required double maxRenderY,
    required bool recordMode,
    required bool ambient,
  }){
    if (brightness < 0)
      return;

    // cache values in cpu
    final area = this.area;
    final rows = totalRows;
    final columns = totalColumns;
    final zs = totalZ;
    final ambientAlpha = this.ambientAlpha;
    final ambientRGB = this.ambientRGB;
    final nodeColors = this.nodeColors;
    final ambientStack = this.ambientStack;
    final interpolations = this.interpolations;
    final nodeTypes = this.nodeTypes;
    final nodeOrientations = this.nodeOrientations;

    while (true) {
      var velocity = vx.abs() + vy.abs() + vz.abs();
      brightness -= velocity;

      if (brightness < 0)
        return;

      if (vx != 0) {
        row += vx;
        if (row < 0 || row >= rows)
          return;
      }

      if (vy != 0) {
        column += vy;
        if (column < 0 || column >= columns)
          return;
      }

      if (vz != 0) {
        z += vz;
        if (z < 0 || z >= zs)
          return;
      }

      final index = (z * area) + (row * columns) + column;

      if (!recordMode) {
        final row =  (index % area) ~/ columns;
        final column = index % columns;
        final renderX = (row - column) * Node_Size_Half;

        if (renderX < minRenderX && (vx < 0 || vy > 0))
          return;

        if (renderX > maxRenderX && (vx > 0 || vy < 0))
          return;

        final renderY = getRenderYOfRowColumnZ(
          row,
          column,
          index ~/ area,
        );

        if (renderY < minRenderY && (vx < 0 || vy < 0 || vz > 0))
          return;

        if (renderY > maxRenderY && (vx > 0 || vy > 0))
          return;
      }

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
          ].contains(nodeOrientation)) return;

          if (nodeOrientation == NodeOrientation.Slope_South && vz == 0){
            return;
          }

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
          ].contains(nodeOrientation)) return;

          if (NodeOrientation.Slope_North == nodeOrientation && vz == 0){
            return;
          }

          if (const [
            NodeOrientation.Half_South,
            NodeOrientation.Corner_South_East,
            NodeOrientation.Corner_South_West,
            NodeOrientation.Slope_South,
          ].contains(nodeOrientation)){
            vx = 0;
          }
        }

        if (vy < 0) {
          if (const [
            NodeOrientation.Half_West,
            NodeOrientation.Corner_North_West,
            NodeOrientation.Corner_South_West,
          ].contains(nodeOrientation)) {
            return;
          }

          if (nodeOrientation == NodeOrientation.Slope_West && vz == 0){
            return;
          }

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
          ].contains(nodeOrientation)) return;

          if (nodeOrientation == NodeOrientation.Slope_East && vz == 0){
            return;
          }

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
          if (const [
            NodeOrientation.Half_Vertical_Top
          ]
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

      if (ambient){
        ambientStackIndex++;
        applyAmbient(
          index: index,
          alpha: interpolate(ambientAlpha, value, brightness > 5 ? 1.0 : interpolations[brightness]).toInt(),
          ambientRGB: ambientRGB,
          ambientAlpha: ambientAlpha,
          nodeColors: nodeColors,
          ambientStack: ambientStack,
          ambientStackIndex: ambientStackIndex,
        );
      } else {
        applyColor(
          index: index,
          intensity: (brightness > 5 ? 1.0 : interpolations[brightness]) * intensity,
          color: value,
        );
      }

      if (recordMode) {
        bakeStackIndex[bakeStackTotal] = index;
        bakeStackBrightness[bakeStackTotal] = brightness;
        bakeStackTotal++;
      }

      if (const [
        NodeType.Grass_Long,
        NodeType.Tree_Bottom,
        NodeType.Tree_Top,
      ].contains(nodeType)) {
        brightness--;
        if (brightness < 0)
          return;
      }

      velocity = vx.abs() + vy.abs() + vz.abs();

      if (velocity <= 0)
        return;

      if (velocity > 1)
        break;
    }
    if (vx.abs() + vy.abs() + vz.abs() == 3) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: vx,
        vy: vy,
        vz: vz,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }

    if (vx.abs() + vy.abs() == 2) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: vx,
        vy: vy,
        vz: 0,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }

    if (vx.abs() + vz.abs() == 2) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: vx,
        vy: 0,
        vz: vz,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }

    if (vy.abs() + vz.abs() == 2) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: 0,
        vy: vy,
        vz: vz,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }

    if (vy != 0) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: 0,
        vy: vy,
        vz: 0,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }

    if (vx != 0) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: vx,
        vy: 0,
        vz: 0,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }

    if (vz != 0) {
      emitLightBeamRecursive(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        value: value,
        vx: 0,
        vy: 0,
        vz: vz,
        intensity: intensity,
        ambient: ambient,
        minRenderX: minRenderX,
        maxRenderX: maxRenderX,
        minRenderY: minRenderY,
        maxRenderY: maxRenderY,
        recordMode: recordMode,
      );
    }
  }


  void recordBakeStack() {
    print('scene.recordBakeStack()');
    bakeStackRecording = true;
    bakeStackTorchTotal = 0;
    for (var i = 0; i < nodeLightSourcesTotal; i++){
      final nodeIndex = nodeLightSources[i];
      final nodeType = nodeTypes[nodeIndex];
      final alpha = ambientAlpha;

      final currentSize = bakeStackTotal;

      switch (nodeType){
        case NodeType.Torch:
          emitLight(
            index: nodeIndex,
            value: alpha,
            intensity: 1.0,
            ambient: true,
          );
          break;
      }

      bakeStackTorchIndex[bakeStackTorchTotal] = nodeIndex;
      bakeStackStartIndex[bakeStackTorchTotal] = currentSize;
      bakeStackTorchSize[bakeStackTorchTotal] = bakeStackTotal - currentSize;
      bakeStackTorchTotal++;
    }

    bakeStackRecording = false;
  }


  void applyEmissions(){
    totalActiveLights = 0;
    applyEmissionsScene();
    applyEmissionGameObjects();
    applyEmissionsProjectiles();
    applyEmissionsParticles();
    applyEmissionEditorSelectedNode();
    updateCharacterColors();
  }

  void applyEmissionsScene() {
    applyEmissionsColoredLightSources();
    if (bakeStackRecording){
      recordBakeStack();
    } else {
      applyEmissionBakeStack();
    }

    applyEmissionsCharacters();
  }

  void applyEmissionsProjectiles() {
    for (var i = 0; i < totalProjectiles; i++){
      applyProjectileEmission(projectiles[i]);
    }
  }

  void applyProjectileEmission(Projectile projectile) {
    if (projectile.type == ProjectileType.Orb) {
      return;
    }
    if (projectile.type == ProjectileType.Bullet) {
      applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.Fireball) {
      //  emitLightColoredAtPosition(projectile,
      //   hue: 167,
      //   alpha: 50,
      //   saturation: 1,
      //   value: 1,
      // );
      return;
    }
    if (projectile.type == ProjectileType.Arrow) {
      applyVector3EmissionAmbient(projectile,
        alpha: 50,
      );
      return;
    }
    if (projectile.type == ProjectileType.FrostBall) {
      //  emitLightColoredAtPosition(
      //    projectile,
      //    hue: 203,
      //    saturation: 43,
      //    value: 100,
      //    alpha: 80,
      //
      // );
      return;
    }
  }

  void applyEmissionGameObjects() {
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;
      switch (gameObject.colorType) {
        case EmissionType.None:
          continue;
        case EmissionType.Color:
        // TODO
        // emitLightColoredAtPosition(
        //   gameObject,
        //   hue: gameObject.emissionHue,
        //   saturation: gameObject.emissionSat,
        //   value: gameObject.emissionVal,
        //   alpha: gameObject.emissionAlp,
        //   intensity: gameObject.emissionIntensity,
        // );
          continue;
        case EmissionType.Ambient:
          applyVector3EmissionAmbient(gameObject,
            alpha: gameObject.emissionAlp,
            intensity: gameObject.emissionIntensity,
          );
          continue;
      }
    }
  }

  void applyEmissionsParticles() {
    final particles = this.particles.children;
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles[i];
      if (!particle.active) continue;
      if (!particle.emitsLight) continue;
      emitLight(
        index: getIndexPosition(particle),
        value: particle.emissionColor,
        intensity: particle.emissionIntensity,
        ambient: false,
      );
    }
  }

  void updateProjectiles() {
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
        particles.emitSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        render.projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
        action.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
      }
      if (projectile.type == ProjectileType.Orb) {
        particles.spawnParticleOrbShard(
          x: projectile.x,
          y: projectile.y,
          z: projectile.z,
          angle: randomAngle(),
        );
      }
    }
  }

  void removeGameObjectById(int id )=>
      gameObjects.removeWhere((element) => element.id == id);

  void updateGameObjects() {
    final gameObjects = this.gameObjects;
    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      gameObject.update();
    }
  }

  void applyEmissionsColoredLightSources() {

    final colors = amulet.colors;
    final torchEmissionIntensityColored = amulet.lighting.torchEmissionIntensityColored;

    for (var i = 0; i < nodeLightSourcesTotal; i++){
      final nodeIndex = nodeLightSources[i];
      final nodeType = nodeTypes[nodeIndex];

      switch (nodeType) {
        case NodeType.Torch:
          break;
        case NodeType.Fireplace:
          emitLight(
            index: nodeIndex,
            value: colors.orange_0.value,
            intensity: torchEmissionIntensityColored,
            ambient: false,
          );
          break;
        case NodeType.Torch_Blue:
          emitLight(
            index: nodeIndex,
            value: colors.blue_1.value,
            intensity: torchEmissionIntensityColored,
            ambient: false,
          );
          break;
        case NodeType.Torch_Red:
          emitLight(
            index: nodeIndex,
            value: colors.red_1.value,
            intensity: torchEmissionIntensityColored,
            ambient: false,
          );
          break;
      }
    }
  }

  GameObject findOrCreateGameObject(int id) {
    var instance = findGameObjectById(id);
    if (instance == null) {
      instance = GameObject(id);
      gameObjects.add(instance);
    }
    return instance;
  }

  GameObject? findGameObjectById(int id) {
    for (final gameObject in gameObjects) {
      if (gameObject.id == id) return gameObject;
    }
    return null;
  }

  void updateParticleSmokeEmitters(){
    if (nextEmissionSmoke-- > 0)
      return;

    nextEmissionSmoke = framesPerSmokeEmission;
    final smokeDuration = options.sceneSmokeSourcesSmokeDuration;

    for (var i = 0; i < smokeSourcesTotal; i++){
      final index = smokeSources[i];
      particles.emitSmoke(
        x: getIndexPositionX(index),
        y: getIndexPositionY(index),
        z: getIndexPositionZ(index),
        duration: smokeDuration,
      );
    }
  }

  void updateAmbientAlphaAccordingToTime(){
    if (!options.updateAmbientAlphaAccordingToTimeEnabled)
      return;

    ambientAlpha = convertSecondsToAmbientAlpha(environment.currentTimeInSeconds);

    if (environment.rainType.value == RainType.Light){
      ambientAlpha += lighting.rainAmbienceLight;
    }
    if (environment.rainType.value == RainType.Heavy){
      ambientAlpha += lighting.rainAmbientHeavy;
    }
  }



  bool isPerceptiblePosition(Position position) {
    if (!player.playerInsideIsland)
      return true;

    if (outOfBoundsPosition(position))
      return false;

    final index = getIndexPosition(position);
    final indexRow = getRow(index);
    final indexColumn = getRow(index);
    final i = indexRow * totalColumns + indexColumn;

    if (!rendererNodes.island[i])
      return true;

    final indexZ = getIndexZ(index);
    if (indexZ > player.indexZ + 2)
      return false;

    return rendererNodes.visible3D[index];
  }

  int getNodeTypeAtPosition(Position position) =>
      outOfBoundsPosition(position)
          ? NodeType.Boundary
          : nodeTypes[getIndexPosition(position)];

  void setNode({
    required int index,
    required int nodeType,
    required int nodeOrientation,
  }) {
    assert(NodeType.supportsOrientation(nodeType, nodeOrientation));
    final previousNodeType = nodeTypes[index];

    if (NodeType.isLightSource(nodeType) != NodeType.isLightSource(previousNodeType)){
      refreshLightSources();
      resetNodeColorsToAmbient();
    }
    nodeTypes[index] = nodeType;
    nodeOrientations[index] = nodeOrientation;
    // events.onChangedNodes();
    editor.refreshNodeSelectedIndex();
  }

  int findNearestMark({
    required double x,
    required double y,
    required double z,
    required double minRadius,
  }) {
    final marks = scene.marks;
    final totalMarks = marks.length;

    if (totalMarks <= 0)
      return -1;

    var nearestIndex = -1;
    var nearestDistanceSquared = pow(minRadius, 2);

    for (var i = 0; i < totalMarks; i++){
      final mark = marks[i];
      final markIndex = MarkType.getIndex(mark);
      final markPosX = scene.getIndexPositionX(markIndex);
      final markPosY = scene.getIndexPositionY(markIndex);
      final markPosZ = scene.getIndexPositionZ(markIndex);

      final distanceSquared = getDistanceXYZSquared(
        x,
        y,
        z,
        markPosX,
        markPosY,
        markPosZ,
      );

      if (distanceSquared >= nearestDistanceSquared)
        continue;

      nearestDistanceSquared = distanceSquared;
      nearestIndex = i;
    }

    return nearestIndex;
  }

  int colorAbove(int index){
    final nodeAboveIndex = index + area;
    if (nodeAboveIndex >= totalNodes)
      return ambientColor;

    return nodeColors[nodeAboveIndex];
  }

  int colorWest(int index){
    final column = getColumn(index);
    if (column + 1 >= totalColumns){
      return ambientColor;
    }
    return nodeColors[index + 1];
  }

  int colorSouth(int index){
    final row = getRow(index);
    if (row + 1 >= totalRows) {
      return ambientColor;
    }
    return nodeColors[index + totalColumns];
  }

  bool nodeTypeBelowIs(int index, int value) => nodeType(index) == value;

  int nodeTypeBelow(int index) => nodeType(index - area);

  int nodeType(int i) {
    if (i < 0){
      return NodeType.Boundary;
    }
    if (i >= totalNodes)
      return NodeType.Boundary;

    return nodeTypes[i];
  }

  double getProjectionZ(Position vector3){

    final x = vector3.x;
    final y = vector3.y;
    var z = vector3.z;
    final nodeOrientations = this.nodeOrientations;

    while (true) {
      if (z < 0) return -1;
      final nodeIndex =  getIndexXYZ(x, y, z);
      final nodeOrientation =  nodeOrientations[nodeIndex];

      if (const <int> [
        NodeOrientation.None,
        NodeOrientation.Radial,
        NodeOrientation.Half_South,
        NodeOrientation.Half_North,
        NodeOrientation.Half_East,
        NodeOrientation.Half_West,
      ].contains(nodeOrientation)) {
        z -= IsometricConstants.Node_Height;
        continue;
      }
      if (z > Node_Height){
        return z + (z % Node_Height);
      } else {
        return Node_Height;
      }
    }
  }

  int findNearestNodeType({
    required int index,
    required int nodeType,
    required int radius,
  }) {
      final types = this.nodeTypes;

      if (types[index] == nodeType){
        return index;
      }

      final indexRow = getRow(index);
      final indexColumn = getColumn(index);
      final indexZ = getIndexZ(index);

      for (var r = 1; r < radius; r++){
        final maxZ = min(indexZ + r, totalZ);
        final maxRow = min(indexRow + r, totalRows);
        final maxColumn = min(indexColumn + r, totalColumns);

        final startZ = max(indexZ - r, 0);
        final startRow = max(indexRow - r, 0);
        final startColumn = max(indexColumn - r, 0);

        for (var z = startZ; z < maxZ; z++){
          for (var row = startRow; row < maxRow; row++){
            for (var column = startColumn; column < maxColumn; column++){
              if (getTypeZRC(z, row, column) == nodeType){
                return getIndexZRC(z, row, column);
              }
            }
          }
        }
      }

      return -1;
  }

  int getHeightMapHeightAt(int index) {
    final row = getRow(index);
    final column = getColumn(index);
    return heightMap[(row * totalColumns) + column];
  }

  final visited3DStack = Uint16List(10000);
  final visited2DStack = Uint16List(10000);

  var visited2D = BoolList(0);
  var visited2DStackIndex = 0;
  var visited3DStackIndex = 0;

  void emitHeightMapIsland(int index) {

    final visited2DStack = this.visited2DStack;
    final totalColumns = this.totalColumns;
    final z = getIndexZ(index);

    resetNodeVisibility();

    final heightMapHeight = getHeightMapHeightAt(index);

    if (z >= heightMapHeight) {
      return;
    }

    visit(getRow(index), getColumn(index), z);

    var j = 0;

    while (j < visited2DStackIndex){
      final i = visited2DStack[j];
      final row = i ~/ totalColumns;
      final column = i % totalColumns;

      visit(row - 1, column, z);
      visit(row + 1, column, z);
      visit(row, column + 1, z);
      visit(row, column - 1, z);
      j++;
    }

  }

  void resetNodeVisibility() {

    if (this.visited2D.length != area){
      this.visited2D = BoolList(area);
    }

    final visited2DStack = this.visited2DStack;
    final visited2DStackIndex = this.visited2DStackIndex;
    final visited3DStackIndex = this.visited3DStackIndex;

    final visited2D = this.visited2D;
    final nodeVisibility = this.nodeVisibility;
    final visited3DStack = this.visited3DStack;

    for (var i = 0; i < visited2DStackIndex; i++){
      visited2D[visited2DStack[i]] = false;
    }

    for (var i = 0; i < visited3DStackIndex; i++){
      nodeVisibility[visited3DStack[i]] = Visibility.opaque;
    }

    this.visited2DStackIndex = 0;
    this.visited3DStackIndex = 0;
  }

  void visit(int row, int column, int z){

    if (
      row < 0 ||
      column < 0 ||
      row >= totalRows ||
      column >= totalColumns
    ){
      return;
    }

    final i = (row * totalColumns) + column;
    if (heightMap[i] <= z || visited2D[i]){
      return;
    }

    visited2D[i] = true;
    visited2DStack[visited2DStackIndex++] = i;

    var index = getIndexZRC(z, row, column);
    var hide = false;

    final totalNodes = this.totalNodes;
    final area = this.area;
    final nodeVisibility = this.nodeVisibility;
    final visited3DStack = this.visited3DStack;

    var j = 0;

    var space = false;

    while (index < totalNodes){
       if (hide || nodeOrientations[index] != NodeOrientation.None){
         hide = true;
         if (j >= 1) {
           nodeVisibility[index] = (space || j >= 2) ? Visibility.invisible : Visibility.transparent;
           visited3DStack[visited3DStackIndex++] = index;
         }
       } else {
         space = true;
       }
       index += area;
       j++;
    }
  }
}

int convertSecondsToAmbientAlpha(int totalSeconds) {
  const Seconds_Per_Hours_12 = Duration.secondsPerHour * 12;
  return ((totalSeconds < Seconds_Per_Hours_12
      ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
      : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) *
      255)
      .round();

}
