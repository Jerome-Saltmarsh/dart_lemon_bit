import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';

import 'enums.dart';

class GameState {
  final textEditingControllerMessage = TextEditingController();
  final textFieldMessage = FocusNode();
  final debug = Watch(false);
  final storeTab = Watch(storeTabs[0]);
  final panelTypeKey = <int, GlobalKey> {};
  final playerTextStyle = TextStyle(color: Colors.white);
  final mapVisible = Watch(false, onChanged: (bool value){
    print("map visible: $value");
  });
}




