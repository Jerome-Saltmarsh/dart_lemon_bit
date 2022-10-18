
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';

Widget buildDialogEditorTriggers(){
   return Container(
     height: 300,
     child: SingleChildScrollView(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           text("Edit Triggers"),
           text("ON_COLLISION_BETWEEN"),
           text("ON_COLLISION_BETWEEN_GAMEOBJECT_AND_ALL_EXCEPT_GAMEOBJECTS"),
           text("ON_COLLISION_BETWEEN_GAMEOBJECT_AND_GAMEOBJECT"),
         ],
       ),
     ),
   );
}