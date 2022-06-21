
import 'package:typedef/json.dart';

import '../classes/enemy_spawn.dart';

EnemySpawn convertJsonToEnemySpawn(dynamic json){
  final j = json as Json;
  return EnemySpawn(
      z: j.getInt('z'),
      row: j.getInt('row'),
      column: j.getInt('column'),
  );
}