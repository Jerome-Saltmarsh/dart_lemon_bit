

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/ui/build_container.dart';

import '../play_mode.dart';
import 'colors.dart';

Widget buildTabsPlayMode(){
   return Row(
     mainAxisAlignment: MainAxisAlignment.center,
     children: playModes.map(buildButtonPlayMode).toList(),
   );
}

Widget buildButtonPlayMode(PlayMode value){
  return watch(playMode, (activePlayMode){
    return container(
      child: value.name,
      action: () => playMode.value = value,
      color: value == activePlayMode ? greyDark : grey
    );
  });
}