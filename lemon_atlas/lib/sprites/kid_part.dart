
enum KidPart {
  armLeftRegular('arms_left', 'regular'),
  armRightRegular('arms_right', 'regular'),
  bodyShirtBlue('body', 'shirt_blue'),
  bodyArmsShirtBlue('body_arms', 'shirt_blue'),
  handsLeftGauntlet('hands_left', 'gauntlets'),
  handsRightGauntlet('hands_right', 'gauntlets'),
  head('head', 'regular'),
  helmsSteel('helms', 'steel'),
  legsBrown('legs', 'brown'),
  torso('torso', 'regular'),
  weaponBow('weapons', 'bow'),
  weaponStaff('weapons', 'staff'),
  weaponSword('weapons', 'sword'),
  shadow('shadow', 'regular');

  final String fileName;
  final String groupName;

  const KidPart(this.groupName, this.fileName);
}
