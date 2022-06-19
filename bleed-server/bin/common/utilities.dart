import 'tile_size.dart';

double getTileWorldX(int row, int column){
  return (row - column) * tileSizeHalf;
}

double getTileWorldY(int row, int column){
  return (row + column) * tileSizeHalf;
}

