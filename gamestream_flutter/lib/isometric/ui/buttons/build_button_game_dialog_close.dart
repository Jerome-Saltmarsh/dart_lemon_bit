
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

Widget buildButtonGameDialogClose(){
  return text("x", onPressed: gamestream.isometric.editor.actionGameDialogClose);
}