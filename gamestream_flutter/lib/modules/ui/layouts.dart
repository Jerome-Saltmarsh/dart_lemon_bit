
import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/game_widgets.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/ui/build.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';

class UILayouts {

  final UIStyle style;

  UILayouts(this.style);
}

Widget buildLayoutWaitingForPlayers(){
  var dots = 0;
  return buildLayout(
    padding: 16,
    child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildTitle(),
        height32,
        Refresh((){
          var dotText = "";
          var dotSpace = "";
          for(var i = 0; i < dots; i++){
            dotText += ".";
            dotSpace += " ";
          }
          dots = (dots + 1) % 4;
          return text("${dotSpace}WAITING FOR PLAYERS$dotText", size: FontSize.Large, color: colours.white);
        }, milliseconds: 200,),
        height(100),
      ],
    )),
  );
}

