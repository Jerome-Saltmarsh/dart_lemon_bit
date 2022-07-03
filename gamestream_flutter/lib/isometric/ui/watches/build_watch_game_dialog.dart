
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/enums/game_dialog.dart';

import '../widgets/build_container.dart';

Widget buildWatchGameDialog(){
  return watch(gameDialog, (GameDialog? dialog){
     if (dialog == null) return const SizedBox();
     return container(child: dialog.name);
  });
}