

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/isometric/ui/stacks/build_stack_play_mode.dart';

Widget buildStackGameTypeWorld() =>
  Stack(
    children: [
      Positioned(left: 8, bottom: 50, child: buildColumnTeleport()),
    ],
  );