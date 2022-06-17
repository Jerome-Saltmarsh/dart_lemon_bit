import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/projectiles.dart';
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
];

// renderOrderLength gets called a lot during rendering so use a const and update it manually if need be
const renderOrderLength = 4;
var renderOrderFirst = renderOrder.first;
var anyRemaining = false;
var totalIndex = 0;

void renderSprites() {
  gridTotalColumnsMinusOne = gridTotalColumns - 1;
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
  @override
  void renderFunction() {
    // TODO: implement renderFunction
  }

  @override
  void updateFunction() {
    // TODO: implement updateFunction
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

  @override
  void renderFunction() {
    renderGridNode(gridZ, gridRow, gridColumn, gridType);
  }

  @override
  void updateFunction() {
    nextGrid();
    while (gridType == GridNodeType.Empty){
      indexNext();
      if (!remaining) return;
      nextGrid();
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
    gridColumn = 0;
    gridRow = 0;
    gridType = 0;
    super.reset();
  }

  void nextGrid(){
    gridRow++;
    gridColumn--;

    if (gridColumn < 0 || gridRow >= gridTotalRows) {
      gridZ++;

      if (gridZ >= gridTotalZ) {
        gridZ = 0;
        gridColumn = gridRow + gridColumn + 1;
        gridRow = 0;
        if (gridColumn >= gridTotalColumns) {
          gridRow = (gridColumn - gridTotalColumnsMinusOne);
          gridColumn = gridTotalColumnsMinusOne;
        }
        final dstY = ((gridRow + gridColumn) * tileSizeHalf) - (gridZ * 24);
        if (dstY > engine.screen.bottom + 50) {
          return end();
        }
      } else {
        gridColumn = gridRow + gridColumn;
        gridRow = 0;
        if (gridColumn >= gridTotalColumns) {
          gridRow = (gridColumn - gridTotalColumnsMinusOne);
          gridColumn = gridTotalColumnsMinusOne;
        }
      }
    }
    gridType = grid[gridZ][gridRow][gridColumn];
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

  void indexNext(){
      index = _index + 1;
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