
class InventoryDimensions {
   static const Rows = 10;
   static const Columns = 50;

   static int convertIndexToRow(int index){
     return index ~/ Columns;
   }

   static int convertIndexToColumn(int index){
     return index % Columns;
   }
}