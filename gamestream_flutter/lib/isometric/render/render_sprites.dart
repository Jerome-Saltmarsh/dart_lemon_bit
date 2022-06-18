import 'dart:math';

import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
import 'package:gamestream_flutter/isometric/render/render_projectiles.dart';
import 'package:gamestream_flutter/isometric/render/render_zombie.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:lemon_engine/engine.dart';

import '../classes/particle.dart';
import '../grid.dart';
import 'render_character.dart';
import 'render_grid_node.dart';
import 'render_particle.dart';


final renderOrder = <RenderOrder> [
  RenderOrderGrid(),
  RenderOrderPlayer(),
  RenderOrderZombie(),
  RenderOrderParticle(),
  RenderOrderProjectiles(),
];

// renderOrderLength gets called a lot during rendering so use a const and update it manually if need be
const renderOrderLength = 5;
var renderOrderFirst = renderOrder.first;
var anyRemaining = false;
var totalIndex = 0;

void renderSprites() {
  for (final order in renderOrder){
      order.reset();
  }
  updateAnyRemaining();
  totalIndex = 0;
  while (anyRemaining) {
    getNextRenderOrder().render();
    totalIndex++;
  }
}

class RenderOrderZombie extends RenderOrder {
  late Character zombie;

  @override
  void renderFunction() {
    renderZombie(zombie);
  }

  @override
  void updateFunction() {
    zombie = zombies[_index];
    order = zombie.renderOrder;
    orderZ = zombie.indexZ;
  }

  @override
  int getTotal() {
    return totalZombies;
  }
}

class RenderOrderProjectiles extends RenderOrder {
  late Projectile projectile;

  @override
  void renderFunction() {
    renderProjectile(projectile);
  }

  @override
  void updateFunction() {
     projectile = projectiles[_index];
     order = projectile.renderOrder;
     orderZ = projectile.indexZ;
  }

  @override
  int getTotal() {
    return totalProjectiles;
  }
}

class RenderOrderParticle extends RenderOrder {
  late Particle particle;

  @override
  void renderFunction() {
    renderParticle(particle);
  }

  @override
  void updateFunction() {
    particle = particles[_index];
    order = particle.renderOrder;
    orderZ = particle.indexZ;
  }

  @override
  int getTotal() {
    final particleLength = particles.length;
    var totalActive = 0;
    for (var i = 0; i < particleLength; i++){
      if (!particles[i].active) break;
      totalActive++;
    }
    return totalActive;
  }

  @override
  void reset() {
    sortParticles();
    super.reset();
  }
}

class RenderOrderPlayer extends RenderOrder {
  late Character player;

  @override
  void renderFunction() {
    renderCharacter(player);
  }

  @override
  void updateFunction() {
    player = players[_index];
    order = player.renderOrder;
    orderZ = player.indexZ;
  }

  @override
  int getTotal() {
    return totalPlayers;
  }
}

class RenderOrderGrid extends RenderOrder {
  var gridZ = 0;
  var gridColumn = 0;
  var gridRow = 0;
  var gridType = 0;
  var maxColumnRow = 0;
  var gridTotalColumnsMinusOne = 0;
  late List<List<int>> plain;

  @override
  void renderFunction() {
    renderGridNode(gridZ, gridRow, gridColumn, gridType);
  }

  @override
  void updateFunction() {
    nextGridNode();
    while (gridType == GridNodeType.Empty){
      index = _index + 1;
      if (!remaining) return;
      nextGridNode();
    }
    order = ((gridRow + gridColumn) * tileSize) + tileSizeHalf;
    orderZ = gridZ;
  }

  @override
  int getTotal() {
    return gridTotalZ * gridTotalRows * gridTotalColumns;
  }

  @override
  void reset() {
    order = 0;
    orderZ = 0;
    gridZ = 0;
    plain = grid[gridZ];
    gridColumn = 0;
    gridRow = 0;
    gridType = 0;
    gridTotalColumnsMinusOne = gridTotalColumns - 1;

    final left = engine.screen.left;
    final bottom = engine.screen.bottom + (gridTotalZ * tileHeight);
    final screenBottomColumn = convertWorldToColumn(left, bottom);
    final screenBottomRow = convertWorldToRow(left, bottom);
    final screenBottomTotal = screenBottomRow + screenBottomColumn;
    maxColumnRow = min(gridTotalRows + gridTotalColumns, screenBottomTotal);
    super.reset();
  }

  void nextGridNode(){
    gridRow++;
    gridColumn--;

    final worldY = getTileWorldY(gridRow, gridColumn);
    final screenRightRow = convertWorldToRow(engine.screen.right, worldY);

    if (gridColumn < 0 || gridRow >= gridTotalRows || gridRow >= screenRightRow) {

      shiftIndexDown();
      final screenLeftColumn = convertWorldToColumn(engine.screen.left, worldY);

      if (screenLeftColumn < gridColumn){
        final amount = gridColumn - screenLeftColumn;
        gridRow += amount;
        gridColumn-= amount;
      }

      if (gridColumn + gridRow >= maxColumnRow || gridRow >= gridTotalRows || gridColumn >= gridTotalColumns){
        gridZ++;
        if (gridZ >= gridTotalZ) {
          end();
          return;
        }
        gridRow = 0;
        gridColumn = 0;
        plain = grid[gridZ];
      }
    }
    gridType = plain[gridRow][gridColumn];
  }

  void shiftIndexDown(){
    gridColumn = gridRow + gridColumn + 1;
    gridRow = 0;
    if (gridColumn < gridTotalColumns) return;
    gridRow = gridColumn - gridTotalColumnsMinusOne;
    gridColumn = gridTotalColumnsMinusOne;
  }
}



abstract class RenderOrder {
  var _index = 0;
  var total = 0;
  var order = 0.0;
  var orderZ = 0;
  var remaining = true;

  void renderFunction();
  void updateFunction();
  int getTotal();

  void reset(){
    total = getTotal();
    index = 0;
    if (remaining){
      updateFunction();
    }
  }

  // double get renderY => ((order) * tileSizeHalf) - (orderZ * tileHeight);

  @override
  String toString(){
    return "$order: $order, orderZ: $orderZ, index: $_index, total: $total";
  }

  RenderOrder compare(RenderOrder that){
    if (!remaining) return that;
    if (!that.remaining) return this;
    if (order <= that.order) return this;
    if (orderZ < that.orderZ) return this;
    return that;
  }

  void set index(int value){
    _index = value;
    remaining = _index < total;
    if (!remaining){
      updateAnyRemaining();
    }
  }

  void end(){
     index = total;
  }

  void render() {
    assert(remaining);
    renderFunction();
    index = (_index + 1);
    if (remaining) {
      updateFunction();
    } else {
      updateAnyRemaining();
    }
  }
}

RenderOrder getNextRenderOrder(){
  assert (anyRemaining);
  var furthest = renderOrderFirst;
  for (var i = 1; i < renderOrderLength; i++){
    furthest =  furthest.compare(renderOrder[i]);
  }
  assert (furthest.remaining);
  return furthest;
}

void updateAnyRemaining(){
  for (final order in renderOrder){
    if (!order.remaining) continue;
    anyRemaining = true;
    return;
  }
  anyRemaining = false;
}