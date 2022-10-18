
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';

Widget buildButtonGameDialogClose(){
  return text("x", onPressed: actionGameDialogClose);
}