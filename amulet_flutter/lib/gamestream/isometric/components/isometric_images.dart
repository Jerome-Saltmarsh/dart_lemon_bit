
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/sprites/character_shader.dart';
import 'package:lemon_watch/src.dart';
import 'package:amulet_flutter/packages/utils/parse.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/gamestream/sprites/character_sprite_group.dart';
import 'package:amulet_flutter/gamestream/sprites/human_character_sprites.dart';
import 'package:lemon_sprite/lib.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typedef/json.dart';

import 'enums/render_direction.dart';
import 'types/sprite_group_type.dart';



class IsometricImages with IsometricComponent {

  static const dirAssets = 'assets';
  static const dirSprites = '$dirAssets/sprites';
  static const dirIsometric = '$dirSprites/isometric';
  static const dirGoblin = '$dirIsometric/goblin';
  static const dirFallen = '$dirIsometric/fallen';
  static const dirFallenArmoured = '$dirIsometric/fallen_armoured';
  static const dirSkeleton = '$dirIsometric/skeleton';
  static const dirGargoyle = '$dirIsometric/gargoyle';
  static const dirWolf = '$dirIsometric/wolf';
  static const dirZombie = '$dirIsometric/zombie';
  static const dirToadWarrior = '$dirIsometric/toad_warrior';

  var imagesCached = false;
  
  final byteDataEmpty = ByteData(0);
  late final CharacterSpriteGroup kidCharacterSpriteGroupShadow;
  final kidCharacterSpritesIsometricNorth = HumanCharacterSprites();
  final kidCharacterSpritesIsometricEast = HumanCharacterSprites();
  final kidCharacterSpritesIsometricSouth = HumanCharacterSprites();
  final kidCharacterSpritesIsometricWest = HumanCharacterSprites();
  final kidCharacterSpritesIsometricDiffuse = HumanCharacterSprites();

  late final kidCharacterSpritesIsometric = {
    RenderDirection.south: kidCharacterSpritesIsometricSouth,
    RenderDirection.west: kidCharacterSpritesIsometricWest,
    RenderDirection.diffuse: kidCharacterSpritesIsometricDiffuse,
  };

  final kidCharacterSpritesFrontDiffuse = HumanCharacterSprites();

  final totalImagesLoadedPercentage = Watch(0.0);
  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();

  IsometricImages(){
    totalImagesLoaded.onChanged(updateLoadedPerc);
    totalImages.onChanged(updateLoadedPerc);
  }

  void updateLoadedPerc (_)=> totalImagesLoadedPercentage.value = getImageLoadPercentage();

  double getImageLoadPercentage(){
    final total = totalImages.value;
    if (total <= 0){
      return 0;
    }
    final loaded = totalImagesLoaded.value;
    return loaded / total;
  }

  late final CharacterShader characterShaderFallen;
  late final CharacterShader characterShaderFallenArmoured;
  late final CharacterShader characterShaderSkeleton;
  late final CharacterShader characterShaderWolf;
  late final CharacterShader characterShaderZombie;
  late final CharacterShader characterShaderGargoyle;
  late final CharacterShader characterShaderToadWarrior;

  late final Sprite broom;
  late final Sprite woodenCart;
  late final Sprite bed;
  late final Sprite rock1;
  late final Sprite crystal;
  late final Sprite tree1;
  late final Sprite tree03;
  late final Sprite tree04;
  late final Sprite tree05;
  late final Sprite tree06;
  late final Sprite firewood;
  late final Sprite woodenBarrel;
  late final Sprite pumpkin;
  late final Sprite woodenChest;
  late final Sprite flame0;
  late final Sprite flame1;
  late final Sprite flame2;
  late final Sprite butterfly;
  late final Sprite moth;
  late final Sprite bat;
  late final Sprite crystalSouth;
  late final Sprite crystalWest;
  late final Sprite barrelWooden;
  late final Sprite shrine;

  late final CharacterSpriteGroup spriteGroupEmpty;

  late final Sprite spriteEmpty;
  late final dstEmpty = Uint16List(0);

  late final Image empty;
  late final Image shades;
  late final Image shadesTransparent;
  late final Image pixel;
  late final Image atlas_projectiles;
  late final Image atlas_particles;
  late final Image atlas_gameobjects;
  late final Image atlas_nodes;
  late final Image atlas_icons;
  late final Image atlas_amulet_items;
  late final Image square;
  late final Image template_spinning;
  late final Sprite emptySprite;

