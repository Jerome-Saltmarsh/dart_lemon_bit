
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/state/decorationImages.dart';

final _Resources resources = _Resources();

class _Resources {
  final _Icons icons = _Icons();
}

class _Icons {
  final topaz = buildDecorationImage(image: decorationImages.orbTopaz, width: 18, height: 22, color: none, borderColor: none);
  final emerald = buildDecorationImage(image: decorationImages.orbEmerald, width: 14, height: 19, color: none, borderColor: none);
  final ruby = buildDecorationImage(image: decorationImages.orbRuby, width: 14, height: 19, color: none, borderColor: none);
}