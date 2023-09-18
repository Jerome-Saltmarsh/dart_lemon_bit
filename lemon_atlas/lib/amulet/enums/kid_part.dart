
enum KidPart {
  armLeftRegular('arms_left', 'regular'),
  armRightRegular('arms_right', 'regular'),
  bodyArmsShirtBlue('body_arms', 'shirt_blue'),
  bodyFemaleLeatherArmour('body_female', 'leather_armour'),
  bodyMaleLeatherArmour('body_male', 'leather_armour'),
  bodyMaleShirtBlue('body_male', 'shirt_blue'),
  hairBack01('hair_back', '01'),
  hairBack02('hair_back', '02'),
  hairBack03('hair_back', '03'),
  hairFront01('hair_front', '01'),
  hairFront02('hair_front', '02'),
  hairFront03('hair_front', '03'),
  hairTop01('hair_top', '01'),
  hairTop02('hair_top', '02'),
  hairTop03('hair_top', '03'),
  handsLeftGauntlet('hands_left', 'gauntlets'),
  handsRightGauntlet('hands_right', 'gauntlets'),
  headBoy('head', 'boy'),
  headGirl('head', 'girl'),
  helmsSteel('helms', 'steel'),
  helmsWizardHat('helms', 'wizard_hat'),
  legsBrown('legs', 'brown'),
  shoesLeftIronPlates('shoes_left', 'iron_plates'),
  shoesRightIronPlates('shoes_right', 'iron_plates'),
  shoesLeftLeatherBoots('shoes_left', 'leather_boots'),
  shoesRightLeatherBoots('shoes_right', 'leather_boots'),
  torsoFemale('torso', 'female'),
  torsoMale('torso', 'male'),
  weaponBow('weapons', 'bow'),
  weaponStaff('weapons', 'staff'),
  weaponSword('weapons', 'sword'),
  shadow('shadow', 'regular'),
  ;

  final String fileName;
  final String groupName;

  const KidPart(this.groupName, this.fileName);
}
