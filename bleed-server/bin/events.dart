import 'dart:async';

import 'classes.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

StreamController<Character> onDeath = StreamController();
StreamController<Npc> onNpcSpawned = StreamController();

void initEvents() {
  onDeath.stream.listen(_onCharacterDeath);
  onNpcSpawned.stream.listen(_onNpcSpawned);
}

void _onNpcSpawned(Npc character){
  npcSetRandomDestination(character);
}

void _onCharacterDeath(Character character) {
  if (character is Npc) {
    Future.delayed(npcDeathVanishDuration, () {
      npcs.remove(character);
    });
  }
}

