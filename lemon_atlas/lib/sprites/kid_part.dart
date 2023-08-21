
enum KidPart {
  armLeft('arms_left'),
  armRight('arms_right'),
  bodyShirtBlue('shirt_blue'),
  bodyArmsShirtBlue('shirt_blue'),
  handsLeftGauntlet('gauntlets'),
  handsRightGauntlet('gauntlets'),
  head('head'),
  helmsSteel('steel'),
  legsBrown('brown'),
  torso('torso'),
  weaponBow('bow'),
  weaponStaff('staff'),
  weaponSword('sword');

  final String fileName;

  const KidPart(this.fileName);

  static String getGroupName(KidPart part){

    if (const [KidPart.head].contains(part)){
      return 'head';
    }
    if (const [KidPart.torso].contains(part)){
      return 'torso';
    }
    if (const [KidPart.bodyShirtBlue].contains(part)){
      return 'body';
    }
    if (const [KidPart.armLeft].contains(part)){
      return 'arms_left';
    }
    if (const [KidPart.armRight].contains(part)){
      return 'arms_right';
    }

    throw Exception();

  }
}
