
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';

Json convertEnemySpawnToJson(EnemySpawn enemySpawn){
  final json = Json();
  json['z'] = enemySpawn.z;
  json['row'] = enemySpawn.row;
  json['column'] = enemySpawn.column;
  json['max'] = enemySpawn.max;
  return json;
}