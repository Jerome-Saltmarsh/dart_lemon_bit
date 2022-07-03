
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/actions/load_selected_scene_name.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_custom_game_names.dart';

Widget buildGameDialogSceneLoad(){
   return Column(
     children: [
       Container(
         width: 350,
         padding: EdgeInsets.all(6),
         color: brownDark,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             text("Load", onPressed: loadSelectedSceneName),
             text("Delete"),
             text("Rename"),
             text("Close"),
           ],
         ),
       ),
       Container(
           height: 300,
           child: SingleChildScrollView(child: buildWatchCustomGameNames())
       ),
     ],
   );
}