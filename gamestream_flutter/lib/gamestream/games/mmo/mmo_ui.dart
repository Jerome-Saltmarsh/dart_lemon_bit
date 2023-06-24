
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/gamestream/games/mmo/mmo_game.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/build_text.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_container.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/gs_dialog.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/nothing.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/on_pressed.dart';
import 'package:golden_ratio/constants.dart';

extension MMOUI on MmoGame {

  Widget buildMMOUI()=> watch(npcText, (npcText) => npcText.isEmpty ? nothing :
    GSDialog(
      child: GSContainer(
          width: 200,
          height: 200 * goldenRatio_0618,
          child: Column(
            children: [
              buildText(npcText),
              onPressed(
                  action: endInteraction,
                  child: buildText("close")),
            ],
          )),
    ));
}