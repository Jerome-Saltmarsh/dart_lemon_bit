
import 'package:bleed_server/common/src/isometric/character_type.dart';
import 'package:bleed_server/common/src/isometric/item_type.dart';

import 'isometric_character.dart';

class IsometricCharacterTemplate extends IsometricCharacter {
  var _headType = ItemType.Head_Steel_Helm;
  var _bodyType = ItemType.Body_Shirt_Cyan;
  var _legsType = ItemType.Legs_Blue;

  IsometricCharacterTemplate({
    required super.x,
    required super.y,
    required super.z,
    required super.health,
    required super.weaponType,
    required super.weaponRange,
    required super.team,
    required super.damage,
  }) : super(characterType: CharacterType.Template);

  int get headType => _headType;
  int get bodyType => _bodyType;
  int get legsType => _legsType;

  set headType(int value){
    assert (value == ItemType.Empty || ItemType.isTypeHead(value));
    if (_headType == value) return;
    _headType = value;
    onEquipmentChanged();
  }

  set bodyType(int value){
    assert (value == ItemType.Empty || ItemType.isTypeBody(value));
    if (_bodyType == value) return;
    _bodyType = value;
    onEquipmentChanged();
  }

  set legsType(int value) {
    assert (value == ItemType.Empty || ItemType.isTypeLegs(value));
    if (_legsType == value) return;
    _legsType = value;
    onEquipmentChanged();
  }

  /// safe to override
  void onEquipmentChanged() {}
}