
import 'package:bleed_common/library.dart';
import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/send.dart';
import 'package:gamestream_flutter/ui/build.dart';
import 'package:gamestream_flutter/ui/builders/build_layout.dart';
import 'package:gamestream_flutter/ui/builders/build_panel.dart';

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

Widget buildLayoutSelectCharacter(){
  return Center(
    child: buildPanel(
      height: 300,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            text("WARRIOR", onPressed: (){
              sendClientRequestSelectCharacterType(CharacterSelection.Warrior);
            }),
            text("WIZARD", onPressed: (){
              sendClientRequestSelectCharacterType(CharacterSelection.Wizard);
            }),
            text("ARCHER", onPressed: (){
              sendClientRequestSelectCharacterType(CharacterSelection.Archer);
            }),
          ],
        ),
      ),
    ),
  );
}
