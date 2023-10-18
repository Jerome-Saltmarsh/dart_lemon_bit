
import 'package:gamestream_ws/amulet.dart';

void playerChangeGame({
  required AmuletPlayer player,
  required AmuletGame src,
  required AmuletGame target,
}){
  // print('playerChangeGame(src: "${src.scene.name}", target: "${target.scene.name}")');
  player.clearPath();
  player.clearTarget();
  src.remove(player);
  target.add(player);
  player.clearCache();
  player.setDestinationToCurrentPosition();
}