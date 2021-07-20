
import '../maths.dart';
import '../settings.dart';
import '../utils.dart';

dynamic spawnRandomZombie() {
  return spawnZombie(randomBetween(-spawnRadius, spawnRadius), randomBetween(-spawnRadius, spawnRadius));
}