import 'package:bleed_common/library.dart';
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class GameState {
  final textEditingControllerMessage = TextEditingController();
  final textFieldMessage = FocusNode();
  final debug = Watch(false);
  final storeTab = Watch(storeTabs[0]);
  final lives = Watch(0);
  final highlightStructureType = Watch<int?>(null);
  final highlightedTechType = Watch<int?>(null);
  final highlightedTechTypeUpgrade = Watch<int?>(null);
  final panelTypeKey = <int, GlobalKey> {};
  final canBuild = Watch(false);
  final playerTextStyle = TextStyle(color: Colors.white);
  final storeColumnKey = GlobalKey();
  final keyPanelStructure = GlobalKey();
  var panningCamera = false;

  GameState(){
    player.weaponType.onChanged((equipped) {
       canBuild.value = equipped == TechType.Hammer;
    });
  }
}




