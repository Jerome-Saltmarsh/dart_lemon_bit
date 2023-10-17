
import 'package:gamestream_ws/amulet.dart';

void playerChangeGame({
  required AmuletPlayer player,
  required AmuletGame src,
  required AmuletGame target,
}){
  print('playerChangeGame(src: "${src.scene.name}", target: "${target.scene.name}")');
  src.remove(player);
  target.add(player);
  player.sceneDownloaded = false;
  player.x = 200;
  player.y = 200;
  player.z = 50.0;
}