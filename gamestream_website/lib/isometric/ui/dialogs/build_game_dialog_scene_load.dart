
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/load_selected_scene_name.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_custom_game_names.dart';
import 'package:gamestream_flutter/isometric/watches/selected_scene_name.dart';

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
    watch(selectedSceneName, (t) {
      return text(
          "Load",
          onPressed: t == null ? null : loadSelectedSceneName,
          color: t == null ? Colors.white60 : Colors.white
      );
    });

Widget buildButtonDeleteSelectedSceneName() =>
    watch(selectedSceneName, (t) {
      return text(
          "Delete",
          onPressed: t == null ? null : loadSelectedSceneName,
          color: t == null ? Colors.white60 : Colors.white
      );
    });



