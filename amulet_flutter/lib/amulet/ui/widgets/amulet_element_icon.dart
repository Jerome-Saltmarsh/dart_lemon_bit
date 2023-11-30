

import 'package:flutter/material.dart';
import 'package:amulet_flutter/amulet/maps/map_amulet_element_to_icon_type.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_icon.dart';

class AmuletElementIcon extends StatelessWidget {

  final AmuletElement amuletElement;

  const AmuletElementIcon({super.key, required this.amuletElement});

  @override
  Widget build(BuildContext context) =>
      IsometricIcon(iconType: mapAmuletElementToIconType(amuletElement));

}