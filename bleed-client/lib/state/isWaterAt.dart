
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/state/getTileAt.dart';

bool isWaterAt(double x, double y){
  return isWater(getTileAt(x, y));
}