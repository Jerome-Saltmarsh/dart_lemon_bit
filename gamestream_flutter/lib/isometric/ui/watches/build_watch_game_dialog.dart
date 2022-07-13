
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/buttons/build_button_game_dialog_close.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog.dart';
import 'package:lemon_engine/screen.dart';

Widget buildWatchGameDialog(){
  return watch(gameDialog, (GameDialog? gameDialog){
     if (gameDialog == null) return const SizedBox();

     return Container(
       width: screen.width,
       height: screen.height,
       alignment: Alignment.center,
       child: Container(
           width: 350,
           height: 400,
           color: brownDark,
           padding: const EdgeInsets.all(6),
           child: Column(
             children: [
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                   buildButtonGameDialogClose(),
                 ],
               ),
               height8,
               buildGameDialog(gameDialog),
             ],
           )),
     );
  });
}
