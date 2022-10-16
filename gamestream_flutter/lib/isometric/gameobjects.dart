
import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';




GameObject getInstanceGameObject(){
  if (Game.gameObjects.length <= Game.totalGameObjects){
    Game.gameObjects.add(GameObject());
  }
  return Game.gameObjects[Game.totalGameObjects++];
}