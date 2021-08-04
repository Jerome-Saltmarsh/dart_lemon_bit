import 'dart:async';

import 'classes.dart';
import 'enums.dart';
import 'maths.dart';
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
    if(randomBool()){
      double a = 4;
      particles.add(Particle(character.x, character.y, character.xVel, character.yVel, randomInt(30, 45), 0, randomBetween(0.8, 0.95), ParticleType.Head, 1));
      particles.add(Particle(character.x, character.y, character.xVel + giveOrTake(a), character.yVel + giveOrTake(a), randomInt(30, 45), randomRadion(), randomBetween(0.7, 0.95), ParticleType.Arm, giveOrTake(0.125)));
      particles.add(Particle(character.x, character.y, character.xVel + giveOrTake(a), character.yVel + giveOrTake(a), randomInt(30, 45), randomRadion(), randomBetween(0.7, 0.95), ParticleType.Arm, giveOrTake(0.125)));
      particles.add(Particle(character.x, character.y, character.xVel + giveOrTake(a), character.yVel + giveOrTake(a), randomInt(30, 45), randomRadion(), randomBetween(0.7, 0.95), ParticleType.Organ, giveOrTake(0.125)));
      particles.add(Particle(character.x, character.y, character.xVel + giveOrTake(a), character.yVel + giveOrTake(a), randomInt(30, 45), randomRadion(), randomBetween(0.7, 0.95), ParticleType.Organ, giveOrTake(0.125)));
      npcs.remove(character);
    } else {
      Future.delayed(npcDeathVanishDuration, () {
        npcs.remove(character);
      });
    }



  }
}

