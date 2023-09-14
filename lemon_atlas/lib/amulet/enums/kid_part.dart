
enum KidPart {
  armLeftRegular('arms_left', 'regular'),
  armRightRegular('arms_right', 'regular'),
  bodyShirtBlue('body', 'shirt_blue'),
  bodyLeatherArmour('body', 'leather_armour'),
  bodyArmsShirtBlue('body_arms', 'shirt_blue'),
  handsLeftGauntlet('hands_left', 'gauntlets'),
  handsRightGauntlet('hands_right', 'gauntlets'),
  hairBasic01('hair', 'basic_1'),
  hairBasic02('hair', 'basic_2'),
  head('head', 'regular'),
  helmsSteel('helms', 'steel'),
  helmsWizardHat('helms', 'wizard_hat'),
  legsBrown('legs', 'brown'),
  torso('torso', 'regular'),
  weaponBow('weapons', 'bow'),
  weaponStaff('weapons', 'staff'),
  weaponSword('weapons', 'sword'),
  shadow('shadow', 'regular'),
  shoesLeftBoots('shoes_left', 'boots'),
  shoesRightBoots('shoes_right', 'boots');

  final String fileName;
  final String groupName;

  const KidPart(this.groupName, this.fileName);
}
