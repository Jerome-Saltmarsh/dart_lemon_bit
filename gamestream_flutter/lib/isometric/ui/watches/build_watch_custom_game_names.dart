import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/io/custom_game_names.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_editor_load_game.dart';

Widget buildWatchCustomGameNames(){
  return watch(customGameNames, (List<String> gameNames){
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: gameNames.map(buildButtonEditorLoadGame).toList(),
      ),
    );
  });
}