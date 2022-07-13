
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/map_atlas.dart';
import 'package:gamestream_flutter/isometric/ui/constants/colors.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/screen.dart';
import 'package:lemon_engine/state/paint.dart';

import '../../../flutterkit.dart';
import 'build_game_dialog_quests.dart';

final f = ValueNotifier<int>(0);

Widget buildGameDialogMap(){
  return Container(
    width: screen.width,
    height: screen.height,
    alignment: Alignment.center,
    child: Container(
      color: brownLight,
      width: screen.width * goldenRatio_0618,
      height: screen.height * goldenRatio_0618,
      child: Column(
        children: [
          gameDialogTab,
          buildCanvas(paint: (Canvas canvas, Size size) {
              canvas.drawImage(mapAtlas, Offset(0, 0), paint);
          }, frame: f)
        ],
      ),
    ),
  );
}