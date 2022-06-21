
import '../common/library.dart';

final gridIndex = GridIndex();

class GridIndex {
   var plain = 0;
   var row = 0;
   var column = 0;

   double get x => row * tileSize;
   double get y => column * tileSize;
   double get z => plain * tileHeight;

   GridIndex set({int? plain, int? row, int? column}){
      if (plain != null){
        this.plain = plain;
      }
      if (row != null) {
        this.row = row;
      }
      if (column != null){
        this.column = column;
      }
      return this;
   }
}