import '../state.dart';

void clearState(){
  print('clearState()');
  playerId = -1;
  gameId = -1;
  playerUUID = "";
  npcs.clear();
  players.clear();
  bullets.clear();
  bulletHoles.clear();
  particles.clear();
  grenades.clear();
  gameEvents.clear();
  playersTransforms.clear();
  tileTransforms.clear();
  playerX = -1;
  playerY = -1;
}