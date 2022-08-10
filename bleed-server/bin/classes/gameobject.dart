

import '../common/library.dart';
import 'library.dart';

abstract class GameObject extends Collider {
  GameObject({
    required double x,
    required double y,
    required double z,
    required double radius,
  }) : super(x: x, y: y, z: z, radius: radius);

  void write(Player player);

  void update(){

  }
}

class GameObjectRock extends GameObject {
  GameObjectRock({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10);

  @override
  void write(Player player) {
      player.writeByte(ServerResponse.GameObject_Rock);
      player.writePosition3(this);
  }
}


class GameObjectFlower extends GameObject {
  GameObjectFlower({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10);

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Flower);
    player.writePosition3(this);
  }
}


class GameObjectStick extends GameObject {
  GameObjectStick({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10);

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Stick);
    player.writePosition3(this);
  }
}

class GameObjectButterfly extends GameObject {
  GameObjectButterfly({
    required double x,
    required double y,
    required double z,
  }) : super(x: x, y: y, z: z, radius: 10);

  @override
  void write(Player player) {
    player.writeByte(ServerResponse.GameObject_Butterfly);
    player.writePosition3(this);
  }

  @override
  void update() {
     x += 0.01;
  }
}