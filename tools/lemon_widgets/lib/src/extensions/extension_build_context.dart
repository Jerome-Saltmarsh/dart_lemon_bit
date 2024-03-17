
import 'package:flutter/cupertino.dart';

extension ExtensionBuildContext on BuildContext {

  double get width => size.width;

  double get height => size.height;

  Size get size => mediaQuery.size;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
}