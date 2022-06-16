import 'package:bleed_common/grid_node_type.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/players.dart';
import 'package:gamestream_flutter/isometric/render/render_zombie.dart';
import 'package:gamestream_flutter/isometric/zombies.dart';

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

final indexRenderOrderGrid = renderOrder.indexOf(renderOrderGrid);
final indexRenderOrderPlayer = renderOrder.indexOf(renderOrderPlayer);
final indexRenderOrderParticle = renderOrder.indexOf(renderOrderParticle);
final indexRenderOrderZombie = renderOrder.indexOf(renderOrderZombie);
final renderOrderLength = renderOrder.length;

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

  renderOrderGrid.index = 0;
  renderOrderZombie.index = 0;
  renderOrderParticle.index = 0;
  renderOrderPlayer.index = 0;
  renderOrderGrid.total = gridTotalZ * gridTotalRows * gridTotalColumns;
  renderOrderPlayer.total = totalPlayers;
  renderOrderZombie.total = totalZombies;
  renderOrderParticle.total = totalActiveParticles;

  for(final order in renderOrder){
    order.updateRemaining();
  }

  if (renderOrderPlayer.remaining) {
    updateNextPlayer(0);
  }
  if (renderOrderGrid.remaining){
    renderOrderGrid.order = 0;
    renderOrderGrid.orderZ = 0;
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

class RenderOrder {
  var index = 0;
  var total = 0;
  var order = 0;
  var orderZ = 0;
  var remaining = true;
  final String name;
  final Function(int index) renderFunction;
  final Function(int index) updateFunction;


  void updateRemaining(){
    remaining = index < total;
  }

  RenderOrder(this.renderFunction, this.updateFunction, this.name);

  void render() {
    assert(remaining);
    renderFunction(index);
    index++;
    remaining = index < total;
    if (remaining) {
      updateFunction(index);
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
  // print("player index: $totalIndex");
}

void renderNextParticle(int index){
  renderParticle(particles[index]);
}

void updateNextGrid(int index){
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
  if (gridType == GridNodeType.Empty) {
    renderOrderGrid.order = -255;
    renderOrderGrid.orderZ = -255;
  } else {
    renderOrderGrid.order = gridRow + gridColumn;
    renderOrderGrid.orderZ = gridZ;
  }
}

void updateNextPlayer(int index) {
   final player = players[index];
   renderOrderPlayer.order = player.renderOrder;
   renderOrderPlayer.orderZ = player.indexZ;
}

void updateNextZombie(int index){
  final zombie = zombies[index];
  renderOrderPlayer.order = zombie.renderOrder;
  renderOrderPlayer.orderZ = zombie.indexZ;
}

void updateNextParticle(int index){
  final particle = particles[index];
  renderOrderPlayer.order = particle.renderOrder;
  renderOrderPlayer.orderZ = particle.indexZ;
}

RenderOrder getNextRenderOrder(){
  final firstIndex = getFirstIndex();
  var furthest = renderOrder[firstIndex];
  for (var i = firstIndex + 1; i < renderOrderLength; i++){
    if (!renderOrder[i].remaining) continue;
    final r = renderOrder[i];
    if (r.order == furthest.order){
      if (r.orderZ > furthest.orderZ) continue;
    }
    if (r.order > furthest.order) continue;
    furthest = r;
  }
  return furthest;
}

int getFirstIndex(){
   if (renderOrderGrid.remaining) return indexRenderOrderGrid;
   if (renderOrderPlayer.remaining) return indexRenderOrderPlayer;
   if (renderOrderZombie.remaining) return indexRenderOrderZombie;
   if (renderOrderParticle.remaining) return indexRenderOrderParticle;
   throw Exception();
}

RenderOrder compare(RenderOrder a, RenderOrder b){
  if (a.order == b.order){
    if (a.orderZ > b.orderZ) return b;
  }
  if (a.order > b.order) return b;
  return a;
}