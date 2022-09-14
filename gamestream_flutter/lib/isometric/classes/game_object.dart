import 'package:gamestream_flutter/isometric/classes/vector3.dart';

class GameObject extends Vector3 {
  var type = 0;
  var direction = 0;
  var state = 0;
  /// Used by spawn objects
  var spawnType = 0;
  var spawnAmount = 0;
  var lootType = 0;
}