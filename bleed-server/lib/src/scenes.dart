import 'package:bleed_server/gamestream.dart';

import 'io/load_scene.dart';

class Scenes {
  late Scene suburbs_01;
  late Scene warehouse;
  late Scene warehouse02;
  late Scene town;

  Future load() async {
      suburbs_01 = await loadScene('suburbs_01');
      warehouse = await loadScene('warehouse');
      warehouse02 = await loadScene('warehouse02');
      town = await loadScene('town');
  }
}
