
enum KidPart {
  armLeftRegular('arms_left', 'regular'),
  armRightRegular('arms_right', 'regular'),
  bodyShirtBlue('body', 'shirt_blue'),
  bodyMaleLeatherArmour('body_male', 'leather_armour'),
  bodyMaleArmsShirtBlue('body_arms', 'shirt_blue'),
  bodyFemaleLeatherArmour('body_female', 'leather_armour'),
  handsLeftGauntlet('hands_left', 'gauntlets'),
  handsRightGauntlet('hands_right', 'gauntlets'),
  hairBasic01('hair', 'basic_1'),
  hairBasic02('hair', 'basic_2'),
  head('head', 'regular'),
  helmsSteel('helms', 'steel'),
  helmsWizardHat('helms', 'wizard_hat'),
  legsBrown('legs', 'brown'),
  torsoFemale('torso', 'female'),
  torsoMale('torso', 'male'),
  weaponBow('weapons', 'bow'),
  weaponStaff('weapons', 'staff'),
  weaponSword('weapons', 'sword'),
  shadow('shadow', 'regular'),
  shoesLeftIronPlates('shoes_left', 'iron_plates'),
  shoesRightIronPlates('shoes_right', 'iron_plates'),
  shoesLeftLeatherBoots('shoes_left', 'leather_boots'),
  shoesRightLeatherBoots('shoes_right', 'leather_boots');

  final String fileName;
  final String groupName;

  const KidPart(this.groupName, this.fileName);
}
