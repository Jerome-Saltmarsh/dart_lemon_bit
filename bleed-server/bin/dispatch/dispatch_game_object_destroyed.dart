

import '../classes/gameobject.dart';
import '../classes/player.dart';
import '../common/GameEventType.dart';

void dispatchGameObjectDestroyed(List<Player> players, GameObject gameObject){
  for (final player in players){
    player.writeGameEvent(
      type: GameEventType.Game_Object_Destroyed,
      x: gameObject.x,
      y: gameObject.y,
      z: gameObject.z,
      angle: 0,
    );
    player.writeByte(gameObject.type);
  }
}