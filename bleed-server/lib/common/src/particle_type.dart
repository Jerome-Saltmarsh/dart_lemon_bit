class ParticleType {
  static const Smoke = 0;
  static const Zombie_Head = 2;
  static const Shell = 3;
  static const Zombie_Arm = 4;
  static const Zombie_leg = 5;
  static const Zombie_Torso = 6;
  static const Blood = 7;
  static const Myst = 10;
  static const Pixel = 11;
  static const Orb_Ruby = 12;
  static const Pot_Shard = 13;
  static const Rock = 14;
  static const Tree_Shard = 15;
  static const Block_Wood = 16;
  static const Orb_Shard = 17;
  static const Star_Explosion = 21;
  static const Bubble = 22;
  static const Bubble_Small = 23;
  static const Flame_Pixel = 24;
  static const Fire = 25;
  static const Fire_Purple = 27;
  static const Bullet_Ring = 30;
  static const Character_Death_Slime = 31;
  static const Block_Grass = 32;
  static const Block_Brick = 33;
  static const Water_Drop = 34;
  static const Light_Emission = 36;
  static const Strike_Blade = 38;
  static const Character_Animation_Death_Zombie_1 = 39;
  static const Character_Animation_Death_Zombie_2 = 40;
  static const Character_Animation_Death_Zombie_3 = 41;
  static const Character_Animation_Death_Slime_1 = 41;
  static const Character_Animation_Death_Slime_2 = 42;
  static const Character_Animation_Dog_Death = 43;
  static const Gunshot_Smoke = 44;
  static const Strike_Punch = 45;
  static const Strike_Bullet = 46;
  static const Strike_Bullet_Light = 47;

  static String getName(int particleType){
    return const {
      Smoke: "Smoke",
      Zombie_Head: "Zombie_Head",
      Shell: "Shell",
    }[particleType] ?? "ParticleType name unknown (particleType: $particleType)";
  }
}
