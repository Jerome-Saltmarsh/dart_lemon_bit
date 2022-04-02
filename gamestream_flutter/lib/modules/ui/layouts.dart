
import 'package:flutter/widgets.dart';
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/modules/ui/widgets.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';

class UILayouts {

  final UIStyle style;
  final UIWidgets widgets;

  UILayouts(this.style, this.widgets);

  var dots = 0;

  Widget buildLayoutLoading(){
    dots = 0;
    return layout(
      padding: style.layoutPadding,
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widgets.title,
          height32,
          Refresh((){
            var dotText = "";
            var dotSpace = "";
            for(var i = 0; i < dots; i++){
              dotText += ".";
              dotSpace += " ";
            }
            dots = (dots + 1) % 4;
            return text("${dotSpace}LOADING$dotText", size: style.font.large, color: colours.white618);
          }, milliseconds: 200,),
          height(100),
        ],
      )),
    );
  }

}