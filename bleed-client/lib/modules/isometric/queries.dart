import 'state.dart';

class IsometricQueries {
  final IsometricState state;
  IsometricQueries(this.state);

  bool outOfBounds(int row, int column){
    if (row < 0) return true;
    if (column < 0) return true;
    if (row >= state.totalRowsInt) return true;
    if (column >= state.totalColumnsInt) return true;
    return false;
  }
}