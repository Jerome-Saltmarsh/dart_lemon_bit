
import 'dart:math';
import 'dart:ui';

import 'package:gamestream_flutter/functions/convert_seconds_to_ambient_alpha.dart';
import 'package:gamestream_flutter/functions/get_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/component_isometric.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/mixins/updatable.dart';
import 'package:gamestream_flutter/gamestream/isometric/enums/emission_type.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/gameobject.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/library.dart';

import '../../../isometric/classes/position.dart';

class IsometricScene with IsometricComponent implements Updatable {

  final sceneEditable = Watch(false);
  final gameObjects = <GameObject>[];
  final projectiles = <Projectile>[];
  late final Engine engine;

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
  var _ambientAlpha = 0;
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
  final characters = <Character>[];

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

  void update(){
    interpolationPadding = ((scene.interpolationLength + 1) * Node_Size) / engine.zoom;

    jobBatchResetNodeColorsToAmbient();
    updateProjectiles();
    updateGameObjects();
    updateParticleEmitters();

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

  void updateCharacterColors(){
    for (var i = 0; i <  totalCharacters; i++){
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
      // if (!character.allie) continue;

      if (character.characterType == CharacterType.Zombie)
        continue;

      applyVector3EmissionAmbient(
        character,
        alpha: isometric.lighting.emissionAlphaCharacter,
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
    emitLightAmbient(
      index: getIndexPosition(v),
      alpha: alpha,
    );
  }

  void emitLightAmbient({
    required int index,
    required int alpha,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final engine = isometric.engine;

    if (!bakeStackRecording){

      final padding = interpolationPadding;
      final rx = getIndexRenderX(index);
      if (rx < engine.Screen_Left - padding) return;
      if (rx > engine.Screen_Right + padding) return;
      final ry = getIndexRenderY(index);
      if (ry < engine.Screen_Top - padding) return;
      if (ry > engine.Screen_Bottom + padding) return;
    }

    totalActiveLights++;

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

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeAmbient(
            row: row,
            column: column,
            z: z,
            brightness: 7,
            alpha: alpha,
            vx: vx,
            vy: vy,
            vz: vz,
          );
        }
      }
    }
  }


  void emitLightColored({
    required int index,
    required int color,
    required double intensity,
  }){
    if (index < 0) return;
    if (index >= totalNodes) return;

    final padding = interpolationPadding;
    final rx = getIndexRenderX(index);
    if (rx < engine.Screen_Left - padding) return;
    if (rx > engine.Screen_Right + padding) return;
    final ry = getIndexRenderY(index);
    if (ry < engine.Screen_Top - padding) return;
    if (ry > engine.Screen_Bottom + padding) return;
    totalActiveLights++;

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

    for (var vz = -1; vz <= 1; vz++){
      for (var vx = vxStart; vx <= vxEnd; vx++){
        for (var vy = vyStart; vy <= vyEnd; vy++){
          shootLightTreeColor(
            row: row,
            column: column,
            z: z,
            brightness: 7,
            vx: vx,
            vy: vy,
            vz: vz,
            color: color,
            intensity: intensity,
          );
        }
      }
    }
  }

  void shootLightTreeColor({
    required int row,
    required int column,
    required int z,
    required int brightness,
    required int color,
    required double intensity,
    int vx = 0,
    int vy = 0,
    int vz = 0,

  }){
    // assert (brightness < interpolationLength);
    var velocity = vx.abs() + vy.abs() + vz.abs();

    brightness -= velocity;
    if (brightness < 0) {
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

    const padding = Node_Size + Node_Size_Half;

    final index = (z * area) + (row * totalColumns) + column;

    final renderX = getIndexRenderX(index);

    if (renderX < isometric.engine.Screen_Left - padding && (vx < 0 || vy > 0))
      return;

    if (renderX > isometric.engine.Screen_Right + padding && (vx > 0 || vy < 0))
      return;

    final renderY = getIndexRenderY(index);

    if (renderY < isometric.engine.Screen_Top - padding && (vx < 0 || vy < 0 || vz > 0))
      return;

    if (renderY > isometric.engine.Screen_Bottom + padding && (vx > 0 || vy > 0))
      return;

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

    applyColor(
      index: index,
      intensity: (brightness > 5 ? 1.0 : interpolations[brightness]) * intensity,
      color: color,
    );

    if (const [
      NodeType.Grass_Long,
      NodeType.Tree_Bottom,
      NodeType.Tree_Top,
    ].contains(nodeType)) {
      brightness--;
      if (brightness >= interpolationLength)
        return;
    }

    velocity = vx.abs() + vy.abs() + vz.abs();

    if (velocity == 0)
      return;

    if (vx.abs() + vy.abs() + vz.abs() == 3) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: vy,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

    if (vx.abs() + vy.abs() == 2) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: vy,
        vz: 0,
        color: color,
        intensity: intensity,
      );
    }

    if (vx.abs() + vz.abs() == 2) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: 0,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

    if (vy.abs() + vz.abs() == 2) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: 0,
        vy: vy,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

    if (vy != 0) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: 0,
        vy: vy,
        vz: 0,
        color: color,
        intensity: intensity,
      );
    }

    if (vx != 0) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: vx,
        vy: 0,
        vz: 0,
        color: color,
        intensity: intensity,
      );
    }

    if (vz != 0) {
      shootLightTreeColor(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
        vx: 0,
        vy: 0,
        vz: vz,
        color: color,
        intensity: intensity,
      );
    }

  }


  void emitLightColoredAtPosition(Position v, {
    required int color,
    double intensity = 1.0,
  }){
    if (!inBoundsPosition(v)) return;
    emitLightColored(
      index: getIndexPosition(v),
      color: color,
      intensity: intensity,
    );
  }

  void applyEmissionBakeStack() {

    final ambient = ambientAlpha;

    final alpha = interpolate(
      ambient,
      0,
      isometric.lighting.torchEmissionIntensityAmbient,
    ).toInt();

    for (var i = 0; i < bakeStackTorchTotal; i++){
      final index = bakeStackTorchIndex[i];

      if (!indexOnscreen(index, padding: (Node_Size * 6)))
        continue;

      final start = bakeStackStartIndex[i];
      final size = bakeStackTorchSize[i];
      final end = start + size;

      for (var j = start; j < end; j++){
        final brightness = bakeStackBrightness[j];
        final index = bakeStackIndex[j];
        final intensity = brightness > 5 ? 1.0 : interpolations[brightness];
        applyAmbient(
          index: index,
          alpha: interpolate(ambient, alpha, intensity).toInt(),
        );
      }
    }
  }

  void applyEmissionEditorSelectedNode() {
    if (!options.editMode) return;
    final editor = isometric.editor;
    if (( editor.gameObject.value == null ||  editor.gameObject.value!.colorType == EmissionType.None)){
      emitLightAmbient(
        index:  editor.nodeSelectedIndex.value,
        alpha: 0,
      );
    }
  }

  void shootLightTreeAmbient({
    required int row,
    required int column,
    required int z,
    required int brightness,
    required int alpha,
    required int vx,
    required int vy,
    required int vz,
  }){
    // assert (brightness >= 0);
    if (brightness < 0)
      return;

    while (true) {
      var velocity = vx.abs() + vy.abs() + vz.abs();
      brightness -= velocity;

      if (brightness < 0)
        return;

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

      const padding = Node_Size + Node_Size_Half;

      final index = (z * area) + (row * totalColumns) + column;

      if (!bakeStackRecording){
        final renderX = getIndexRenderX(index);
        final engine = isometric.engine;

        if (renderX < engine.Screen_Left - padding && (vx < 0 || vy > 0))
          return;

        if (renderX > engine.Screen_Right + padding && (vx > 0 || vy < 0))
          return;

        final renderY = getIndexRenderY(index);

        if (renderY < engine.Screen_Top - padding && (vx < 0 || vy < 0 || vz > 0))
          return;

        if (renderY > engine.Screen_Bottom + padding && (vx > 0 || vy > 0))
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

      final intensity = brightness > 5 ? 1.0 : interpolations[brightness];

      applyAmbient(
        index: index,
        alpha: interpolate(ambientAlpha, alpha, intensity).toInt(),
      );

      if (bakeStackRecording) {
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
      shootLightTreeAmbient(
        row: row,
        column: column,
        z: z,
        brightness: brightness,
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
        brightness: brightness,
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
        brightness: brightness,
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
        brightness: brightness,
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
        brightness: brightness,
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
        brightness: brightness,
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
        brightness: brightness,
        alpha: alpha,
        vx: 0,
        vy: 0,
        vz: vz,
      );
    }
  }

  bool indexOnscreen(int index, {double padding = Node_Size}){
    final x = getIndexRenderX(index);
    final engine = isometric.engine;
    if (x < engine.Screen_Left - padding || x > engine.Screen_Right + padding)
      return false;

    final y = getIndexRenderY(index);
    return y > engine.Screen_Top - padding && y < engine.Screen_Bottom + padding;
  }

  void recordBakeStack() {
    print('recordBakeStack()');
    bakeStackRecording = true;
    for (var i = 0; i < nodeLightSourcesTotal; i++){
      final nodeIndex = nodeLightSources[i];
      final nodeType = nodeTypes[nodeIndex];
      final alpha = interpolate(
        ambientAlpha,
        0,
        1.0,
      ).toInt();

      final currentSize = bakeStackTotal;

      switch (nodeType){
        case NodeType.Torch:
          emitLightAmbient(
            index: nodeIndex,
            alpha: alpha,
          );
          break;
      }

      bakeStackTorchIndex[bakeStackTorchTotal] = nodeIndex;
      bakeStackStartIndex[bakeStackTorchTotal] = currentSize;
      bakeStackTorchSize[bakeStackTorchTotal] = bakeStackTotal - currentSize;
      bakeStackTorchTotal++;
    }

    bakeStackRecording = false;
    print('recordBakeStack() finished recording total: ${bakeStackTotal}');
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
      //  emitLightColoredAtPosition(projectile,
      //   hue: 100,
      //   saturation: 1,
      //   value: 1,
      //   alpha: 20,
      // );
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
      emitLightColored(
        index: getIndexPosition(particle),
        color: particle.emissionColor,
        intensity: particle.emissionIntensity,
      );
    }
  }

  void updateProjectiles() {
    for (var i = 0; i < totalProjectiles; i++) {
      final projectile = projectiles[i];
      if (projectile.type == ProjectileType.Rocket) {
        particles.emitSmoke(x: projectile.x, y: projectile.y, z: projectile.z);
        isometric.projectShadow(projectile);
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

    final colors = isometric.colors;
    final torchEmissionIntensityColored = isometric.lighting.torchEmissionIntensityColored;

    for (var i = 0; i < nodeLightSourcesTotal; i++){
      final nodeIndex = nodeLightSources[i];
      final nodeType = nodeTypes[nodeIndex];

      switch (nodeType) {
        case NodeType.Torch:
          break;
        case NodeType.Fireplace:
          emitLightColored(
            index: nodeIndex,
            color: colors.orange,
            intensity: torchEmissionIntensityColored,
          );
          break;
        case NodeType.Torch_Blue:
          emitLightColored(
            index: nodeIndex,
            color: colors.blue1,
            intensity: torchEmissionIntensityColored,
          );
          break;
        case NodeType.Torch_Red:
          emitLightColored(
            index: nodeIndex,
            color: colors.red1,
            intensity: torchEmissionIntensityColored,
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

  void updateParticleEmitters(){
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

    for (final gameObject in gameObjects){
      if (!gameObject.active) continue;
      if (gameObject.type != ObjectType.Barrel_Flaming) continue;
      particles.emitSmoke(
        x: gameObject.x + giveOrTake(5),
        y: gameObject.y + giveOrTake(5),
        z: gameObject.z + 35,
      );
    }
  }

  void updateAmbientAlphaAccordingToTime(){
    if (!options.updateAmbientAlphaAccordingToTimeEnabled)
      return;

    ambientAlpha = convertSecondsToAmbientAlpha(environment.currentTimeInSeconds);

    if (environment.rainType.value == RainType.Light){
      ambientAlpha += isometric.lighting.rainAmbienceLight;
    }
    if (environment.rainType.value == RainType.Heavy){
      ambientAlpha += isometric.lighting.rainAmbientHeavy;
    }
  }



  bool isPerceptiblePosition(Position position) {
    if (!player.playerInsideIsland)
      return true;

    if (outOfBoundsPosition(position))
      return false;

    final index = getIndexPosition(position);
    final indexRow = getIndexRow(index);
    final indexColumn = getIndexRow(index);
    final i = indexRow * totalColumns + indexColumn;

    if (!rendererNodes.island[i])
      return true;

    final indexZ = getIndexZ(index);
    if (indexZ > player.indexZ + 2)
      return false;

    return rendererNodes.visible3D[index];
  }

}



