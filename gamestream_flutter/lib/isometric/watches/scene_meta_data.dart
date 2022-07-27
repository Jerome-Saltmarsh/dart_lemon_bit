
import 'package:gamestream_flutter/isometric/events/on_changed_meta_data_player_is_owner.dart';
import 'package:lemon_watch/watch.dart';

final sceneMetaDataSceneName = Watch<String?>(null);

final sceneMetaDataMapEditable = Watch(false,
    onChanged: onChangedMetaDataPlayerIsOwner
);
