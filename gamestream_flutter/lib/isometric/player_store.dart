

import 'package:gamestream_flutter/library.dart';
import 'package:lemon_watch/watch.dart';

import 'events/on_store_items_changed.dart';

final storeItems = Watch(<Weapon>[], onChanged: onPlayerStoreItemsChanged);
final storeVisible = Watch(false, onChanged: GameEvents.onChangedStoreVisible);