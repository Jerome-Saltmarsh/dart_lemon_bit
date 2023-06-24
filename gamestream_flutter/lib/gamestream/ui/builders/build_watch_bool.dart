
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/nothing.dart';
import 'package:gamestream_flutter/library.dart';

Widget buildWatchBool(
    Watch<bool> watch,
    Widget Function() builder,
    [bool match = true]
    ) =>
    WatchBuilder(watch, (bool value) => value == match ? builder() : nothing);


