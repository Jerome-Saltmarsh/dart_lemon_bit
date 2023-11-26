

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/isometric/io/custom_game_names.dart';
import 'package:gamestream_flutter/network/send_client_request.dart';
import 'package:gamestream_flutter/ui/builders/build_panel_menu.dart';

import 'widgets/build_container.dart';

Widget buildPlayModeFile(){

  return Stack(children: [
    Positioned(top: 0, right: 0, child: buildPanelMenu()),
    Positioned(top: 0, left: 0, child: buildColumnLoadFile()),
  ],);
}

Widget buildColumnLoadFile(){
   return watch(customGameNames, (List<String> gameNames){
     return Column(
       children: gameNames.map(buildButtonLoadGame).toList(),
     );
   });
}

Widget buildButtonLoadGame(String gameName) {
  return container(
    child: gameName,
    action: () => sendClientRequestEditorLoadGame(gameName),
  );
}

