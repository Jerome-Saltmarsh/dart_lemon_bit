import 'dart:async';

import 'classes.dart';
import 'settings.dart';
import 'state.dart';

StreamController<Character> onDeath = StreamController();

void initEvents() {
  onDeath.stream.listen(_onCharacterDeath);
}

void _onCharacterDeath(Character character) {
  if (character is Npc) {
    Future.delayed(npcDeathVanishDuration, () {
      npcs.remove(character);
    });
  }
}
