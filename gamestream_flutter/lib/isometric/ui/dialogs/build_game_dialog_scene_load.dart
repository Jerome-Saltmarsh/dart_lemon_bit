
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/ui/watches/build_watch_custom_game_names.dart';

import '../../../flutterkit.dart';

Widget buildGameDialogSceneLoad(){
   return Container(
      height: 500,
     child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         text("Load Game Dialog"),
         Container(
             height: 300,
             child: buildWatchCustomGameNames()
         ),
       ],
     ),
   );
}