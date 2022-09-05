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
  final panelTypeKey = <int, GlobalKey> {};
  final playerTextStyle = TextStyle(color: Colors.white);
}




