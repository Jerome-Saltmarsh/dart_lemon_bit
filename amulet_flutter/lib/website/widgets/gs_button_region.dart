

import 'package:amulet_flutter/isometric/builders/build_watch.dart';
import 'package:amulet_flutter/isometric/enums/connection_region.dart';
import 'package:lemon_watch/src.dart';
import 'package:flutter/material.dart';
import 'package:amulet_flutter/packages/utils/format_enum_name.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class GSButtonRegion extends StatelessWidget {

  final Watch<ConnectionRegion> region;
  final Function action;

  const GSButtonRegion({
    super.key,
    required this.region,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return buildWatch(region, (region) =>
        onPressed(
          hint: 'REGION',
          action: action,
          child: Container(
            height: 30,
            width: 100,
            alignment: Alignment.center,
            color: Colors.white12,
            child: buildText(formatEnumName(region.name)),
          ),
        ));
  }
}