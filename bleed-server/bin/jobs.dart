import 'classes.dart';
import 'instances/game.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void jobNpcWander() {
  for (Npc npc in game.npcs) {
    if (npc.targetSet) continue;
    if (npc.destinationSet) continue;
    if (randomBool()) return;
    npcSetRandomDestination(npc);
  }
}

void jobRemoveDisconnectedPlayers(){
  for (int i = 0; i < game.players.length; i++){
    if (frame - game.players[i].lastEventFrame > settingsPlayerDisconnectFrames){
      print('Removing disconnected player ${game.players[i].id}');
      game.players.removeAt(i);
      i--;
    }
  }
}