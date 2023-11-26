
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:lemon_watch/src.dart';

Widget buildWatchBool(
    Watch<bool> watch,
    Widget Function() builder,
    {bool match = true}
    ) =>
    WatchBuilder(watch, (bool value) => value == match ? builder() : nothing);


