import 'dart:async';

import 'classes.dart';
import 'utils.dart';

StreamController<Npc> onNpcSpawned = StreamController();

void initEvents() {
  onNpcSpawned.stream.listen(_onNpcSpawned);
}

void _onNpcSpawned(Npc character){
  npcSetRandomDestination(character);
}

