
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud_debug.dart';
import 'package:gamestream_flutter/isometric/watches/debug_visible.dart';

Widget buildWatchDebugVisible(){
  return watch(debugVisible, (bool debugVisible){
     if (!debugVisible) return const SizedBox();
     return buildHudDebug();
  });
}