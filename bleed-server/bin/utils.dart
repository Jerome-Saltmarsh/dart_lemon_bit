import 'common.dart';
import 'game_maths.dart';

double bulletDistanceTravelled(dynamic bullet) {
  return distance(
      bullet[keyPositionX],
      bullet[keyPositionY],
      bullet[keyStartX],
      bullet[keyStartY]
  );
}
