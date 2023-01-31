import 'vector3.dart';

class GameObject extends Vector3 {
  var id = 0;
  var type = 0;
  var direction = 0;
  var state = 0;
  var active = false;
}