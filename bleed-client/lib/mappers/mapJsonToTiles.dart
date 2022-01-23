
import 'package:bleed_client/common/Tile.dart';

List<List<Tile>> mapJsonToTiles(dynamic json){
  final List<List<Tile>> rows = [];
  for(var jsonRow in json){
    final List<Tile> column = [];
    rows.add(column);
    for(var jsonColumn in jsonRow){
      final Tile tile = parseStringToTile(jsonColumn);
      column.add(tile);
    }
  }
  return rows;
}