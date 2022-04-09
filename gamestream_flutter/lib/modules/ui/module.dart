
import 'package:gamestream_flutter/modules/ui/layouts.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';
import 'package:gamestream_flutter/modules/ui/widgets.dart';

final ui = UI();

class UI {
  final widgets = UIWidgets();
  final style = UIStyle();
  late final UILayouts layouts;

  UI(){
    layouts = UILayouts(style, widgets);
  }
}