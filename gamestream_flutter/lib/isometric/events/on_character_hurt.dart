import 'package:gamestream_flutter/library.dart';

void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {

  randomItem(gamestream.audio.bloody_punches).playXYZ(x, y, z);

  gamestream.audio.heavy_punch_13.playXYZ(x, y, z);

  for (var i = 0; i < 4; i++){
    gamestream.isometricEngine.clientState.spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: randomBetween(1.5, 2),
        angle: angle + giveOrTake(piQuarter),
        speed: randomBetween(1.5, 2.5),
    );
  }


  switch (type) {
    case CharacterType.Zombie:
      if (randomBool()){
        gamestream.audio.zombie_hurt_1.playXYZ(x, y, z);
      } else {
        gamestream.audio.zombie_hurt_4.playXYZ(x, y, z);
      }
      break;
    case CharacterType.Rat:
      gamestream.audio.rat_squeak.playXYZ(x, y, z);
      break;
    case CharacterType.Slime:
      gamestream.audio.bloody_punches_3.playXYZ(x, y, z);
      break;
    case CharacterType.Dog:
      gamestream.audio.dog_woolf_howl_4();
      break;
  }
}
