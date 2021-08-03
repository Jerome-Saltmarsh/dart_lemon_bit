import 'classes.dart';
import 'events.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';
import 'utils.dart';

void spawnBullet(Character character) {
  Bullet bullet = Bullet(
      character.x,
      character.y,
      velX(character.aimAngle + giveOrTake(getWeaponAccuracy(character.weapon)),
          bulletSpeed),
      velY(character.aimAngle + giveOrTake(getWeaponAccuracy(character.weapon)),
          bulletSpeed),
      character.id,
      getWeaponRange(character.weapon));
  bullets.add(bullet);
}

void spawnShell(double x, double y, double rotation) {
  double speed = 8;
  particles.add(Particle(x, y, velX(rotation, speed), velY(rotation, speed), 40, 0, 0.7));
}

void spawnBlood(Character character, double rotation, speed){
  blood.add(Blood(character.x, character.y, velX(rotation, speed), velY(rotation, speed)));
}

Npc spawnNpc(double x, double y) {
  Npc npc = Npc(x: x, y: y, health: 5, maxHealth: 5);
  npcs.add(npc);
  onNpcSpawned.add(npc);
  return npc;
}

Npc spawnRandomNpc() {
  return spawnNpc(randomBetween(-spawnRadius, spawnRadius),
      randomBetween(-spawnRadius, spawnRadius) + 1000);
}

Player spawnPlayer({required String name}) {
  Player player = Player(
      uuid: _generateUUID(),
      x: giveOrTake(50),
      y: 1000 + giveOrTake(50),
      name: name);
  players.add(player);
  return player;
}

String _generateUUID() {
  return uuidGenerator.v4().substring(0, 8);
}
