import 'package:amulet_common/src.dart';
import 'package:lemon_json/src.dart';

import 'amulet_field.dart';

AmuletItemObject? mapJsonToAmuletItemObject(Json? json) {

  if (json == null) {
    return null;
  }

  final amuletItemName = json.getString(AmuletField.Amulet_Item);
  final amuletItem = AmuletItem.findByName(amuletItemName);
  final level = json.tryGetInt(AmuletField.Level);

  if (amuletItem == null || level == null) {
    return null;
  }

  return AmuletItemObject(
      amuletItem: amuletItem,
      level: level,
  );
}
