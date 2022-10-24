
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';
import 'package:gamestream_flutter/isometric/watches/player_entered_scene_name.dart';
import 'package:gamestream_flutter/library.dart';

Widget buildGameDialogSceneSave(){
  return Column(
    children: [
      text("Enter Name"),
      TextField(
        autofocus: true,
        onSubmitted: (value){
          GameEditor.requestSaveScene();
        },
        onChanged: playerEnteredSceneName,
      ),
      container(child: "Save", action: GameEditor.requestSaveScene),
    ],
  );
}
