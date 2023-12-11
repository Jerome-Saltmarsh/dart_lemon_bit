
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';


import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/lemon_math.dart';

import 'package:amulet_flutter/gamestream/isometric/classes/particle_roam.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/gamestream/isometric/consts/map_projectile_type_to_emission_ambient.dart';
import 'package:amulet_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:amulet_flutter/gamestream/isometric/enums/node_visibility.dart';
import 'package:amulet_flutter/gamestream/isometric/functions/src.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/isometric_constants.dart';
import 'package:amulet_flutter/isometric/classes/character.dart';
import 'package:amulet_flutter/isometric/classes/gameobject.dart';
import 'package:amulet_flutter/isometric/classes/projectile.dart';
import 'package:amulet_flutter/isometric/functions/get_render.dart';
import 'package:amulet_flutter/packages/lemon_components.dart';
import 'package:lemon_watch/src.dart';

import '../../../isometric/classes/position.dart';
import 'functions/convert_seconds_to_ambient_alpha.dart';
import 'render/classes/bool_list.dart';
import 'render/functions/merge_32_bit_colors.dart';

class IsometricScene with IsometricComponent implements Updatable {

  var _ambientAlpha = 0;

  final keys = <String, int>{};
  final keysChangedNotifier = Watch(0);
  var loaded = false;
  var marks = Uint32List(0);
  var interpolationPadding = 0.0;
  var nextLightingUpdate = 0;
  var framesPerSmokeEmission = 10;
  var nextEmissionSmoke = 0;
  var nextEmissionWind = 0;
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
  var emptyNodes = Uint16List(0);
  var nodeVariations = Uint8List(0);
  var miniMap = Uint8List(0);
  var heightMap = Uint16List(0);
  var nodeRandoms = Uint8List(400000);
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
  var interpolations = Float32List(6);

  final marksChangedNotifier = Watch(0);
  final interpolationEaseType = Watch(EaseType.In_Quad);
  final editEnabled = Watch(false);
  final nodesChangedNotifier = Watch(0);
  final characters = <Character>[];
  final gameObjects = <GameObject>[];
  final projectiles = <Projectile>[];

  IsometricScene(){
    interpolationEaseType.onChanged(onChangedInterpolationEaseType);
    ambientRGB = getRGB(ambientColor);
    assignInterpolations();
    marksChangedNotifier.onChanged(onChangedMarks);
    shuffleNodeRandoms();
  }

  void shuffleNodeRandoms() {
    final nodeRandoms = this.nodeRandoms;
    final length = nodeRandoms.length;
    for (var i = 0; i < length; i++){
      nodeRandoms[i] = randomByte();
    }
  }

  void onChangedMarks(int count){
    final particles = this.particles;
    particles.activated.removeWhere((element) => element is ParticleRoam);
    particles.mystIndexes.clear();
    particles.indexesWaterDrops.clear();
    final marks = this.marks;
    for (final markValue in marks) {
      final markType = MarkType.getType(markValue);
      final markIndex = MarkType.getIndex(markValue);
      final x = getIndexPositionX(markIndex);
      final y = getIndexPositionY(markIndex);
      final z = getIndexPositionZ(markIndex);

      switch (markType){
        case MarkType.Whisp:
          for (var i = 0; i < 3; i++){
            particles.spawnWhisp(x: x + giveOrTake(10), y: y + giveOrTake(10), z: z);
          }
          break;
        case MarkType.Glow:
          particles.spawnGlow(x: x, y: y, z: z);
          break;
        case MarkType.Myst:
          particles.mystIndexes.add(markIndex);
          break;
        case MarkType.Water_Drops:
          particles.indexesWaterDrops.add(markIndex);
          break;
        case MarkType.Butterfly:
          particles.spawnFlying(x: x, y: y, z: z)
            ..shadowScale = 0.4
            ..type = ParticleType.Butterfly;
          break;
        case MarkType.Moth:
          particles.spawnFlying(x: x, y: y, z: z)
            ..shadowScale = 0.25
            ..speed = 1.8
            ..type = ParticleType.Moth;
          break;
      }
    }

    particles.bootstrap();
  }

