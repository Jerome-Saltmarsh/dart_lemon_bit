

import 'dart:typed_data';

/// classes may not contain methods
/// classes may only contain basic data
/// no references to other classes
///
/// this allows us to have thousands of particles with needing to create any objects
/// this is very important for a particle system
/// otherwise it could slow down the system when scaled to large amounts
///
/// the beautiful thing is that none of the information shifts
///
/// no pointers are moved and no garbage collection takes place
///
/// zero garbage collection particle engine
///
/// create a game which instantly starts
///
/// if its the players first time visiting the site
///
/// instantly start a game
///
/// try to dynamically work out what region they are
///
/// do not ask for a region
///
/// take the user to the game and start playing
///
/// explain the instructions while the game is loading
///
/// if the user is killed offer to do a tutorial
///
/// if the user is not moving offer instructions
class ApiParticles {
  final int total;
  late final Uint32List order;
  late final Float32List render;
  late final Float32List velocityX;
  late final Float32List velocityY;
  late final Float32List velocityZ;
  late final Float32List positionX;
  late final Float32List positionY;
  late final Float32List positionZ;
  late final Float32List weight;
  late final Uint16List duration;
  late final Uint8List type;
  late final List<bool> active;

  ApiParticles(this.total) {
    const maxInt32 = 2147483647;
    if (total > maxInt32){
      throw Exception('total ($total) cannot be bigger  than $maxInt32');
    }
    if (total < 0) {
      throw Exception("total cannot be negative");
    }
    order = Uint32List(total);
    render = Float32List(total);
    velocityX = Float32List(total);
    velocityY = Float32List(total);
    velocityZ = Float32List(total);
    positionX = Float32List(total);
    positionY = Float32List(total);
    positionZ = Float32List(total);
    weight = Float32List(total);
    duration = Uint16List(total);
    type = Uint8List(total);
    active = List<bool>.generate(total, (index) => false);
  }

  /// render the order list using the values from render
  void sortRenderOrder(){

  }

  /// Insertion sort
  void sortActive(){
    for (var pos = 1; pos < total; pos++) {
      var min = 0;
      var max = pos;
      var index = order[pos];
      var element = active[index];
      while (min < max) {
        var mid = min + ((max - min) >> 1);
        if (!active[order[mid]]) {
          max = mid;
        } else {
          min = mid + 1;
        }
      }
      order.setRange(min + 1, index + 1, order, min);
      active[order[min]] = element;
    }
  }
}