  @override
  Future onComponentInit(SharedPreferences sharedPreferences) async {
    print('isometric.images.onComponentInitialize()');

    empty = await loadPng('empty');
    loadPng('shades').then((value) => shades = value);
    loadPng('shades_transparent').then((value) => shadesTransparent = value);
    loadPng('square').then((value) => square = value);
    loadPng('atlas_nodes').then((value) => atlas_nodes = value);
    loadPng('atlas_gameobjects').then((value) => atlas_gameobjects = value);
    loadPng('atlas_particles').then((value) => atlas_particles = value);
    loadPng('atlas_projectiles').then((value) => atlas_projectiles = value);
    loadPng('atlas_icons').then((value) => atlas_icons = value);
    loadPng('atlas_amulet_items').then((value) => atlas_amulet_items = value);

    emptySprite = Sprite(
        image: empty,
        src: Float32List(0),
        dst: Float32List(0),
        rows: 0,
        columns: 0,
        srcWidth: 0,
        srcHeight: 0,
    );

    totalImagesLoaded.onChanged((totalImagesLoaded) {
      if (totalImagesLoaded < totalImages.value)
        return;

      _completerImages.complete(true);
    });

    spriteEmpty = Sprite(
        image: empty,
        src: Float32List(0),
        dst: Float32List(0),
        srcWidth: 0,
        srcHeight: 0,
        rows: 0,
        columns: 0,
    );

    spriteGroupEmpty = CharacterSpriteGroup(
        idle: emptySprite,
        running: emptySprite,
        change: emptySprite,
        dead: emptySprite,
        fire: emptySprite,
        strike1: emptySprite,
        strike2: emptySprite,
        hurt: emptySprite,
        casting: emptySprite,
    );

    kidCharacterSpriteGroupShadow = CharacterSpriteGroup(
      idle: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/idle'),
      running: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/running'),
      change: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/change'),
      dead: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/dead'),
      fire: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/fire'),
      strike1: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/strike_1'),
      strike2: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/strike_2'),
      hurt: emptySprite,
      casting: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/casting'),
    );

    for (final kidCharacterSpritesIsometric in kidCharacterSpritesIsometric.values){
      kidCharacterSpritesIsometric.weapons[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.helm[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.armor[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.hair[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.shoes[0] = spriteGroupEmpty;
    }

    // loadSpriteGroupFront(type: SpriteGroupType.Armor, subType: ArmorType.Tunic);
    // loadSpriteGroupFront(type: SpriteGroupType.Head, subType: HeadType.boy);
    // loadSpriteGroupFront(type: SpriteGroupType.Head, subType: HeadType.girl);
    // loadSpriteGroupFront(type: SpriteGroupType.Helm, subType: HelmType.Full_Helm);
    // loadSpriteGroupFront(type: SpriteGroupType.Helm, subType: HelmType.Pointed_Hat_Purple);
    // loadSpriteGroupFront(type: SpriteGroupType.Torso, subType: Gender.male);
    // loadSpriteGroupFront(type: SpriteGroupType.Torso, subType: Gender.female);
    // loadSpriteGroupFront(type: SpriteGroupType.Weapon, subType: WeaponType.Bow);
    // loadSpriteGroupFront(type: SpriteGroupType.Weapon, subType: WeaponType.Staff);
    // loadSpriteGroupFront(type: SpriteGroupType.Weapon, subType: WeaponType.Shortsword);
    // loadSpriteGroupFront(type: SpriteGroupType.Shoes, subType: ShoeType.Leather_Boots);

    for (final direction in const[
      RenderDirection.south,
      RenderDirection.west,
      RenderDirection.diffuse,
    ]){
      for (final armorType in ArmorType.values) {
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Armor,
          subType: armorType,
        );
      }
      for (final headType in HeadType.values){
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Head,
          subType: headType,
        );
      }
      for (final helmType in HelmType.values) {
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Helm,
          subType: helmType,
        );
      }
      for (final gender in Gender.values){
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Torso,
          subType: gender,
        );
      }
      for (final weaponType in WeaponType.valuesNotUnarmed) {
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Weapon,
          subType: weaponType,
          skipStrike: !WeaponType.isMelee(weaponType),
          skipFire: !WeaponType.isBow(weaponType)
        );
      }
      for (final shoeType in ShoeType.values){
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Shoes,
          subType: shoeType,
        );
      }
      for (final hairType in HairType.valuesNotNone) {
        // loadSpriteGroupFront(
        //     type: SpriteGroupType.Hair,
        //     subType: hairType,
        // );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hair,
          subType: hairType,
        );
      };
    }

    loadSprite(name: 'assets/sprites/isometric/butterfly/butterfly')
        .then((value) => butterfly = value);

    loadSprite(name: 'assets/sprites/isometric/moth/moth')
        .then((value) => moth = value);

    loadSprite(name: 'assets/sprites/isometric/crystal')
        .then((value) => crystal = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/rock1')
        .then((value) => rock1 = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/wooden_cart')
        .then((value) => woodenCart = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/broom')
        .then((value) => broom = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/bed')
        .then((value) => bed = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/tree1')
        .then((value) => tree1 = value);

    loadSprite(name: 'assets/sprites/isometric/tree_03')
        .then((value) => tree03 = value);

    loadSprite(name: 'assets/sprites/isometric/tree_04')
        .then((value) => tree04 = value);

    loadSprite(name: 'assets/sprites/isometric/tree_05')
        .then((value) => tree05 = value);

    loadSprite(name: 'assets/sprites/isometric/tree_06')
        .then((value) => tree06 = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/firewood')
        .then((value) => firewood = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/wooden_barrel')
        .then((value) => woodenBarrel = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/pumpkin')
        .then((value) => pumpkin = value);

    loadSprite(name: 'assets/sprites/isometric/gameobjects/wooden_chest')
        .then((value) => woodenChest = value);

    loadSprite(name: 'assets/sprites/isometric/bat/bat')
        .then((value) => bat = value);

    loadSprite(name: 'assets/sprites/isometric/crystal/south')
        .then((value) => crystalSouth = value);

    loadSprite(name: 'assets/sprites/isometric/crystal/west')
        .then((value) => crystalWest = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/barrel',
        atlasX: 995,
        atlasY: 0,
    ).then((value) => barrelWooden = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/shrine',
    ).then((value) => shrine = value);

    loadCharacterShader(dirGoblin).then((value) => characterShaderFallen = value);
    loadCharacterShader(dirFallenArmoured).then((value) => characterShaderFallenArmoured = value);
    loadCharacterShader(dirSkeleton).then((value) => characterShaderSkeleton = value);
    loadCharacterShader(dirGargoyle).then((value) => characterShaderGargoyle = value);
    loadCharacterShader(dirWolf).then((value) => characterShaderWolf = value);
    loadCharacterShader(dirZombie).then((value) => characterShaderZombie = value);
    loadCharacterShader(dirToadWarrior).then((value) => characterShaderToadWarrior = value);

    loadSprite(
        name: 'assets/sprites/isometric/flame/wind0',
        atlasX: 664,
        atlasY: 1681,
        image: atlas_nodes,
    ).then((value) => flame0 = value);
    loadSprite(
        name: 'assets/sprites/isometric/flame/wind1',
        atlasX: 664,
        atlasY: 1733,
        image: atlas_nodes,
    ).then((value) => flame1 = value);
    loadSprite(
        name: 'assets/sprites/isometric/flame/wind2',
        atlasX: 664,
        atlasY: 1778,
        image: atlas_nodes,
    ).then((value) => flame2 = value);

    await _completerImages.future;
  }

  Future<CharacterSpriteGroup> loadCharacterSpriteGroup(String directory) async =>
      CharacterSpriteGroup(
        idle: await loadSprite(name: '$directory/idle'),
        running: await loadSprite(name: '$directory/running'),
        dead: await loadSprite(name: '$directory/dead'),
        strike1: await loadSprite(name: '$directory/strike'),
        strike2: await loadSprite(name: '$directory/strike'),
        hurt: await loadSprite(name: '$directory/hurt'),
        fire: await loadSprite(name: '$directory/fire'),
        change: emptySprite,
        casting: emptySprite,
      );

  void loadSpriteGroupIsometric({
    required int type,
    required int subType,
    required RenderDirection direction,
    bool skipIdle = false,
    bool skipRunning = false,
    bool skipChange = false,
    bool skipDead = false,
    bool skipFire = false,
    bool skipStrike = false,
    bool skipHurt = false,
    bool skipCasting = false,
  }) async {
    final typeName = SpriteGroupType.getName(type).toLowerCase();
    final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase().replaceAll(' ', '_');

    final kidCharacterSprites = kidCharacterSpritesIsometric[direction];

    if (kidCharacterSprites == null){
      throw Exception('loadSpriteGroupIsometric() - kidCharacterSprites == null: $direction');
    }

    final kidCharacterSpriteGroup = kidCharacterSprites.values[type] ?? (throw Exception('images.loadSpriteGroup2($typeName, $subTypeName)'));
    final directory = 'assets/sprites/isometric/kid/${direction.name}/$typeName/$subTypeName';

    kidCharacterSpriteGroup[subType] = CharacterSpriteGroup(
        idle: skipIdle ? emptySprite : await loadSprite(name: '$directory/idle'),
        running: skipRunning ? emptySprite : await loadSprite(name: '$directory/running'),
        change: skipChange ? emptySprite : await loadSprite(name: '$directory/change'),
        dead: skipDead ? emptySprite : await loadSprite(name: '$directory/dead'),
        fire: skipFire ? emptySprite : await loadSprite(name: '$directory/fire'),
        strike1: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike_1'),
        strike2: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike_2'),
        hurt: skipHurt ? emptySprite : await loadSprite(name: '$directory/hurt'),
        casting: skipCasting ? emptySprite : await loadSprite(name: '$directory/casting'),
    );
  }

  // void loadSpriteGroupFront({
  //   required int type,
  //   required int subType,
  // }) async {
  //   final typeName = SpriteGroupType.getName(type).toLowerCase();
  //   final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase().replaceAll(' ', '_');
  //   final kidCharacterSpriteGroup = kidCharacterSpritesFrontDiffuse.values[type] ?? (throw Exception('images.loadSpriteGroupFront($typeName, $subTypeName)'));
  //   final directory = 'assets/sprites/front/kid/diffuse/$typeName/$subTypeName';
  //
  //   kidCharacterSpriteGroup[subType] = CharacterSpriteGroup(
  //     idle: await loadSprite(name: '$directory/idle'),
  //     running: emptySprite,
  //     change: emptySprite,
  //     dead: emptySprite,
  //     fire: emptySprite,
  //     strike1: emptySprite,
  //     strike2: emptySprite,
  //     hurt: emptySprite,
  //     casting: emptySprite,
  //   );
  // }

  parseListDouble(List<dynamic> values) =>
      (values.cast<num>()).map((e) => e.toDouble()).toList(growable: false);

  List<double> readDoubles(dynamic values)=> parseListDouble(values as List);

  Float32List readFloat32List(dynamic values) => Float32List.fromList(readDoubles(values));

  Future<Sprite> loadSprite({
    required String name,
    Image? image,
    int atlasX = 0,
    int atlasY = 0,
  }) async {

    try {
      totalImages.value++;
      image = image ?? await loadImageAsset('$name.png');
      final json = await loadAssetJson('$name.json');

      final src = parse<Float32List>(json['src']);
      final dst = parse<Float32List>(json['dst']);

      if (atlasX != 0 || atlasY != 0){
        final length = dst.length;
        for (var i = 0; i < length; i += 4){
          dst[i + 0] += atlasX;
          dst[i + 1] += atlasY;
          dst[i + 2] += atlasX;
          dst[i + 3] += atlasY;
        }
      }

      totalImagesLoaded.value++;
      return Sprite(
        image: image,
        src: src,
        dst: dst,
        rows: json.getInt('rows'),
        columns: json.getInt('columns'),
        srcWidth: json.getDouble('width'),
        srcHeight: json.getDouble('height'),
      );
    } catch(e) {
      print('exception isometricImages.loadSprite(name: "$name")');
      totalImagesLoaded.value++;
      return emptySprite;
    }
  }

   Future<Image> loadPng(String fileName) async => loadImage('$fileName.png');

   Future<Image> loadImage(String fileName) async {
     totalImages.value++;
     final image = await loadImageAsset('assets/images/$fileName');
     values.add(image);
     totalImagesLoaded.value++;
     return image;
   }

   Future<CharacterShader> loadCharacterShader(String directory) async {

     var loaded = 0;
     final completer = Completer();
     late CharacterSpriteGroup flat;
     late CharacterSpriteGroup shadow;
     late CharacterSpriteGroup south;
     late CharacterSpriteGroup west;

     void onLoadCompleted(){
       loaded++;
       if (loaded >= 4){
         completer.complete(true);
       }
     }

     loadCharacterSpriteGroup('$directory/flat').then((value) {
       flat = value;
       onLoadCompleted();
     });
     loadCharacterSpriteGroup('$directory/shadow').then((value) {
       shadow = value;
       onLoadCompleted();
     });
     loadCharacterSpriteGroup('$directory/south').then((value) {
       south = value;
       onLoadCompleted();
     });
     loadCharacterSpriteGroup('$directory/west').then((value) {
       west = value;
       onLoadCompleted();
     });
     await completer.future;
     return CharacterShader(
       flat: flat,
       west: west,
       south: south,
       shadow: shadow,
     );
   }

  void cacheImages() {

    if (imagesCached)
      return;

    print('images.cacheImages()');
    imagesCached = true;
    final values = images.values;
    for (final image in values) {
      engine.renderSprite(
        image: image,
        srcX: 0,
        srcY: 0,
        srcWidth: 1,
        srcHeight: 1,
        dstX: 0,
        dstY: 0,
      );
    }
  }
}



