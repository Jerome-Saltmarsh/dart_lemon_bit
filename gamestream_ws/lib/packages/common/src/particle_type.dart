class ParticleType {
  static const Smoke              = 00;
  static const Zombie_Head        = 01;
  static const Shell              = 02;
  static const Zombie_Arm         = 03;
  static const Zombie_leg         = 04;
  static const Zombie_Torso       = 05;
  static const Blood              = 06;
  static const Myst               = 07;
  static const Pixel              = 08;
  static const Orb_Ruby           = 09;
  static const Pot_Shard          = 10;
  static const Rock               = 11;
  static const Tree_Shard         = 12;
  static const Block_Wood         = 13;
  static const Orb_Shard          = 14;
  static const Star_Explosion     = 15;
  static const Bubble             = 16;
  static const Bubble_Small       = 17;
  static const Flame_Pixel        = 18;
  static const Fire               = 19;
  static const Fire_Purple        = 20;
  static const Bullet_Ring        = 21;
  static const Block_Grass        = 22;
  static const Block_Brick        = 23;
  static const Water_Drop         = 24;
  static const Light_Emission     = 25;
  static const Strike_Blade       = 26;
  static const Gunshot_Smoke      = 27;
  static const Strike_Punch       = 28;
  static const Strike_Bullet      = 29;
  static const Strike_Light       = 30;
  static const Block_Sand         = 31;
  static const Shadow             = 32;
  static const Confetti_Red       = 33;
  static const Confetti_Yellow    = 34;
  static const Confetti_Blue      = 35;
  static const Confetti_Green     = 36;
  static const Confetti_Purple    = 37;
  static const Confetti_Cyan      = 38;
  static const Confetti_White      = 39;
  static const Lightning_Bolt     = 40;
  static const Whisp = 41;
  static const Glow = 42;
  static const Butterfly = 43;
  static const Trail = 44;
  static const Bat = 45;
  static const Moth = 46;
  static const Water_Drop_Large = 47;

  static String getName(int particleType) => const {
      Smoke: 'Smoke',
      Shadow: 'Shadow',
      Zombie_Head: 'Zombie_Head',
      Shell: 'Shell',
      Blood: 'Blood',
      Whisp: 'Whisp',
      Water_Drop: 'Water_Drop',
      Myst: 'myst',
      Glow: 'glow',
      Butterfly: 'butterfly',
      Trail: 'trail',
      Moth: 'moth',
      Water_Drop_Large: 'Water_Drop_Large'
    }[particleType] ?? 'unknown-$particleType';
}
