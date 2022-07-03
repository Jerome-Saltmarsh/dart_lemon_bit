
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/dialogs/build_game_dialog.dart';
import 'package:lemon_engine/screen.dart';

Widget buildWatchGameDialog(){
  return watch(gameDialog, (GameDialog? gameDialog){
     if (gameDialog == null) return const SizedBox();

     return Positioned(
       top: 200,
       child: Container(
         width: screen.width,
         child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Container(
                 width: 400,
                 child: buildGameDialog(gameDialog)),
           ],
         ),
       ),
     );
  });
}
