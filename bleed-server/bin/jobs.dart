import 'classes.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void jobNpcWander() {
  for (Npc npc in npcs) {
    if (npc.targetSet) continue;
    if (npc.destinationSet) continue;
    if (randomBool()) return;
    npcSetRandomDestination(npc);
  }
}

void jobRemoveDisconnectedPlayers(){
  for (int i = 0; i < players.length; i++){
    if (frame - players[i].lastEventFrame > settingsPlayerDisconnectFrames){
      print('Removing disconnected player ${players[i].id}');
      players.removeAt(i);
      i--;
    }
  }
}