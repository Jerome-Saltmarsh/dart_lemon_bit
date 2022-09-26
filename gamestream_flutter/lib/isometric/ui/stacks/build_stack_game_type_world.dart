

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/player.dart';
import 'package:gamestream_flutter/isometric/ui/build_hud.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';

Widget buildStackGameTypeWorld() =>
  Stack(
    children: [
      Positioned(left: 8, bottom: 50, child: buildColumnTeleport()),
      buildBottomPlayerExperienceAndHealthBar(),
      buildWatchBool(player.questAdded, buildContainerQuestUpdated),
    ],
  );