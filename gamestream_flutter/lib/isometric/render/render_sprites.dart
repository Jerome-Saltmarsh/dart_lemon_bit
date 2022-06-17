import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/render/render_zombie.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';
import 'package:lemon_engine/engine.dart';

import '../grid.dart';
import 'render_character.dart';
import 'render_grid_node.dart';
import 'render_particle.dart';

final renderOrderGrid = RenderOrder(renderNextGridNode, updateNextGrid, "Grid");
final renderOrderPlayer = RenderOrder(renderNextPlayer, updateNextPlayer, "Player");
final renderOrderZombie = RenderOrder(renderNextZombie, updateNextZombie, "Zombie");
final renderOrderParticle = RenderOrder(renderNextParticle, updateNextParticle, "Particle");

final renderOrder = <RenderOrder> [
  renderOrderGrid,
  renderOrderPlayer,
  renderOrderParticle,
  renderOrderZombie,
];
const renderOrderLength = 4;
var renderOrderFirst = renderOrder.first;


var gridZ = 0;
var gridColumn = 0;
var gridRow = 0;
var gridType = 0;

var anyRemaining = false;
var totalIndex = 0;

void updateAnyRemaining(){
  anyRemaining =
      renderOrderGrid.remaining ||
      renderOrderZombie.remaining ||
      renderOrderPlayer.remaining ||
      renderOrderParticle.remaining;
}

void renderSprites() {
  final totalParticles = particles.length;
  gridTotalColumnsMinusOne = gridTotalColumns - 1;

  sortParticles();
  gridZ = 0;
  gridColumn = 0;
  gridRow = 0;
  gridType = 0;

  var totalActiveParticles = 0;
  for (var i = 0; i < totalParticles; i++){
    if (!particles[i].active) break;
    totalActiveParticles++;
  }
  renderOrderGrid.total = gridVolume;
  renderOrderPlayer.total = totalPlayers;
  renderOrderZombie.total = totalZombies;
  renderOrderParticle.total = totalActiveParticles;
  renderOrderGrid.index = 0;
  renderOrderZombie.index = 0;
  renderOrderParticle.index = 0;
  renderOrderPlayer.index = 0;

  if (renderOrderPlayer.remaining) {
    updateNextPlayer(0);
  }
  if (renderOrderGrid.remaining){
    renderOrderGrid.order = 0;
    renderOrderGrid.orderZ = 0;
    gridType = grid[gridZ][gridType][gridColumn];
    if (gridType == GridNodeType.Empty){
      updateNextGrid(0);
    }
  }
  if (renderOrderParticle.remaining){
    updateNextParticle(0);
  }
  if (renderOrderZombie.remaining){
    updateNextZombie(0);
  }
  updateAnyRemaining();
  totalIndex = 0;
  while (anyRemaining) {
    getNextRenderOrder().render();
    totalIndex++;
  }
}

// class RenderOrderGrid extends RenderOrder {
//
// }

class RenderOrder {
  var _index = 0;
  var total = 0;
  var order = 0;
  var orderZ = 0;
  var remaining = true;
  final String name;
  final Function(int index) renderFunction;
  final Function(int index) updateFunction;

  double get renderY => ((order) * tileSizeHalf) - (orderZ * tileHeight);

  @override
  String toString(){
    return "$name: name, order: $order, orderZ: $orderZ, index: $_index, total: $total";
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

  RenderOrder(this.renderFunction, this.updateFunction, this.name);

  void indexNext(){
      index = _index + 1;
  }

  void render() {
    assert(remaining);

    renderFunction(_index);
    index = (_index + 1);
    if (remaining) {
      updateFunction(_index);
    } else {
      updateAnyRemaining();
    }
  }
}

void renderNextGridNode(int index) {
  renderGridNode(gridZ, gridRow, gridColumn, gridType);
}

void renderNextZombie(int index){
   renderZombie(zombies[index]);
}

void renderNextPlayer(int index) {
  renderCharacter(players[index]);
}

void renderNextParticle(int index){
  renderParticle(particles[index]);
}

void updateNextGrid(int index){
  nextGrid();
  while (gridType == GridNodeType.Empty){
    renderOrderGrid.indexNext();
    if (!renderOrderGrid.remaining) return;
    nextGrid();
  }
  renderOrderGrid.order = gridRow + gridColumn;
  renderOrderGrid.orderZ = gridZ;
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
        renderOrderGrid.end();
        return;
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

void updateNextPlayer(int index) {
   final player = players[index];
   renderOrderPlayer.order = player.renderOrder;
   renderOrderPlayer.orderZ = player.indexZ;
}

void updateNextZombie(int index){
  final zombie = zombies[index];
  renderOrderZombie.order = zombie.renderOrder;
  renderOrderZombie.orderZ = zombie.indexZ;
}

void updateNextParticle(int index){
  final particle = particles[index];
  renderOrderParticle.order = particle.renderOrder;
  renderOrderParticle.orderZ = particle.indexZ;
}

RenderOrder getNextRenderOrder(){
  var furthest = renderOrderFirst;
  for (var i = 1; i < renderOrderLength; i++){
    furthest =  furthest.compare(renderOrder[i]);
  }
  assert (furthest.remaining);
  return furthest;
}
