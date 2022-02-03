
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';

import 'flutterkit.dart';

final _Resources resources = _Resources();

class _Resources {
  final _Icons icons = _Icons();
}

class _Icons {
  final topaz = buildDecorationImage(image: decorationImages.orbTopaz, width: 18, height: 22, color: none, borderColor: none);
  final emerald = buildDecorationImage(image: decorationImages.orbEmerald, width: 14, height: 19, color: none, borderColor: none);
  final ruby = buildDecorationImage(image: decorationImages.orbRuby, width: 14, height: 19, color: none, borderColor: none);
  final sword = buildDecorationImage(image: decorationImages.sword, width: 25, height: 25, color: none, borderColor: none);
  final shield = buildDecorationImage(image: decorationImages.shield, width: 22, height: 26, color: none, borderColor: none);
  final book = buildDecorationImage(image: decorationImages.book, width: 26, height: 26, color: none, borderColor: none);
}