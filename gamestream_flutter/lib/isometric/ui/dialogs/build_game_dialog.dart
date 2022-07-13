

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_quests.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/nothing.dart';

Widget buildGameDialog(GameDialog? value) {
   if (value == null) return nothing;
   switch(value){
     case GameDialog.Quests:
        return buildGameDialogQuests();
     case GameDialog.Inventory:
        return text("Inventory");
     case GameDialog.Map:
        return text("Map");
   }
}