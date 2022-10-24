
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_custom_game_names.dart';

Widget buildGameDialogSceneLoad(){
   return Column(
     children: [
       Container(
           height: 200,
           child: SingleChildScrollView(child: buildWatchCustomGameNames())
       ),
       Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
           buildButtonLoadSelectedSceneName(),
           // text("Delete"),
           // text("Rename"),
         ],
       )
     ],
   );
}

Widget buildButtonLoadSelectedSceneName() =>
    watch(GameEditor.selectedSceneName, (t) {
      return text(
          "Load",
          onPressed: t == null ? null : GameActions.loadSelectedSceneName,
          color: t == null ? Colors.white60 : Colors.white
      );
    });

Widget buildButtonDeleteSelectedSceneName() =>
    watch(GameEditor.selectedSceneName, (t) {
      return text(
          "Delete",
          onPressed: t == null ? null : GameActions.loadSelectedSceneName,
          color: t == null ? Colors.white60 : Colors.white
      );
    });



