

import 'package:gamestream_flutter/isometric/classes/weapon.dart';
import 'package:lemon_watch/watch.dart';

import 'events/on_store_items_changed.dart';

final storeItems = Watch(<Weapon>[], onChanged: onPlayerStoreItemsChanged);

bool get storeVisible => storeItems.isNotNull;