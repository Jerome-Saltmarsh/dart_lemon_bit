
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/isometric/classes/game_object.dart';




GameObject getInstanceGameObject(){
  if (GameState.gameObjects.length <= GameState.totalGameObjects){
    GameState.gameObjects.add(GameObject());
  }
  return GameState.gameObjects[GameState.totalGameObjects++];
}