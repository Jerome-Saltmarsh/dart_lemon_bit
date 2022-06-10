
final grid = <List<List<int>>>[];
final gridLightBake = <List<List<int>>>[];
final gridLightDynamic = <List<List<int>>>[];

var gridTotalZ = 0;
var gridTotalRows = 0;
var gridTotalColumns = 0;

void gridSetAmbient(int ambient){
  refreshGridMetrics();
  refreshLightMap(gridLightBake, ambient);
  refreshLightMap(gridLightDynamic, ambient);
}

void refreshGridMetrics(){
  gridTotalZ = grid.length;
  gridTotalRows = grid[0].length;
  gridTotalColumns = grid[0][0].length;
}

void refreshLightMap(List<List<List<int>>> map, int ambient){
  map.clear();
  for (var zIndex = 0; zIndex < gridTotalZ; zIndex++) {
    final plain = <List<int>>[];
    map.add(plain);
    for (var rowIndex = 0; rowIndex < gridTotalRows; rowIndex++) {
      final row = <int> [];
      plain.add(row);
      for (var columnIndex = 0; columnIndex < gridTotalColumns; columnIndex++) {
        row.add(ambient);
      }
    }
  }
}