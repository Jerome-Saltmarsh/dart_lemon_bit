import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/io/custom_game_names.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_select_scene_name.dart';

Widget buildWatchCustomGameNames(){
  return watch(customGameNames, (List<String> gameNames){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: gameNames.map(buildButtonSelectSceneName).toList(),
    );
  });
}