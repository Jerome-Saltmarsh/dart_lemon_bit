import 'package:gamestream_flutter/cube/camera3d.dart';
import 'package:gamestream_flutter/cube/widget.dart';
import 'package:gamestream_flutter/parse.dart';
import 'package:gamestream_flutter/state/game.dart';
import 'package:vector_math/vector_math_64.dart';

void parseCubePlayers(){
  game.totalCubes = consumeInt();
  // scene.world.children.clear();
  for (int i = 0; i < game.totalCubes; i++){
    Vector3 position = _consumeVector3();
    Vector3 rotation = _consumeVector3();
    if (position.x != camera3D.position.x && position.y != camera3D.position.y){
      // scene.world.add(cube(position: position, rotation: rotation));
    }
  }

  cubeFrame.value++;
}

Vector3 _consumeVector3(){
  double x = consumeDouble();
  double y = consumeDouble();
  double z = consumeDouble();
  return Vector3(x, y, z);
}
