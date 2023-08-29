
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

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
import 'package:gamestream_flutter/gamestream/isometric/classes/particle_whisp.dart';

import '../../../isometric/classes/position.dart';

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
    print('scene.onChangedMarks()');
    particles.children.removeWhere((element) => element is ParticleWhisp);
    particles.mystIndexes.clear();
    for (final markValue in marks) {
      final markType = MarkType.getType(markValue);
      switch (markType){
        case MarkType.Spawn_Whisp:
          final markIndex = MarkType.getIndex(markValue);
          particles.spawnWhisp(
            x: getIndexPositionX(markIndex),
            y: getIndexPositionY(markIndex),
            z: getIndexPositionZ(markIndex),
          );
          break;
        case MarkType.Spawn_Myst:
          particles.mystIndexes.add(
            MarkType.getIndex(markValue)
          );
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
      if (currentAlpha <= alpha) {
        return;
      }
    }

    if (alpha < 0 || alpha > 255){
      print('applyAmbient() invalid alpha: $alpha');
    }

    ambientStackIndex++;
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
    for (var i = 0; i < totalCharacters; i++) {
      final character = characters[i];

      if (const [
        CharacterType.Zombie,
        CharacterType.Fallen,
        CharacterType.Dog,
      ].contains(character.characterType))
        continue;

      applyVector3EmissionAmbient(
        character,
        alpha: lighting.emissionAlphaCharacter,
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

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          emitLightBeam(
            row: row,
            column: column,
            z: z,
            brightness: 7,
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
            recordMode: bakeStackRecording,
          );
        }
      }
    }
  }

  void applyEmissionBakeStack() {

    final ambient = ambientAlpha.clamp(0, 255);
    final alpha = interpolate(
      ambient,
      0,
      amulet.lighting.torchEmissionIntensityAmbient,
    ).toInt().clamp(0, 255);

    final total =  bakeStackTorchTotal;
    final stack = bakeStackTorchIndex;

    const padding = Node_Size * 6;
    final screenLeft = engine.Screen_Left - padding;
    final screenTop = engine.Screen_Top - padding;
    final screenRight = engine.Screen_Right + padding;
    final screenBottom = engine.Screen_Bottom + padding;

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
        applyAmbient(
          index: index,
          alpha: interpolate(ambient, alpha, intensity).toInt().clamp(0, 255),
        );
      }
    }
  }

  void applyEmissionEditorSelectedNode() {
    if (!options.editMode) return;
    final editor = amulet.editor;
    if (( editor.gameObject.value == null ||  editor.gameObject.value!.colorType == EmissionType.None)){
      emitLight(
        index:  editor.nodeSelectedIndex.value,
        value: 0,
        intensity: 1.0,
        ambient: true,
      );
    }
  }

  void emitLightBeam({
    required int row,
    required int column,
    required int z,
    required int brightness,
    required int vx,
    required int vy,
    required int vz,
    required int value,
    required double intensity,
    required bool ambient,
    required double minRenderX,
    required double maxRenderX,
    required double minRenderY,
    required double maxRenderY,
    required bool recordMode,
  }){
    if (brightness < 0)
      return;

    final area = this.area; // cache on cpu
    final rows = totalRows;
    final columns = totalColumns;
    final zs = totalZ;

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

      if (!recordMode){
        final renderX = getIndexRenderX(index);

        if (renderX < minRenderX && (vx < 0 || vy > 0))
          return;

        if (renderX > maxRenderX && (vx > 0 || vy < 0))
          return;

        final renderY = getIndexRenderY(index);

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

      if (ambient){
        applyAmbient(
          index: index,
          alpha: interpolate(ambientAlpha, value, brightness > 5 ? 1.0 : interpolations[brightness]).toInt(),
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
      emitLightBeam(
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
      emitLightBeam(
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
      emitLightBeam(
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
      emitLightBeam(
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
      emitLightBeam(
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
      emitLightBeam(
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
      emitLightBeam(
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

  bool indexOnscreen(int index, {double padding = Node_Size}){
    final x = getIndexRenderX(index);
    if (x < engine.Screen_Left - padding || x > engine.Screen_Right + padding)
      return false;

    final y = getIndexRenderY(index);
    return y > engine.Screen_Top - padding && y < engine.Screen_Bottom + padding;
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

  /// TODO Optimize
  void updateGameObjects() {
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
}

int convertSecondsToAmbientAlpha(int totalSeconds) {
  const Seconds_Per_Hours_12 = Duration.secondsPerHour * 12;
  return ((totalSeconds < Seconds_Per_Hours_12
      ? 1.0 - (totalSeconds / Seconds_Per_Hours_12)
      : (totalSeconds - Seconds_Per_Hours_12) / Seconds_Per_Hours_12) *
      255)
      .round();

}
