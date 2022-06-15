import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/classes/FloatingText.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/classes/ParticleEmitter.dart';
import 'package:gamestream_flutter/classes/Structure.dart';
import 'package:gamestream_flutter/convert/convert_hour_to_ambient.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/utils/mouse.dart';
import 'package:gamestream_flutter/isometric/state/time.dart';
import 'package:gamestream_flutter/modules/game/emit_particle.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';
import 'package:lemon_watch/watch.dart';

import 'events.dart';
import 'render.dart';
import 'subscriptions.dart';


class IsometricModule {
  final subscriptions = IsometricSubscriptions();
  late final IsometricRender render;
  late final IsometricSpawn spawn;
  late final IsometricEvents events;
  final particleEmitters = <ParticleEmitter>[];
  final paths = Float32List(10000);
  final targets = Float32List(10000);
  final particles = <Particle>[];
  final structures = <Structure>[];
  final gemSpawns = <GemSpawn>[];
  final floatingTexts = <FloatingText>[];
  final dynamic = <Int8List>[];
  final bake = <Int8List>[];
  final items = <Item>[];
  // final totalColumns = Watch(0);
  // final totalRows = Watch(0);
  final maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  var eventsRegistered = false;
  var tiles = <List<int>>[];
  var tilesDst = Float32List(0);
  var tilesSrc = Float32List(0);
  var totalColumnsInt = 0;
  var targetsTotal = 0;
  var totalRowsInt = 0;
  var totalStructures = 0;
  var minRow = 0;
  var maxRow = 0;
  var minColumn = 0;
  var maxColumn = 0;

  Particle? next;

  // PROPERTIES

  bool get dayTime => ambient.value == Shade.Bright;


