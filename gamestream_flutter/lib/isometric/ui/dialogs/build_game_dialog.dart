

import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/nothing.dart';

Widget buildGameDialog(GameDialog? value) =>
    value == null ? nothing :
   Container(
      child: text(value.name),
   );