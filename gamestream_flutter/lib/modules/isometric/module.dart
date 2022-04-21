import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bleed_common/GemSpawn.dart';
import 'package:bleed_common/utilities.dart';
import 'package:bleed_common/ItemType.dart';
import 'package:bleed_common/ObjectType.dart';
import 'package:bleed_common/ProjectileType.dart';
import 'package:bleed_common/Shade.dart';
import 'package:bleed_common/Tile.dart';
import 'package:bleed_common/constants.dart';
import 'package:bleed_common/tileTypeToObjectType.dart';
import 'package:bleed_common/utilities.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/classes/EnvironmentObject.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/classes/ParticleEmitter.dart';
import 'package:gamestream_flutter/functions.dart';
import 'package:gamestream_flutter/mappers/mapTileToSrcRect.dart';
import 'package:gamestream_flutter/modules/isometric/spawn.dart';
import 'package:gamestream_flutter/modules/isometric/utilities.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';
import 'events.dart';
import 'render.dart';
import 'subscriptions.dart';


class IsometricModule {
  final _screen = engine.screen;
  final subscriptions = IsometricSubscriptions();
  late final IsometricRender render;
  late final IsometricSpawn spawn;
  late final IsometricEvents events;

  late ui.Image image;

  final particleEmitters = <ParticleEmitter>[];
  final paths = Float32List(10000);
  final targets = Float32List(10000);
  final particles = <Particle>[];
  final gemSpawns = <GemSpawn>[];
  final environmentObjects = <EnvironmentObject>[];
  final dynamic = <Int8List>[];
  final bake = <Int8List>[];
  final items = <Item>[];
  final totalColumns = Watch(0);
  final totalRows = Watch(0);
  final hours = Watch(0);
  final minutes = Watch(0);
  final ambient = Watch(Shade.Bright);
  final maxAmbientBrightness = Watch(Shade.Bright);
  final nameTextStyle = TextStyle(color: Colors.white);

  var eventsRegistered = false;
  var tiles = <List<int>>[];
  var tilesDst = Float32List(0);
  var tilesSrc = Float32List(0);
  var totalColumnsInt = 0;
  var targetsTotal = 0;
  var totalRowsInt = 0;
  var minRow = 0;
  var maxRow = 0;
  var minColumn = 0;
  var maxColumn = 0;

  Particle? next;

  // PROPERTIES

  bool get dayTime => ambient.value == Shade.Bright;

  int get tileAtMouse {
    if (mouseRow < 0) return Tile.Boundary;
    if (mouseColumn < 0) return Tile.Boundary;
    if (mouseRow >= totalRows.value) return Tile.Boundary;
    if (mouseColumn >= totalColumns.value) return Tile.Boundary;
    return tiles[mouseRow][mouseColumn];
  }

  int get currentPhaseShade {
    return Phase.toShade(phase);
  }

  String get currentAmbientShadeName {
    return shadeName(currentPhaseShade);
  }

  int get phase {
    return Phase.fromHour(hours.value);
  }

  Vector2 get mapCenter {
    final row = totalRows.value ~/ 2;
    final column = totalColumns.value ~/ 2;
    return getTilePosition(row: row, column: column);
  }

  int get totalActiveParticles {
    var totalParticles = 0;
    final length = particles.length;
    for (var i = 0; i < length; i++) {
      if (!particles[i].active) continue;
      totalParticles++;
    }
    return totalParticles;
  }

  bool get boundaryAtMouse => tileAtMouse == Tile.Boundary;

  // CONSTRUCTOR

  IsometricModule(){
    spawn = IsometricSpawn(this);
    events = IsometricEvents(this);
    render = IsometricRender(this);

    for(var i = 0; i < 300; i++){
      particles.add(Particle());
      items.add(Item(type: ItemType.Armour_Plated, x: 0, y: 0));
    }
  }

  // METHODS

  bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
    if (environmentObject.top > _screen.bottom) return false;
    if (environmentObject.right < _screen.left) return false;
    if (environmentObject.left > _screen.right) return false;
    if (environmentObject.bottom < _screen.top) return false;
    return true;
  }

  void sortParticles(){
    insertionSort(
      particles,
      compare: compareParticles,
    );
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

  int getShadeAt(Vector2 position){
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

  bool tileIsWalkable(Vector2 position){
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
    shadeDynamic(getRow(x,  y), getColumn(x, y), value);
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
    final column = getColumn(x, y);
    if (column < 0) return;
    if (column >= shader[0].length) return;
    final row = getRow(x, y);
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
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (outOfBounds(row, column)) return;

    applyShade(shader, row, column, Shade.Medium);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightHigh(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Medium);
    applyShadeRing(shader, row, column, 3, Shade.Dark);
    applyShadeRing(shader, row, column, 4, Shade.Very_Dark);
  }

  void emitLightHighLarge(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Bright);
    applyShadeRing(shader, row, column, 2, Shade.Bright);
    applyShadeRing(shader, row, column, 3, Shade.Medium);
    applyShadeRing(shader, row, column, 4, Shade.Dark);
    applyShadeRing(shader, row, column, 5, Shade.Very_Dark);
  }

  void emitLightBakeHigh(double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (outOfBounds(row, column)) return;
    shadeBake(row, column, Shade.Bright);
    bakeShadeRing(row, column, 1, Shade.Bright);
    bakeShadeRing(row, column, 2, Shade.Medium);
    bakeShadeRing(row, column, 3, Shade.Dark);
    bakeShadeRing(row, column, 4, Shade.Very_Dark);
  }

  void emitLightBrightSmall(List<List<int>> shader, double x, double y) {
    final column = getColumn(x, y);
    final row = getRow(x, y);
    if (outOfBounds(row, column)) return;
    applyShade(shader, row, column, Shade.Bright);
    applyShadeRing(shader, row, column, 1, Shade.Medium);
    applyShadeRing(shader, row, column, 2, Shade.Dark);
    applyShadeRing(shader, row, column, 3, Shade.Very_Dark);
  }

  void applyEnvironmentObjectsToBakeMapping(){
    for (final env in environmentObjects){
      final type = env.type;
      if (type == ObjectType.Torch){
        emitLightBakeHigh(env.x, env.y);
        continue;
      }
      if (type == ObjectType.House01){
        emitLightMedium(bake, env.x, env.y);
        continue;
      }
      if (type == ObjectType.House02){
        emitLightMedium(bake, env.x, env.y);
        continue;
      }
    }
  }


  void resetBakeMap(){
    refreshAmbientLight();
    final ambient = this.ambient.value;
    final rows = this.totalRows.value;
    final columns = this.totalColumns.value;
    bake.clear();
    for (var row = 0; row < rows; row++) {
      final _baked = Int8List(columns);
      bake.add(_baked);
      for (var column = 0; column < columns; column++) {
        _baked[column] = ambient;
      }
    }
    applyEnvironmentObjectsToBakeMapping();
  }

  void resetDynamicMap(){
    final rows = this.totalRows.value;
    final columns = this.totalColumns.value;
    final ambient = this.ambient.value;
    dynamic.clear();
    for (var row = 0; row < rows; row++) {
      final dynamicRow = Int8List(columns);
      dynamic.add(dynamicRow);
      for (var column = 0; column < columns; column++) {
        dynamicRow[column] = ambient;
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

  /// Expensive method
  void resetLighting(){
    refreshTileSize();
    resetBakeMap();
    resetDynamicMap();
    resetDynamicShadesToBakeMap();
    applyDynamicShadeToTileSrc();
  }

  void updateTileRender(){
    resetTilesSrcDst();
    resetLighting();
  }

  /// Expensive
  void setTile({
    required int row,
    required int column,
    required int tile,
  }) {
    if (row < 0) return;
    if (column < 0) return;
    if (row >= totalRows.value) return;
    if (column >= totalColumns.value) return;
    if (tiles[row][column] == tile) return;
    tiles[row][column] = tile;
    resetTilesSrcDst();
  }

  void refreshTileSize(){
    final screen = engine.screen;
    final rows = tiles.length;
    final columns = tiles.length > 0 ? tiles[0].length : 0;
    totalRows.value = rows;
    totalColumns.value = columns;
    minRow = max(0, getRow(screen.left, screen.top));
    maxRow = min(rows, getRow(screen.right, screen.bottom));
    minColumn = max(0, getColumn(screen.right, screen.top));
    maxColumn = min(columns, getColumn(screen.left, screen.bottom));
    if (minRow > maxRow){
      this.minRow = maxRow;
    }
    if (minColumn > maxColumn){
      this.minColumn = maxColumn;
    }
  }

  bool _isBridgeOrWater(int tile){
    return tile != Tile.Water && tile != Tile.Bridge;
  }

  void resetTilesSrcDst() {
    const tileSize = 48.0;
    final rows = tiles.length;
    final columns = rows > 0 ? tiles[0].length : 0;
    final List<double> tileLeft = [];
    for (var rowIndex = 0; rowIndex < rows; rowIndex++) {
      final row = tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < columns; columnIndex++) {
        final tile = row[columnIndex];
        final tileAboveLeft = rowIndex > 0 && _isBridgeOrWater(tiles[rowIndex - 1][columnIndex]);
        final tileAboveRight = columnIndex > 0 && _isBridgeOrWater(row[columnIndex - 1]);
        final tileAbove = rowIndex > 0 &&
            columnIndex > 0 &&
            _isBridgeOrWater(tiles[rowIndex - 1][columnIndex - 1]);

        if (tile == Tile.Water) {
          if (!tileAboveLeft && !tileAboveRight) {
            if (tileAbove) {
              tileLeft.add(waterCorner4);
            } else {
              tileLeft.add(mapTileToSrcLeft(tile));
            }
          } else if (tileAboveLeft) {
            if (tileAboveRight) {
              tileLeft.add(waterCorner3);
            } else {
              if (tileAbove) {
                tileLeft.add(waterHor);
              } else {
                tileLeft.add(waterCorner1);
              }
            }
          } else {
            if (tileAbove) {
              tileLeft.add(waterVer);
            } else {
              tileLeft.add(waterCorner2);
            }
          }
        } else {
          tileLeft.add(mapTileToSrcLeft(tile));
        }
      }
    }

    final tileLeftLength = tileLeft.length;
    final total = tileLeftLength * 4;
    late Float32List tilesDst;
    late Float32List tilesSrc;
    if (this.tilesDst.length != total) {
      tilesDst = Float32List(total);
      tilesSrc = Float32List(total);
    } else {
      tilesDst = this.tilesDst;
      tilesSrc = this.tilesSrc;
    }

    for (var i = 0; i < tileLeftLength; ++i) {
      final index0 = i * 4;
      final index1 = index0 + 1;
      final index2 = index0 + 2;
      final index3 = index0 + 3;
      final row = i ~/ columns;
      final column = i % columns;
      tilesDst[index0] = 1;
      tilesDst[index1] = 0;
      const tileSizeHalf = tileSize / 2;
      tilesDst[index2] = getTileWorldX(row, column) - tileSizeHalf;
      tilesDst[index3] = getTileWorldY(row, column);
      tilesSrc[index0] = 4543 + tileLeft[i];
      tilesSrc[index1] = 1;
      tilesSrc[index2] = tilesSrc[index0] + tileSize;
      tilesSrc[index3] = tilesSrc[index1] + tileSize;
    }
    this.tilesDst = tilesDst;
    this.tilesSrc = tilesSrc;
  }

  void addRow(){
    final List<int> row = [];
    final rows = tiles[0].length;
    for(var i = 0; i < rows; i++){
      row.add(Tile.Grass);
    }
    tiles.add(row);
    _refreshMapTiles();
  }

  void removeRow(){
    tiles.removeLast();
    _refreshMapTiles();
  }

  void _refreshMapTiles(){
    refreshTileSize();
    resetTilesSrcDst();
    resetLighting();
  }

  void addColumn() {
    for (final row in tiles) {
      row.add(Tile.Grass);
    }
    _refreshMapTiles();
  }

  void removeColumn() {
    for (var i = 0; i < tiles.length; i++) {
      tiles[i].removeLast();
    }
    _refreshMapTiles();
  }

  void detractHour(){
    print("isometric.actions.detractHour()");
    hours.value = (hours.value - 1) % 24;
  }

  void addHour(){
    hours.value = (hours.value + 1) % 24;
  }

  void setHour(int hour) {
    // print("isometric.actions.setHour($hour)");
    minutes.value = hour * secondsPerHour;
  }

  void removeGeneratedEnvironmentObjects(){
    const generated = [
      ObjectType.Palisade,
      ObjectType.Palisade_H,
      ObjectType.Palisade_V,
      ObjectType.Rock_Wall,
      ObjectType.Block_Grass,
    ];
    environmentObjects.removeWhere((env) => generated.contains(env));
  }

  void cameraCenterMap(){
    final center = mapCenter;
    engine.cameraCenter(center.x, center.y);
  }

  void applyDynamicEmissions() {
    if (dayTime) return;
    resetDynamicShadesToBakeMap();

    final totalPlayers = game.totalPlayers.value;
    final totalNpcs = game.totalNpcs;
    final players = game.players;
    final npcs = game.interactableNpcs;

    for (var i = 0; i < totalPlayers; i++){
      final player = players[i];
      if (!player.allie) continue;
      emitLightHighLarge(dynamic, player.x, player.y);
    }

    for (var i = 0; i < totalNpcs; i++){
      final npc = npcs[i];
      if (!npc.allie) continue;
      emitLightHigh(dynamic, npc.x, npc.y);
    }

    applyEmissionFromProjectiles();
    applyEmissionFromEffects();
  }

  void applyEmissionFromEffects() {
    for (final effect in game.effects) {
      if (!effect.enabled) continue;
      final percentage = effect.percentage;
      if (percentage < 0.33) {
        emitLightHigh(dynamic, effect.x, effect.y);
        break;
      }
      if (percentage < 0.66) {
        emitLightMedium(dynamic, effect.x, effect.y);
        break;
      }
      emitLightLow(dynamic, effect.x, effect.y);
    }
  }

  void applyEmissionFromProjectiles() {
    final total = game.totalProjectiles;
    final projectiles = game.projectiles;
    for (var i = 0; i < total; i++) {
      final projectile = projectiles[i];
      if (projectile.type != ProjectileType.Fireball) continue;
      emitLightBrightSmall(dynamic, projectile.x, projectile.y);
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

  void refreshAmbientLight(){
    final phase = Phase.fromHour(hours.value);
    final phaseBrightness = Phase.toShade(phase);
    if (maxAmbientBrightness.value > phaseBrightness) return;
    ambient.value = phaseBrightness;
  }

  void refreshGeneratedObjects() {
    final totalRows = tiles.length;
    final totalColumns = totalRows > 0 ? tiles[0].length : 0;
    for (var rowIndex = 0; rowIndex < totalRows; rowIndex++) {
      final row = tiles[rowIndex];
      for (var columnIndex = 0; columnIndex < totalColumns; columnIndex++){
        final tile = row[columnIndex];
        var objectType = tileTypeToObjectType[tile];
        if (objectType == null) continue;

        if (objectType == ObjectType.Palisade) {
          if (rowIndex > 0 && rowIndex < totalRows -1) {
            if (tiles[rowIndex - 1][columnIndex] == Tile.Palisade && tiles[rowIndex + 1][columnIndex] == Tile.Palisade) {
              objectType = ObjectType.Palisade_H;
            }
          }

          if (columnIndex > 0 && columnIndex < totalColumns - 1) {
            if (row[columnIndex -1] == Tile.Palisade && row[columnIndex + 1] == Tile.Palisade) {
              objectType = ObjectType.Palisade_V;
            }
          }
        }

        final env = EnvironmentObject(
            x: getTileWorldX(rowIndex, columnIndex),
            y: getTileWorldY(rowIndex, columnIndex) + halfTileSize,
            type: objectType,
            radius: 0
        );
        environmentObjects.add(env);
      }
    }
  }

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
        spawn.blood(x: particle.x, y: particle.y, z: particle.z, zv: 0, angle: 0, speed: 0);
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
}