  int get totalActiveParticles {
    var totalParticles = 0;
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      if (!particles[i].active) continue;
      totalParticles++;
    }
    return totalParticles;
  }

  // CONSTRUCTOR

  IsometricModule(){
    spawn = IsometricSpawn(this);
    events = IsometricEvents(this);
    render = IsometricRender(this);

    for(var i = 0; i < 300; i++){
      particles.add(Particle());
      items.add(Item(type: ItemType.Armour_Plated, x: 0, y: 0));
    }
    for (var i = 0; i < 1000; i++) {
      structures.add(Structure());
    }
  }

  // METHODS

  void sortParticles(){
    insertionSort(
      particles,
      compare: compareParticles,
    );
  }

  int compareParticles(Particle a, Particle b) {
    if (!a.active) {
      if (!b.active){
        return 0;
      }
      return 1;
    }
    if (!b.active) {
      return -1;
    }
    return a.y > b.y ? 1 : -1;
  }


  int getShade(int row, int column){
    if (row < 0) return Pitch_Black;
    if (column < 0) return Pitch_Black;
    if (row >= totalRowsInt){
      return Pitch_Black;
    }
    if (column >= totalColumnsInt){
      return Pitch_Black;
    }
    return dynamic[row][column];
  }

  int getShadeAt(Position position){
    return getShadeAtPosition(position.x, position.y);
  }

  int getShadeAtPosition(double x, double y){
    return getShade(
        (x + y) ~/ 48.0,
        (y - x) ~/ 48.0,
    );
  }

  bool inDarkness(double x, double y){
    return getShadeAtPosition(x, y) >= Shade.Very_Dark;
  }

  bool tileIsWalkable(Vector3 position){
    final tile = getTileAt(position.x, position.y);
    if (tile == Tile.Boundary) return false;
    if (tile == Tile.Water) return false;
    return true;
  }

  int getTileAt(double x, double y){
    return getTile((x + y) ~/ 48.0, (y - x) ~/ 48.0);
  }

  int getTile(int row, int column){
    if (outOfBounds(row, column)) return Tile.Boundary;
    return tiles[row][column];
  }

  bool outOfBounds(int row, int column){
    if (row < 0) return true;
    if (column < 0) return true;
    if (row >= totalRowsInt) return true;
    if (column >= totalColumnsInt) return true;
    return false;
  }

  void applyShadeDynamicPositionUnchecked(double x, double y, int value) {
    shadeDynamic(convertWorldToRow(x,  y), convertWorldToColumn(x, y), value);
  }

  void shadeDynamic(int row, int column, int value) {
    applyShade(dynamic, row, column, value);
  }

  void shadeBake(int row, int column, int value) {
    applyShade(bake, row, column, value);
  }

  void applyShade(List<List<int>> shader, int row, int column, int value) {
    applyShadeAtRow(shader[row], column, value);
  }

  void applyShadeAtRow(List<int> shadeRow, int column, int value) {
    if (shadeRow[column] <= value) return;
    shadeRow[column] = value;
  }

  void applyShadeRing(List<List<int>> shader, int row, int column, int size, int shade) {
    if (shade >= ambient.value) return;
    final rStart = max(row - size, minRow);
    if (rStart > maxRow) return;
    var rEnd = min(row + size, maxRow);
    if (rEnd < minRow) return;
    final cStart = max(column - size, minColumn);
    if (cStart > maxColumn) return;
    var cEnd = min(column + size, maxColumn);
    if (cEnd < minColumn) return;

    if (rEnd >= totalRowsInt){
      rEnd = totalRowsInt - 1;
    }
    if (cEnd >= totalColumnsInt){
      cEnd = totalColumnsInt - 1;
    }

    final rowStart = shader[rStart];
    final rowEnd = shader[rEnd];

    for (var r = rStart + 1; r < rEnd; r++) {
      final shadeRow = shader[r];
      applyShadeAtRow(shadeRow, cStart, shade);
      applyShadeAtRow(shadeRow, cEnd, shade);
    }
    for (var c = cStart; c <= cEnd; c++) {
      applyShadeAtRow(rowStart, c, shade);
      applyShadeAtRow(rowEnd, c, shade);
    }
  }

  void emitLightLow(List<List<int>> shader, double x, double y) {
    final column = convertWorldToColumn(x, y);
    if (column < 0) return;
    if (column >= shader[0].length) return;
    final row = convertWorldToRow(x, y);
    if (row < 0) return;
    if (row >= shader.length) return;

    applyShade(shader, row, column, Shade.Medium);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Dark);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
  }

  void bakeShadeRing(int row, int column, int size, int shade) {

    if (shade >= ambient.value) return;

    var rStart = row - size;
    var rEnd = row + size;
    var cStart = column - size;
    var cEnd = column + size;

    if (rStart < 0) {
      rStart = 0;
    } else if (rStart >= totalRowsInt) {
      return;
    }

    if (rEnd >= totalRowsInt){
      rEnd = totalRowsInt - 1;
    } else if(rEnd < 0) {
      return;
    }

    if (cStart < 0) {
      cStart = 0;
    } else if (cStart >= totalColumnsInt) {
      return;
    }

    if (cEnd >= totalColumnsInt){
      cEnd = totalColumnsInt - 1;
    } else if(cEnd < 0) {
      return;
    }

    for (var r = rStart; r <= rEnd; r++) {
      shadeBake(r, cStart, shade);
      shadeBake(r, cEnd, shade);
    }
    for (var c = cStart + 1; c < cEnd; c++) {
      shadeBake(rStart, c, shade);
      shadeBake(rEnd, c, shade);
    }
  }


  void emitLightMedium(List<List<int>> shader, double x, double y) {
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;

    applyShade(shader, row, column, Shade.Medium);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightHigh(List<List<int>> shader, Vector2 position) {
    final x = position.x;
    final y = position.y;
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightHighLarge(List<List<int>> shader, double x, double y) {
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Bright);
    applyShadeRing(shader, row, column, 3, Shade.Bright);
    applyShadeRing(shader, row, column, 4, Shade.Medium);
    applyShadeRing(shader, row, column, 5, Shade.Dark);
    applyShadeRing(shader, row, column, 6, Shade.Very_Dark);
  }

  void emitLightHighLarge2(List<List<int>> shader, double x, double y) {
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Bright);
    applyShadeRing(shader, row, column, 3, Shade.Bright);
    applyShadeRing(shader, row, column, 4, Shade.Medium);
    applyShadeRing(shader, row, column, 5, Shade.Dark);
    applyShadeRing(shader, row, column, 6, Shade.Very_Dark);
  }

  void emitLightBakeHigh(double x, double y) {
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;
    shadeBake(row, column, Shade.Bright);
    bakeShadeRing(row, column, 1, Shade.Bright);
    bakeShadeRing(row, column, 2, Shade.Medium);
    bakeShadeRing(row, column, 3, Shade.Dark);
    bakeShadeRing(row, column, 4, Shade.Very_Dark);
  }

  void emitLightBakeHighLarge(double x, double y) {
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;
    shadeBake(row, column, Shade.Bright);
    bakeShadeRing(row, column, 1, Shade.Bright);
    bakeShadeRing(row, column, 2, Shade.Bright);
    bakeShadeRing(row, column, 3, Shade.Medium);
    bakeShadeRing(row, column, 4, Shade.Dark);
    bakeShadeRing(row, column, 5, Shade.Very_Dark);
  }

  void emitLightBrightSmall(List<List<int>> shader, double x, double y) {
    final column = convertWorldToColumn(x, y);
    final row = convertWorldToRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Dark);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
  }

  void applyGameObjectsToBakeMapping(){
    for (final gameObject in game.gameObjects) {
      final type = gameObject.type;
      if (type == GameObjectType.Torch){
        emitLightBakeHigh(gameObject.x, gameObject.y);
        continue;
      }
      if (type == GameObjectType.House){
        emitLightMedium(bake, gameObject.x, gameObject.y);
        continue;
      }
      if (type == GameObjectType.Fireplace) {
        emitLightBakeHighLarge(gameObject.x, gameObject.y);
        continue;
      }
    }
  }

  // TODO Optimize
  void resetDynamicShadesToBakeMap() {
    for (var row = minRow; row < maxRow; row++) {
      final dynamicRow = dynamic[row];
      final bakeRow = bake[row];
      for (var column = minColumn; column < maxColumn; column++) {
        dynamicRow[column] = bakeRow[column];
      }
    }
  }

  void addRow(){
    final List<int> row = [];
    final rows = tiles[0].length;
    for(var i = 0; i < rows; i++){
      row.add(Tile.Grass);
    }
    tiles.add(row);
  }

  void removeRow(){
    tiles.removeLast();
  }


  void addColumn() {
    for (final row in tiles) {
      row.add(Tile.Grass);
    }
  }

  void removeColumn() {
    for (var i = 0; i < tiles.length; i++) {
      tiles[i].removeLast();
    }
  }

  void detractHour(){
    print("isometric.actions.detractHour()");
    hours.value = (hours.value - 1) % 24;
  }

  void addHour(){
    hours.value = (hours.value + 1) % 24;
  }

  void setHour(int hour) {
    hours.value = hour * secondsPerHour;
  }

  void cameraCenterMap(){
    // final center = mapCenter;
    // engine.cameraCenter(center.x, center.y);
  }

  void applyEmissionFromEffects() {
    for (final effect in game.effects) {
      if (!effect.enabled) continue;
      final percentage = effect.percentage;
      if (percentage < 0.33) {
        emitLightHigh(dynamic, effect);
        break;
      }
      if (percentage < 0.66) {
        emitLightMedium(dynamic, effect.x, effect.y);
        break;
      }
      emitLightLow(dynamic, effect.x, effect.y);
    }
  }

  void applyDynamicShadeToTileSrc() {
    final _rowIndex16 = totalColumnsInt * 16;
    for (var rowIndex = minRow; rowIndex < maxRow; rowIndex++) {
      final row = dynamic[rowIndex];
      for (var columnIndex = minColumn; columnIndex < maxColumn; columnIndex++) {
        final i = _rowIndex16 + (columnIndex * 4);
        final top = row[columnIndex] * 48.0;
        tilesSrc[i + 1] = top; // top
        tilesSrc[i + 3] = top + 48.0; // bottom
      }
    }
  }

  // void refreshAmbientLight(){
  //   final shade = convertHourToAmbient(hours.value);
  //   if (maxAmbientBrightness.value > shade) return;
  //   ambient.value = shade;
  // }

  // void refreshGeneratedObjects() {
  //   game.generatedObjects.clear();
  //   final totalRows = tiles.length;
  //   final totalColumns = totalRows > 0 ? tiles[0].length : 0;
  //   for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
  //     final row = tiles[rowIndex];
  //     for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++){
  //       final tile = row[columnIndex];
  //       var objectType = tileTypeToObjectType[tile];
  //       if (objectType == null) continue;
  //       game.generatedObjects.add(
  //           GeneratedObject(
  //             x: getTileWorldX(rowIndex, columnIndex),
  //             y: getTileWorldY(rowIndex, columnIndex) + tileSizeHalf,
  //             type: objectType,
  //           )
  //       );
  //     }
  //   }
  //   sortVertically(game.generatedObjects);
  // }

  void updateParticles() {

    for (final emitter in particleEmitters) {
      if (emitter.next-- > 0) continue;
      emitter.next = emitter.rate;
      final particle = spawn.getAvailableParticle();
      particle.x = emitter.x;
      particle.y = emitter.y;
      emitter.emit(particle);
    }

    for (final particle in particles) {
      if (!particle.active) continue;
      _updateParticle(particle);
    }

    if (engine.frame % 6 == 0) {
      for (final particle in particles) {
        if (!particle.active) continue;
        if (!particle.bleeds) continue;
        if (particle.speed < 2.0) continue;
        spawn.spawnParticleBlood(x: particle.x, y: particle.y, z: particle.z, zv: 0, angle: 0, speed: 0);
      }
    }
  }

  void _updateParticle(Particle particle){
    final airBorn = particle.z > 0.01;
    final bounce = particle.zv < 0 && !airBorn;
    particle.updateMotion();

    if (bounce) {
      if (!tileIsWalkable(particle)){
        _deactivateParticle(particle);
        return;
      }
      if (particle.zv < -0.1){
        particle.zv = -particle.zv * particle.bounciness;
      } else {
        particle.zv = 0;
      }

    } else if (airBorn) {
      particle.applyAirFriction();
    } else {
      particle.applyFloorFriction();
      if (!tileIsWalkable(particle)){
        _deactivateParticle(particle);
        return;
      }
    }
    particle.applyLimits();
    if (particle.duration-- <= 0) {
      _deactivateParticle(particle);
    }
  }

  void _deactivateParticle(Particle particle) {
    particle.duration = -1;
    if (next != null) {
      next = particle;
      particle.next = next;
      return;
    }
    next = particle;
  }

  void spawnFloatingText(double x, double y, String text) {
    final floatingText = _getFloatingText();
    floatingText.duration = 50;
    floatingText.x = x;
    floatingText.y = y;
    floatingText.xv = giveOrTake(0.2);
    floatingText.value = text;
  }

  FloatingText _getFloatingText(){
    for (final floatingText in floatingTexts) {
      if (floatingText.duration > 0) continue;
      return floatingText;
    }
    final instance = FloatingText();
    floatingTexts.add(instance);
    return instance;
  }

  void addSmokeEmitter(double x, double y){
    particleEmitters.add(ParticleEmitter(x: x, y: y, rate: 12, emit: emitSmoke));
  }
}


// double convertWorldToGridX(double x, double y){
//   return (x + y) ~/ 48.0;
//   return getTile((x + y) ~/ 48.0, (y - x) ~/ 48.0);
// }