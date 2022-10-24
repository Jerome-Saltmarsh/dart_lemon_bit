

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/enums/game_dialog.dart';
import 'package:gamestream_flutter/library.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog_quests.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/nothing.dart';

import 'build_game_dialog_map.dart';

Widget buildGameDialog(GameDialog? value) {
   if (value == null) return nothing;
   switch(value){
     case GameDialog.Quests:
        return buildGameDialogQuests();
     case GameDialog.Map:
        return buildGameDialogMap();
   }
}