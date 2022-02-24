
import 'package:bleed_client/modules/ui/layouts.dart';
import 'package:bleed_client/modules/ui/style.dart';
import 'package:bleed_client/modules/ui/widgets.dart';

final ui = UI();

class UI {
  final widgets = UIWidgets();
  final style = UIStyle();
  late final UILayouts layouts;

  UI(){
    layouts = UILayouts(style, widgets);
  }
}