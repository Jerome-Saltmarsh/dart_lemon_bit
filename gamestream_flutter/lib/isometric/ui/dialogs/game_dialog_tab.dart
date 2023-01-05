import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

import '../constants/colors.dart';
import '../widgets/build_container.dart';

// final gameDialogTab = watch(player.gameDialog, (GameDialog? gameDialog){
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Row(
//         children: GameDialog.values.map((e) =>
//             container(
//               child: e.name,
//               action: ()=> player.gameDialog.value = e,
//               color: gameDialog == e ? brownDark : brownLight,
//               hoverColor: brownDark,
//             ),
//         ).toList(),
//       ),
//       buildButtonCloseGameDialog(),
//     ],
//   );
// });

Widget buildGameDialog(GameDialog? gameDialog) =>
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: GameDialog.values.map((e) =>
            container(
              child: e.name,
              action: ()=> GamePlayer.gameDialog.value = e,
              color: gameDialog == e ? brownDark : brownLight,
              hoverColor: brownDark,
            ),
        ).toList(),
      ),
      buildButtonCloseGameDialog(),
    ],
  );


Widget buildButtonCloseGameDialog() =>
    container(
      toolTip: "(Press T)",
      child: text("x"),
      alignment: Alignment.center,
      action: actionCloseGameDialog,
    );

void actionCloseGameDialog(){
  GamePlayer.gameDialog.value = null;
}