class ParticleType {
  static const Smoke              = 00;
  static const Blood              = 06;
  static const Myst               = 07;
  static const Pixel              = 08;
  static const Rock               = 11;
  static const Tree_Shard         = 12;
  static const Block_Wood         = 13;
  static const Fire               = 19;
  static const Block_Grass        = 22;
  static const Block_Brick        = 23;
  static const Water_Drop         = 24;
  static const Light_Emission     = 25;
  static const Gunshot_Smoke      = 27;
  static const Block_Sand         = 31;
  static const Shadow             = 32;
  static const Confetti           = 33;
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
