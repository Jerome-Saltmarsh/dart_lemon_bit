

import 'package:amulet_engine/classes/amulet.dart';
// import 'package:amulet_engine/classes/src.dart';


class AmuletSinglePlayer {

  // final AmuletPlayer player;

  late final amulet = Amulet(
      onFixedUpdate: onFixedUpdate,
      isLocalMachine: true,
  );

  void onFixedUpdate(){

  }
}

