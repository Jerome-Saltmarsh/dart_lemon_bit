
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/isometric/enums/editor_dialog.dart';
import 'package:gamestream_flutter/isometric/ui/widgets/build_container.dart';

Widget buildButtonShowDialogLoadScene(){
   return container(
       child: "Load",
       alignment: Alignment.center,
       action: actionGameDialogShowSceneLoad,
   );
}