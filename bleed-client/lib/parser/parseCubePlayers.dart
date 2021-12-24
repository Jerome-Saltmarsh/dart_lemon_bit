import 'package:bleed_client/cube/cube.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/render/draw/drawCanvas.dart';
import 'package:bleed_client/state/game.dart';
import 'package:vector_math/vector_math_64.dart';

void parseCubePlayers(){
  game.totalCubes = consumeInt();
  scene.world.children.clear();
  for (int i = 0; i < game.totalCubes; i++){
    Vector3 position = _consumeVector3();
    Vector3 rotation = _consumeVector3();
    scene.world.add(cube(position: position, rotation: rotation));
  }
}

Vector3 _consumeVector3(){
  double x = consumeDouble();
  double y = consumeDouble();
  double z = consumeDouble();
  return Vector3(x, y, z);
}
