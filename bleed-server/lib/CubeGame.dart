import 'package:uuid/uuid.dart';

final CubeGame cubeGame = CubeGame([
  CubePlayer(position: Vector3(), rotation: Vector3()),
  CubePlayer(position: Vector3(x: 3), rotation: Vector3()),
  CubePlayer(position: Vector3(y: 3), rotation: Vector3()),
  CubePlayer(position: Vector3(x: 3, y: 3), rotation: Vector3(x: 45)),
]);

class CubeGame {
  final List<CubePlayer> cubes;
  CubeGame(this.cubes);

  void update(){
    if (cubes.isEmpty) return;
    cubes[0].rotation.x += 0.1;
  }
}

CubePlayer? findCubePlayer(String uuid){
  for(CubePlayer block in cubeGame.cubes) {
    if (block.uuid == uuid) {
      return block;
    }
  }
  return null;
}

final Uuid _uuid = Uuid();

String generateUUID(){
  return _uuid.v1();
}

class CubePlayer {
  final String uuid = generateUUID();
  Vector3 position;
  Vector3 rotation;

  CubePlayer({required this.position, required this.rotation});
}

class Vector3 {
  double x;
  double y;
  double z;
  Vector3({this.x = 0, this.y = 0, this.z = 0});
}
