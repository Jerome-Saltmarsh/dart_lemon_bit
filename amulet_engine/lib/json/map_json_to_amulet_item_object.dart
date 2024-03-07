import 'package:amulet_engine/common.dart';
import 'package:lemon_json/src.dart';

import 'amulet_field.dart';

AmuletItemObject? mapJsonToAmuletItemObject(Json? json) {

  if (json == null) {
    return null;
  }

  final amuletItemName = json.getString(AmuletField.Amulet_Item);
  final amuletItem = AmuletItem.findByName(amuletItemName);

  if (amuletItem == null) {
    return null;
  }

  return AmuletItemObject(
      amuletItem: amuletItem,
      level: json.getInt(AmuletField.Level),
  );
}
