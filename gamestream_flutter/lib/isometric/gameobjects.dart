
import 'package:gamestream_flutter/isometric/classes/game_object.dart';

final gameObjects = <GameObject>[];
var totalGameObjects = 0;


GameObject getInstanceGameObject(){
  if (gameObjects.length <= totalGameObjects){
    gameObjects.add(GameObject());
  }
  return gameObjects[totalGameObjects];
}