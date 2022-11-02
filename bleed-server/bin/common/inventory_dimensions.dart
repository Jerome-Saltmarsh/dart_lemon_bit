
class InventoryDimensions {
   static const Rows = 5;
   static const Columns = 10;

   static int convertIndexToRow(int index){
     return index ~/ Columns;
   }

   static int convertIndexToColumn(int index){
     return index % Columns;
   }
   
   static int convertToIndex({required int row, required int column}){
     return row * Columns + column;
   }
}