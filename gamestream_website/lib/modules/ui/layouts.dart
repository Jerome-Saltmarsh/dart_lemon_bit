
import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/ui/build.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';

class UILayouts {

  final UIStyle style;

  UILayouts(this.style);

  var dots = 0;

  Widget buildLayoutLoading(){
    dots = 0;
    return buildLayout(
      padding: style.layoutPadding,
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          text("CONNECTING", color: colours.white80),
        ],
        // children: [
        //   buildTitle(),
        //   height32,
        //   Refresh((){
        //     var dotText = "";
        //     var dotSpace = "";
        //     for(var i = 0; i < dots; i++){
        //       dotText += ".";
        //       dotSpace += " ";
        //     }
        //     dots = (dots + 1) % 4;
        //     return text("${dotSpace}LOADING$dotText", size: FontSize.Large, color: colours.white618);
        //   }, milliseconds: 200,),
        //   height(100),
        // ],
      )),
    );
  }
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

