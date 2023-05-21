
import 'package:bleed_server/gamestream.dart';

class PlayerAeon extends IsometricPlayer {
  var _attributeHealth = 0;
  var _attributeDamage = 0;
  var _attributeMagic = 0;

  int get attributeHealth => _attributeHealth;
  int get attributeDamage => _attributeDamage;
  int get attributeMagic => _attributeMagic;

  set attributeHealth(int value){
    if (_attributeHealth == value) return;
    _attributeHealth = value;
    writeAttributeValues();
  }

  set attributeDamage(int value){
    if (_attributeDamage == value) return;
    _attributeDamage = value;
    writeAttributeValues();
  }

  set attributeMagic(int value){
    if (_attributeMagic == value) return;
    _attributeMagic = value;
    writeAttributeValues();
  }

  PlayerAeon({required super.game});

  void writeAttributeValues() {
     writeByte(ServerResponse.Api_Player);
     writeByte(ApiPlayer.Attribute_Values);
     writeUInt16(_attributeHealth);
     writeUInt16(_attributeDamage);
     writeUInt16(_attributeMagic);
  }
}