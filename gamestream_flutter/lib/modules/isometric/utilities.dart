import 'package:bleed_common/library.dart';
import 'package:lemon_math/library.dart';

Vector2 getTilePosition({required int row, required int column}){
  return Vector2(
    getTileWorldX(row, column),
    getTileWorldY(row, column),
  );
}
