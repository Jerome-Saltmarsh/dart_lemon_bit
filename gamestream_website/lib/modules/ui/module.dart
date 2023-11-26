
import 'package:gamestream_flutter/modules/ui/layouts.dart';
import 'package:gamestream_flutter/modules/ui/style.dart';

final ui = UI();

class UI {
  final style = UIStyle();
  late final UILayouts layouts;

  UI(){
    layouts = UILayouts(style);
  }
}