import 'package:gamestream_flutter/isometric/events/on_changed_active_player_design_tab.dart';
import 'package:gamestream_flutter/isometric/ui/enums/player_design_tab.dart';
import 'package:lemon_watch/watch.dart';

final activePlayerDesignTab = Watch(PlayerDesignTab.Class, onChanged: onChangedActivePlayerDesignTab);