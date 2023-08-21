
enum PartType {
  regular,
  gauntlets,
  brown
}

const parts = {
  'arms_left' : ['regular'],
  'arms_right' : ['regular'],
  'hands_left' : ['gauntlets'],
};

enum KidPart {
  armLeftRegular('arms_left'),
  armRightRegular('arms_right'),
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
    if (const [KidPart.armLeftRegular].contains(part)){
      return 'arms_left_regular';
    }
    if (const [KidPart.armRightRegular].contains(part)){
      return 'arms_right_regular';
    }
    if (const [KidPart.handsLeftGauntlet].contains(part)){
      return 'hands_left';
    }
    if (const [KidPart.handsRightGauntlet].contains(part)){
      return 'hands_right';
    }

    throw Exception('KidPart.getGroupName($part)');
  }
}
