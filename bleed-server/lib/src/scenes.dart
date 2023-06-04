import 'games/isometric/isometric_scene.dart';
import 'io/load_scene.dart';

class Scenes {
  late IsometricScene suburbs_01;
  late IsometricScene warehouse;
  late IsometricScene warehouse02;
  late IsometricScene town;

  Future load() async {
      suburbs_01 = await loadScene('suburbs_01');
      warehouse = await loadScene('warehouse');
      warehouse02 = await loadScene('warehouse02');
      town = await loadScene('town');
  }
}
