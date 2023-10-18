
import 'package:gamestream_ws/amulet.dart';

void playerChangeGame({
  required AmuletPlayer player,
  required AmuletGame src,
  required AmuletGame target,
}){
  player.clearPath();
  player.clearTarget();
  src.remove(player);
  target.add(player);
  player.clearCache();
  player.setDestinationToCurrentPosition();
}