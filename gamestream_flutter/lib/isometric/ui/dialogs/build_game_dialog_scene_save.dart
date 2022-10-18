
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/isometric/editor/actions/save_scene.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/player_entered_scene_name.dart';

Widget buildGameDialogSceneSave(){
  return Column(
    children: [
      text("Enter Name"),
      TextField(
        autofocus: true,
        onSubmitted: (value){
          requestSaveScene();
        },
        onChanged: playerEnteredSceneName,
      ),
      container(child: "Save", action: requestSaveScene),
    ],
  );
}
