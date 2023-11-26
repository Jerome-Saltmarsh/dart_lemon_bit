
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_player_design.dart';

Widget buildWatchPlayerDesigned(){
  return watch(player.designed, (bool designed){
    if (designed) return Stack(children: [],);
    return buildStackPlayerDesign();
  });
}