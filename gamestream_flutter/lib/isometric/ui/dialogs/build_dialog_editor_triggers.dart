
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/widgets/build_text.dart';

Widget buildDialogEditorTriggers(){
   return Container(
     height: 300,
     child: SingleChildScrollView(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           buildText("Edit Triggers"),
           buildText("ON_COLLISION_BETWEEN"),
           buildText("ON_COLLISION_BETWEEN_GAMEOBJECT_AND_ALL_EXCEPT_GAMEOBJECTS"),
           buildText("ON_COLLISION_BETWEEN_GAMEOBJECT_AND_GAMEOBJECT"),
         ],
       ),
     ),
   );
}