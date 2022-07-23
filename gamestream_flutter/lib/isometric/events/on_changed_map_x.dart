
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_map.dart';

void onMapTileChanged(int value){
   for (final tile in mapTiles) {
     if (tile.srcIndex != value) continue;
     mapTileActive.x = tile.x;
     mapTileActive.y = tile.y;
   }
}
