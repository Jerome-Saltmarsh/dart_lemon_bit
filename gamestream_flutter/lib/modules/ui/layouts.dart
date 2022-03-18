
import 'package:gamestream_flutter/constants/colours.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/modules/ui/widgets.dart';
import 'package:gamestream_flutter/ui/compose/hudUI.dart';
import 'package:flutter/widgets.dart';

class UILayouts {

  final UIStyle style;
  final UIWidgets widgets;

  UILayouts(this.style, this.widgets);

  Widget waitingForGame(){
    return layout(
      padding: style.layoutPadding,
      child: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widgets.title,
          height32,
          text("LOADING", size: style.font.large, color: colours.white618),
          height(100),
        ],
      )),
    );
  }

}