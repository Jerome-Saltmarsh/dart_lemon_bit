import 'package:gamestream_flutter/control/events/on_changed_game_type.dart';
import 'package:lemon_watch/watch.dart';

final gameType = Watch<int?>(null, onChanged: onChangedGameType);