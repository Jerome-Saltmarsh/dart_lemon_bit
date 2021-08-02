import 'classes.dart';
import 'maths.dart';
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