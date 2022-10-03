
import 'dart:typed_data';

// used to store projectiles particles and gameobjects
class ApiGameObject {
  final positionX = Float32List(100);
  final positionY = Float32List(100);
  final positionZ = Float32List(100);
  final velocityX = Float32List(100);
  final velocityY = Float32List(100);
  final velocityZ = Float32List(100);
  late final List<bool> active;
  late final List<int> inactive;
  final int total;
  var inactiveIndex = 0;

  bool get inactiveIndexAvailable => inactiveIndex >= 0;

  static const No_Active_Index_Available = -1;

  ApiGameObject(this.total){
    active = List.generate(total, (index) => false);
    inactive = List.generate(total, (index) => 0);
    inactiveIndex = active.length - 1;
  }

  void deactivate(int index){
    inactiveIndex++;
    inactive[inactiveIndex] = index;
  }

  int getInactiveIndex() =>
    inactiveIndexAvailable ? inactiveIndex-- : No_Active_Index_Available;

}



// create a sub list of move distances

// next sub sort that list or moves

void sortInts(List<int> numbers){

}