
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

Widget buildButtonGameDialogClose(){
  return text("x", onPressed: actionGameDialogClose);
}