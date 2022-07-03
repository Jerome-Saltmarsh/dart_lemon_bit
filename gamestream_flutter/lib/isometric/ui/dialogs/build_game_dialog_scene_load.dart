
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/load_selected_scene_name.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_custom_game_names.dart';
import 'package:gamestream_flutter/isometric/watches/selected_scene_name.dart';

Widget buildGameDialogSceneLoad(){
  const width = 350.0;
   return Column(
     children: [
       Container(
         width: width,
         padding: EdgeInsets.all(6),
         color: brownDark,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.end,
           children: [
             text("x", onPressed: actionGameDialogClose),
           ],
         ),
       ),
       Container(
           width: width,
           constraints: BoxConstraints(
             maxHeight: 350,
           ),
           color: brownDark,
           child: SingleChildScrollView(child: buildWatchCustomGameNames())
       ),
       Container(
         width: width,
         padding: EdgeInsets.all(6),
         color: brownDark,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
           children: [
             buildButtonLoadSelectedSceneName(),
             // text("Delete"),
             // text("Rename"),
           ],
         ),
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

