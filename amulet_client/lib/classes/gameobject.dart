import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/position.dart';
import 'package:lemon_lang/src.dart';

class GameObject extends Position {
  final int id;
  var type = -1;
  var subType = -1;
  var health = -1;
  var maxHealth = -1;

  GameObject(this.id); // PROPERTIES
  
  double get healthPercentage => health.percentageOf(maxHealth);

  AmuletItem? get amuletItem {
    if (type != ItemType.Amulet_Item) return null;
    return AmuletItem.values.tryGet(subType);
  }

  @override
  String toString() => '{x: ${x.toInt()}, '
      'y: ${y.toInt()}, '
      'z: ${z.toInt()}, '
      'type: ${ItemType.getName(type)}, '
      'subType: ${ItemType.getNameSubType(type, subType)}}';
}
