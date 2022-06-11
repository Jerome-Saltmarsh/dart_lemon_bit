
import '../common/Tile.dart';

List<List<int>> generateTilesPlain(int rows, int columns){
   final tiles = <List<int>>[];
   for (var rowIndex = 0; rowIndex < rows; rowIndex++){
     final row = <int>[];
     tiles.add(row);
      for (var columnIndex = 0; columnIndex < columns; columnIndex++){
         row.add(Tile.Grass);
      }
   }
   return tiles;
}