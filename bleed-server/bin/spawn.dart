import 'classes.dart';
import 'events.dart';
import 'maths.dart';
import 'settings.dart';
import 'state.dart';

void spawnBullet(Character character) {
  Bullet bullet = Bullet(character.x, character.y, velX(character.aimAngle, bulletSpeed), velY(character.aimAngle, bulletSpeed), character.id);
  bullets.add(bullet);
  print("Bullet spawned");
}

Npc spawnNpc(double x, double y) {
  Npc npc = Npc(x: x, y: y, id: _generateId(), health: 5, maxHealth: 5);
  npcs.add(npc);
  onNpcSpawned.add(npc);
  return npc;
}

Npc spawnRandomNpc() {
  return spawnNpc(randomBetween(-spawnRadius, spawnRadius),
      randomBetween(-spawnRadius, spawnRadius));
}

Player spawnPlayer({required String name}){
  Player player = Player(
      id: _generateId(),
      uuid: _generateUUID(),
      x: giveOrTake(50),
      y: giveOrTake(50),
      name: name
  );
  players.add(player);
  return player;
}

String _generateUUID(){
  return uuidGenerator.v4();
}

int _generateId(){
  id++;
  return id;
}