  void onChangedInterpolationEaseType(EaseType easeType){
    assignInterpolations();
  }

  void setInterpolationLength(int value){
    if (value < 1 || interpolationLength == value)
      return;

    interpolationLength = value;
    assignInterpolations();
  }

  void assignInterpolations() {
    interpolations = Float32List.fromList(interpolateEase(
      length: interpolationLength,
      easeType: interpolationEaseType.value,
    ));
  }

  int get ambientAlpha => _ambientAlpha;

  set ambientAlpha(int value){
    final clampedValue = value.clamp(0, 255);

    if (clampedValue == _ambientAlpha)
      return;

    ambientResetIndex = 0;
    _ambientAlpha = clampedValue;
    ambientColor = setAlpha(ambientColor, clampedValue);
  }

  // TODO Optimize
  void rainStart(){
    final rows = totalRows;
    final columns = totalColumns;
    final zs = totalZ - 1;
    final nodeTypes = this.nodeTypes;
    final nodeOrientations = this.nodeOrientations;

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

  // TODO Optimize
  void rainStop() {
    final totalNodes = this.totalNodes;
    final nodeTypes = this.nodeTypes;
    final nodeOrientations = this.nodeOrientations;

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
    // updateParticleWindEmitters();

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
  
  void onChangedNodes(){
    refreshMetrics();
    generateHeightMap();
    generateMiniMap();
    refreshSmokeSources();
    generateEmptyNodes();

    if (environment.raining.value) {
      rainStop();
      rainStart();
    }

    updateAmbientAlphaAccordingToTime();
    refreshLightSources();
    resetNodeColorsToAmbient();
    recordBakeStack();
    nodesChangedNotifier.value++;
  }

  void refreshMetrics(){
    print('scene.refreshMetrics()');
    lengthRows = totalRows * Node_Size;
    lengthColumns = totalColumns * Node_Size;
    lengthZ = totalZ * Node_Height;

    area = totalRows * totalColumns;
    area2 = area * 2;
    projection = area2 + totalColumns + 1;
    projectionHalf =  projection ~/ 2;
    totalNodes = totalZ * totalRows * totalColumns;

    if (colorStack.length != totalNodes){
      colorStack = Uint16List(totalNodes);
    }

    if (ambientStack.length != totalNodes){
      ambientStack = Uint16List(totalNodes);
    }

    if (nodeColors.length != totalNodes){
      nodeColors = Uint32List(totalNodes);
    }

    if (nodeVisibility.length != totalNodes){
      nodeVisibility = Uint8List(totalNodes);
    }
  }

  int getRow(int index) => (index % area) ~/ totalColumns;

  int getIndexZ(int index) => index ~/ area;

  int getColumn(int index) => index % totalColumns;

  int getRowColumn(int index)=> getRow(index) + getColumn(index);

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
    NodeType.Water,
    NodeType.Boulder,
  ].contains(nodeType);

  bool nodeOrientationBlocksVertical(int nodeOrientation) => const [
    NodeOrientation.Solid,
    NodeOrientation.Half_Vertical_Top,
    NodeOrientation.Half_Vertical_Center,
    NodeOrientation.Half_Vertical_Bottom,
  ].contains(nodeOrientation);

  bool nodeOrientationBlocksVerticalDown(int nodeOrientation) => const [
    NodeOrientation.Solid,
    NodeOrientation.Half_Vertical_Top,
    NodeOrientation.Half_Vertical_Center,
    NodeOrientation.Half_Vertical_Bottom,
  ].contains(nodeOrientation);

  int getProjectionIndex(int nodeIndex) => nodeIndex % projection;

  int getIndexBelow(int index) => index - area;

  int getIndexBelowPosition(Position position) =>
      getIndexZRC(
        position.indexZ - 1,
        position.indexRow,
        position.indexColumn,
      );

  // TODO OPTIMIZE
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
    final totalNodes = this.totalNodes;
    final nodeTypes = this.nodeTypes;
    for (var i = 0; i < totalNodes; i++){
      if (!const [
        NodeType.Fireplace,
        // NodeType.Torch,
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
    final totalNodes = this.totalNodes;
    final nodeTypes = this.nodeTypes;

    for (var i = 0; i < totalNodes; i++) {

      if (!NodeType.isLightSource(nodeTypes[i]))
        continue;

      nodeLightSources[nodeLightSourcesTotal] = i;
      nodeLightSourcesTotal++;

      if (nodeLightSourcesTotal >= nodeLightSources.length) {
        print('max light sources reached');
        return;
      }
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
    required int ambientAlpha,
    required Uint32List nodeColors,
  }){
    final ambientIntensity = ambientAlpha / 255;
    final interpolation = intensity * ambientIntensity;

    final currentColor = nodeColors[index];
    final currentRed = getRed(currentColor);
    final currentGreen = getGreen(currentColor);
    final currentBlue = getBlue(currentColor);
    final currentAlpha = getAlpha(currentColor);

    final colorRed = getRed(color);
    final colorGreen = getGreen(color);
    final colorBlue = getBlue(color);
    final colorAlpha = getAlpha(color);

    nodeColors[index] = rgba(
      r: interpolateByte(currentRed, colorRed, interpolation),
      g: interpolateByte(currentGreen, colorGreen, interpolation),
      b: interpolateByte(currentBlue, colorBlue, interpolation),
      a: interpolateByte(currentAlpha, colorAlpha, interpolation),
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
    final currentColor = nodeColors[index];
    final currentAlpha =  getAlpha(currentColor);
    if (currentAlpha <= alpha) {
      return;
    }
    ambientStack[ambientStackIndex] = index;
    nodeColors[index] = setAlpha(currentColor, alpha);
  }

  // void updateCharacterColors(){
  //   final totalCharacters = this.totalCharacters;
  //   final characters = this.characters;
  //   for (var i = 0; i < totalCharacters; i++){
  //     final character = characters[i];
  //     character.color =  getRenderColorPosition(character);
  //   }
  // }

  Character getCharacterInstance(){
    if (characters.length <= totalCharacters){
      characters.add(Character());
    }
    return characters[totalCharacters];
  }

  void applyEmissionAmbientCharacters() {
    final alpha = lighting.emissionAlphaCharacter;
    final totalCharacters = this.totalCharacters;
    final characters = this.characters;
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

    final engine = this.engine;
    final padding = interpolationPadding;
    final minRenderX = engine.Screen_Left - padding;
    final maxRenderX = engine.Screen_Right + padding;
    final minRenderY = engine.Screen_Top - padding;
    final maxRenderY = engine.Screen_Bottom + padding;

    if (!bakeStackRecording){
      final rx = getIndexRenderX(index);
      if (rx < minRenderX || rx > maxRenderX) return;
      final ry = getIndexRenderY(index);
      if (ry < minRenderY || ry > maxRenderY) return;
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

    final brightness = 7;
    final stackA = this.emitLightBeamStackA;
    final stackB = this.emitLightBeamStackB;

    this.emitLightBeamStackTotal = 0;
    var total = 0;

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

    final engine = this.engine;
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
    if (!options.editing) return;
    if (( editor.gameObject.value == null ||  editor.gameObject.value!.emissionType == EmissionType.None)){
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
    final colorStack = this.colorStack;
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
    var colorStackIndex = this.colorStackIndex;

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
          nodeColors: nodeColors,
          ambientAlpha: ambientAlpha,
        );
        colorStackIndex++;
        colorStack[colorStackIndex] = index;
      }

      if (recordMode) {
        final bakeStackTotal = this.bakeStackTotal;
        bakeStackIndex[bakeStackTotal] = index;
        bakeStackBrightness[bakeStackTotal] = brightness;
        this.bakeStackTotal++;
      }

      if (const [
        NodeType.Grass_Long,
        NodeType.Tree_Bottom,
        NodeType.Tree_Top,
        NodeType.Boulder,
      ].contains(nodeType)) {
        brightness -= 2;
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
      }

      if (vy != 0) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          vyByte << 2;
      }

      if (vz != 0) {
        stackA[stackTotal] =
          row |
          column << 8 |
          z << 16 |
          brightness << 24 ;

        stackB[stackTotal++] =
          vzByte << 4 ;
      }
    }

    this.ambientStackIndex = ambientStackIndex;
    this.colorStackIndex = colorStackIndex;
  }

  void recordBakeStack() {
    print('scene.recordBakeStack()');
    bakeStackRecording = true;
    bakeStackTorchTotal = 0;
    bakeStackTotal = 0;

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
    applyEmissionAmbientNodes();
    applyEmissionAmbientCharacters();
    applyEmissionAmbientGameObjects();
    applyEmissionAmbientProjectiles();
    applyEmissionEditorSelectedNode();
    applyEmissionColorNodes();
    applyEmissionColorParticles();
    applyEmissionColorGameObjects();
    // updateCharacterColors();
  }

  void applyEmissionAmbientNodes() {
    if (bakeStackRecording){
      recordBakeStack();
    } else {
      applyEmissionBakeStack();
    }
  }

  void applyEmissionAmbientProjectiles() {
    final totalProjectiles = this.totalProjectiles;
    final projectiles = this.projectiles;
    for (var i = 0; i < totalProjectiles; i++){
      applyProjectileEmissionAmbient(projectiles[i]);
    }
  }

  void applyProjectileEmissionAmbient(Projectile projectile) {
    final alpha = mapProjectileTypeEmissionToEmissionAmbient[projectile.type];

    if (alpha == null){
      return;
    }

    applyVector3EmissionAmbient(projectile,
      alpha: alpha,
    );
  }

  void applyEmissionAmbientGameObjects() {
    final gameObjects = this.gameObjects;
    for (final gameObject in gameObjects) {
      if (!gameObject.active || gameObject.emissionType != EmissionType.Ambient)
        continue;

      applyVector3EmissionAmbient(
        gameObject,
        alpha: gameObject.emissionAlp,
        intensity: gameObject.emissionIntensity,
      );
    }
  }

  void applyEmissionColorParticles() {
    final particles = this.particles.activated;
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      final particle = particles[i];
      if (
        !particle.emitsLight
      ) continue;
      emitLight(
        index: getIndexPosition(particle),
        value: particle.emissionColor,
        intensity: particle.emissionIntensity,
        ambient: false,
      );
    }
  }

  void updateProjectiles() {
    final totalProjectiles = this.totalProjectiles;
    final projectiles = this.projectiles;
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
        particles.emitSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        render.projectShadow(projectile);
        continue;
      }
      if (projectile.type == ProjectileType.Fireball) {
        actions.spawnParticleFire(x: projectile.x, y: projectile.y, z: projectile.z);
        continue;
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

  void applyEmissionColorNodes() {

    final colors = amulet.colors;
    final torchEmissionIntensityColored = amulet.lighting.torchEmissionIntensityColored;
    final nodeLightSourcesTotal = this.nodeLightSourcesTotal;
    final nodeLightSources = this.nodeLightSources;
    final nodeTypes = this.nodeTypes;

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
    if (nextEmissionSmoke-- > 0){
      return;
    }

    nextEmissionSmoke = framesPerSmokeEmission;
    final smokeDuration = options.sceneSmokeSourcesSmokeDuration;
    final smokeSourcesTotal = this.smokeSourcesTotal;
    final smokeSources = this.smokeSources;
    final particles = this.particles;

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
    if (outOfBoundsPosition(position))
      return false;

    return nodeVisibility[getIndexPosition(position)] != NodeVisibility.invisible;
  }

  int getNodeTypeAtPosition(Position position) =>
      outOfBoundsPosition(position)
          ? NodeType.Boundary
          : nodeTypes[getIndexPosition(position)];

  void setNode({
    required int index,
    required int nodeType,
    required int nodeOrientation,
    required int variation,
  }) {
    final previousNodeType = nodeTypes[index];
    nodeTypes[index] = nodeType;
    nodeOrientations[index] = nodeOrientation;
    nodeVariations[index] = variation;
    events.onChangedNodes();
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

  // TODO EXPENSIVE
  int colorAbove(int index){
    final nodeAboveIndex = index + area;
    if (nodeAboveIndex >= totalNodes)
      return ambientColor;

    return nodeColors[nodeAboveIndex];
  }

  // TODO EXPENSIVE
  int colorWest(int index){
    if (index < 0){
      return ambientColor;
    }

    final column = getColumn(index);
    if (column + 1 >= totalColumns){
      return ambientColor;
    }

    final indexWest = index + 1;

    if (const [
      NodeOrientation.Solid,
      NodeOrientation.Half_East,
      NodeOrientation.Corner_North_East,
      NodeOrientation.Corner_South_East,
      NodeOrientation.Slope_East,
    ].contains(nodeOrientations[indexWest])){
      final current = nodeColors[index];
      return merge32BitColors(current, ambientColor);
    }

    return nodeColors[indexWest];
  }

  // TODO EXPENSIVE
  int colorEast(int index){
    if (index < 0){
      return ambientColor;
    }

    final column = getColumn(index);
    if (column - 1 < 0) {
      final current = nodeColors[index];
      return merge32BitColors(current, ambientColor);
    }

    final indexEast = index - 1;

    if (const [
      NodeOrientation.Solid,
      NodeOrientation.Half_West,
      NodeOrientation.Corner_North_West,
      NodeOrientation.Corner_South_West,
      NodeOrientation.Slope_West,
    ].contains(nodeOrientations[indexEast])){
      final current = nodeColors[index];
      return merge32BitColors(current, ambientColor);
    }

    return nodeColors[indexEast];
  }

  // TODO EXPENSIVE
  int colorNorth(int index){
    if (index < 0){
      return ambientColor;
    }

    final row = getRow(index);
    if (row - 1 < 0) {
      return nodeColors[index];
    }

    final indexNorth = index - totalColumns;
    final orientationNorth = nodeOrientations[indexNorth];

    if (const [
      NodeOrientation.Solid,
      NodeOrientation.Half_South,
      NodeOrientation.Corner_South_East,
      NodeOrientation.Corner_South_West,
      NodeOrientation.Slope_South,
    ].contains(orientationNorth)){
      final current = nodeColors[index];
      return merge32BitColors(current, ambientColor);
    }

    return nodeColors[indexNorth];
  }

  int colorNorthWest(int index){
    if (index < 0){
      return -1;
    }

    final row = getRow(index);
    if (row - 1 < 0) {
      return -1;
    }

    final column = getColumn(index);
    if (column + 1 >= totalColumns){
      return -1;
    }

    final indexNorthWest = index - totalColumns + 1;
    if (const [
      NodeOrientation.Solid,
      NodeOrientation.Corner_South_East,
    ].contains(nodeOrientations[indexNorthWest])){
      return -1;
    }
    return nodeColors[indexNorthWest];
  }

  int colorSouthEast(int index){
    if (index < 0){
      -1;
    }
    final row = getRow(index);
    if (row + 1 >= totalRows) {
      return -1;
    }

    final column = getColumn(index);
    if (column - 1 < 0) {
      return -1;
    }

    final indexSouthEast = index + totalColumns - 1;
    final orientation = nodeOrientations[indexSouthEast];
    if (const [
      NodeOrientation.Solid,
      NodeOrientation.Corner_North_West,
    ].contains(orientation)){
      return -1;
    }
    return nodeColors[indexSouthEast];
  }

  // TODO EXPENSIVE
  int colorSouth(int index){
    if (index < 0){
      return ambientColor;
    }

    final row = getRow(index);
    if (row + 1 >= totalRows) {
      return nodeColors[index];
    }

    final indexSouth = index + totalColumns;

    if (const [
      NodeOrientation.Solid,
      NodeOrientation.Half_North,
      NodeOrientation.Corner_North_East,
      NodeOrientation.Corner_North_West,
      NodeOrientation.Slope_North,
    ].contains(nodeOrientations[indexSouth])){
      final current = nodeColors[index];
      return merge32BitColors(current, ambientColor);
    }

    return nodeColors[indexSouth];
  }

  int indexSouth(int index){
    return index + totalColumns;
  }

  bool nodeTypeBelowIs(int index, int value) => nodeType(index) == value;

  // TODO EXPENSIVE
  int nodeTypeBelow(int index) => nodeType(index - area);

  // TODO EXPENSIVE
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

  void clearVisited() {
    visited2DStackIndex = 0;
    visited3DStackIndex = 0;
    visited2D.fill(false);
  }

  void emitHeightMapIsland(int index) {

    final visited2DStack = this.visited2DStack;
    final totalColumns = this.totalColumns;
    final totalRows = this.totalRows;
    final z = getIndexZ(index);
    final heightMapHeight = getHeightMapHeightAt(index);

    if (z >= heightMapHeight) {
      return;
    }

    final visited2D = this.visited2D;

    visit(getRow(index), getColumn(index), z, totalColumns: totalColumns, totalRows: totalRows, visited2D: visited2D);

    var j = 0;

    while (j < visited2DStackIndex){
      final i = visited2DStack[j];
      final row = i ~/ totalColumns;
      final column = i % totalColumns;

      visit(row - 1, column, z, totalColumns: totalColumns, totalRows: totalRows, visited2D: visited2D);
      visit(row + 1, column, z, totalColumns: totalColumns, totalRows: totalRows, visited2D: visited2D);
      visit(row, column + 1, z, totalColumns: totalColumns, totalRows: totalRows, visited2D: visited2D);
      visit(row, column - 1, z, totalColumns: totalColumns, totalRows: totalRows, visited2D: visited2D);
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
      nodeVisibility[visited3DStack[i]] = NodeVisibility.opaque;
    }

    this.visited2DStackIndex = 0;
    this.visited3DStackIndex = 0;
  }

  void visit(int row, int column, int z, {
    required BoolList visited2D,
    required int totalRows,
    required int totalColumns,
  }){

    if (
      row < 0 ||
      column < 0 ||
      row >= totalRows ||
      column >= totalColumns
    ){
      return;
    }

    final i = (row * totalColumns) + column;
    if (visited2D[i] || heightMap[i] <= z){
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
    final nodeOrientations = this.nodeOrientations;

    var j = 0;

    var space = false;

    while (index < totalNodes){
       if (hide || nodeOrientations[index] != NodeOrientation.None){
         hide = true;
         if (j >= 1) {

           // if (j == 1){
           //   final indexAbove = index + area;
           //   if (indexAbove < totalNodes){
           //     if (nodeOrientations[indexAbove] == NodeOrientation.None) {
           //       index += area;
           //       j++;
           //       continue;
           //     }
           //   }
           // }


           nodeVisibility[index] = (space || j >= 2) ? NodeVisibility.invisible : NodeVisibility.transparent;
           visited3DStack[visited3DStackIndex++] = index;
         }
       } else {
         space = true;
       }
       index += area;
       j++;
    }
  }

  void generateEmptyNodes() {
    final nodeTypes = this.nodeTypes;
    final totalRows = this.totalRows;
    final totalZ = this.totalZ;
    final totalColumns = this.totalColumns;

    if (this.emptyNodes.length != nodeTypes.length) {
      this.emptyNodes = Uint16List(nodeTypes.length);
    } else {
      this.emptyNodes.fillRange(0, this.emptyNodes.length - 1, 0);
    }

    final emptyNodes = this.emptyNodes;

    final shift = totalColumns - 1;
    final sideLength = totalRows + totalColumns;

    for (var z = 0; z < totalZ; z++){
      for (var i = 0; i < sideLength; i++) {

        int r;
        int c;

        if (i < totalRows){
          r = i;
          c = 0;
        } else {
          r = totalRows - 1;
          c = i - r;
        }

        var count = 0;
        var index = getIndexZRC(z, r, c);
        while (r >= 0 && c < totalColumns){
          if (nodeTypes[index] == NodeType.Empty){
            emptyNodes[index] = count;
            count++;
          } else {
            count = 0;
          }
          index -= shift;
          r--;
          c++;
        }
      }
    }
  }

  void applyEmissionColorGameObjects() {
    final gameObjects = this.gameObjects;
    for (final gameObject in gameObjects) {
      if (!gameObject.active) continue;

      if (
        gameObject.type == ItemType.Object &&
        gameObject.subType == GameObjectType.Crystal_Glowing_False
      ){
        emitLight(
          index: getIndexPosition(gameObject),
          value: colors.purple_1.value,
          intensity: 0.15,
          ambient: false,
        );
      }

      if (
        gameObject.type == ItemType.Object &&
        gameObject.subType == GameObjectType.Crystal_Glowing_True
      ){
        emitLight(
          index: getIndexPosition(gameObject),
          value: colors.aqua_2.value,
          intensity: 0.35,
          ambient: false,
        );
      }
    }
  }

  void updateParticleWindEmitters() {
    if (nextEmissionWind-- > 0){
      return;
    }

    nextEmissionWind = 50;
    particles.spawnParticle(
        particleType: ParticleType.Wind,
        x: player.x,
        y: player.y,
        z: player.z + 100,
        duration: 50,
        weight: 0,
    );
  }


  void applyColorToCharacter(Character character){

    if (outOfBoundsPosition(character)){
      character.colorSouthEast = ambientColor;
      character.colorNorthWest = ambientColor;
      return;
    }

    final index = getIndexPosition(character);
    final colorN = this.colorNorth(index);
    final colorE = this.colorEast(index);
    final colorS = this.colorSouth(index);
    final colorW = this.colorWest(index);
    final colorNW = this.colorNorthWest(index);
    final colorSE = this.colorSouthEast(index);
    final colorNAlpha = getAlpha(colorN);
    final colorEAlpha = getAlpha(colorE);
    final colorSAlpha = getAlpha(colorS);
    final colorWAlpha = getAlpha(colorW);

    var maxSEAlpha = max(colorSAlpha, colorEAlpha);
    var maxNWAlpha = max(colorNAlpha, colorWAlpha);

    if (colorSE != -1){
      final colorSEAlpha = getAlpha(colorSE);
      maxSEAlpha = max(colorSEAlpha, maxSEAlpha);
    }

    if (colorNW != -1){
      final alphaNW = getAlpha(colorNW);
      maxNWAlpha = max(alphaNW, maxNWAlpha);
    }

    final minSEAlpha = min(colorSAlpha, colorEAlpha);
    final minNWAlpha = min(colorNAlpha, colorWAlpha);

    final southEast = merge32BitColors(colorS, colorE);
    final northWest = merge32BitColors(colorN, colorW);

    if (minSEAlpha < minNWAlpha){
       character.colorSouthEast = setAlpha(southEast, minSEAlpha);
       character.colorNorthWest = setAlpha(northWest, maxNWAlpha);
    } else {
      character.colorSouthEast = setAlpha(southEast, maxSEAlpha);
      character.colorNorthWest = setAlpha(northWest, minNWAlpha);
    }
  }

  int getColorBeamNorth(int index){
    final row = getRow(index);
    final totalColumns = this.totalColumns;
    final indexNorth1 = index - totalColumns;
    final indexNorth2 = indexNorth1 - totalColumns;

    const blockNorth = const [
      NodeOrientation.Half_North,
      NodeOrientation.Corner_North_East,
      NodeOrientation.Corner_North_West,
    ];

    const blockSouth = const [
      NodeOrientation.Solid,
      NodeOrientation.Half_South,
      NodeOrientation.Corner_South_East,
      NodeOrientation.Corner_South_West,
    ];

    if (
      row - 1 < 0 ||
      blockNorth.contains(nodeOrientations[index]) ||
      blockSouth.contains(nodeOrientations[indexNorth1])
    ) {
      // return nodeColors[index];
      return merge32BitColors(
        nodeColors[index],
        ambientColor,
      );
    }

    if (
      row - 2 < 0 ||
      blockNorth.contains(nodeOrientations[indexNorth1]) ||
      blockSouth.contains(nodeOrientations[indexNorth2])
    ) {
      // return nodeColors[indexNorth1];
      return merge32BitColors(
        nodeColors[indexNorth1],
        ambientColor,
      );
    }

    return merge32BitColors(
      nodeColors[indexNorth1],
      nodeColors[indexNorth2],
    );
  }

  int getColorBeamEast(int index){
    final column = getColumn(index);

    final indexEast1 = index - 1;
    final indexEast2 = indexEast1 - 1;

    const blockEast = const [
      NodeOrientation.Half_East,
      NodeOrientation.Corner_North_East,
      NodeOrientation.Corner_South_East,
    ];

    const blockWest = const [
      NodeOrientation.Solid,
      NodeOrientation.Half_West,
      NodeOrientation.Corner_North_West,
      NodeOrientation.Corner_South_West,
    ];

    if (
      column - 1 < 0 ||
      blockEast.contains(nodeOrientations[index]) ||
      blockWest.contains(nodeOrientations[indexEast1])
    ) {
      return merge32BitColors(
        nodeColors[index],
        ambientColor,
      );
      // return nodeColors[index];
    }

    if (
      column - 2 < 0 ||
      blockEast.contains(nodeOrientations[indexEast1]) ||
      blockWest.contains(nodeOrientations[indexEast2])
    ) {
      return merge32BitColors(
        nodeColors[indexEast1],
        ambientColor,
      );
      // return nodeColors[indexEast1];
    }

    return merge32BitColors(
      nodeColors[indexEast1],
      nodeColors[indexEast2],
    );
  }

  int getColorBeamWest(int index){
    final column = getColumn(index);

    final indexWest1 = index + 1;
    final indexWest2 = indexWest1 + 1;

    const blockEast = const [
      NodeOrientation.Half_West,
      NodeOrientation.Corner_North_West,
      NodeOrientation.Corner_South_West,
    ];

    const blockWest = const [
      NodeOrientation.Solid,
      NodeOrientation.Half_East,
      NodeOrientation.Corner_North_East,
      NodeOrientation.Corner_South_East,
    ];

    if (
      column + 1 >= totalColumns ||
      blockEast.contains(nodeOrientations[index]) ||
      blockWest.contains(nodeOrientations[indexWest1])
    ) {
      // return nodeColors[index];
      return merge32BitColors(
        nodeColors[index],
        ambientColor,
      );
    }

    if (
      column + 2 >= totalColumns ||
      blockEast.contains(nodeOrientations[indexWest1]) ||
      blockWest.contains(nodeOrientations[indexWest2])
    ) {
      return merge32BitColors(
        nodeColors[indexWest1],
        ambientColor,
      );
      // return nodeColors[indexWest1];
    }

    return merge32BitColors(
      nodeColors[indexWest1],
      nodeColors[indexWest2],
    );
  }

  int getColorBeamSouth(int index){
    final row = getRow(index);

    final indexSouth1 = index + totalColumns;
    final indexSouth2 = indexSouth1 + totalColumns;

    const blockNorth = const [
      NodeOrientation.Half_South,
      NodeOrientation.Corner_South_East,
      NodeOrientation.Corner_South_West,
    ];

    const blockSouth = const [
      NodeOrientation.Solid,
      NodeOrientation.Half_North,
      NodeOrientation.Corner_North_East,
      NodeOrientation.Corner_North_West,
    ];

    if (
      row + 1 >= totalRows ||
      blockNorth.contains(nodeOrientations[index]) ||
      blockSouth.contains(nodeOrientations[indexSouth1])
    ) {
      return merge32BitColors(
        nodeColors[index],
        ambientColor,
      );
      // return nodeColors[index];
    }

    if (
      row + 2 >= totalRows ||
      blockNorth.contains(nodeOrientations[indexSouth1]) ||
      blockSouth.contains(nodeOrientations[indexSouth2])
    ) {
      return merge32BitColors(
        nodeColors[indexSouth1],
        ambientColor,
      );
      // return nodeColors[indexSouth1];
    }

    return merge32BitColors(
      nodeColors[indexSouth1],
      nodeColors[indexSouth2],
    );
  }

}
