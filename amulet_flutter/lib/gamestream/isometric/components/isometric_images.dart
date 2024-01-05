
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_flutter/gamestream/sprites/character_shader.dart';
import 'package:lemon_watch/src.dart';
import 'package:amulet_flutter/packages/utils/parse.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:amulet_flutter/gamestream/sprites/character_sprite_group.dart';
import 'package:amulet_flutter/gamestream/sprites/kid_character_sprites.dart';
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
  static const dirFallen = '$dirIsometric/fallen';
  static const dirFallenArmoured = '$dirIsometric/fallen_armoured';
  static const dirSkeleton = '$dirIsometric/skeleton';
  static const dirWolf = '$dirIsometric/wolf';
  static const dirZombie = '$dirIsometric/zombie';

  var imagesCached = false;
  
  final byteDataEmpty = ByteData(0);
  late final CharacterSpriteGroup kidCharacterSpriteGroupShadow;
  final kidCharacterSpritesIsometricNorth = KidCharacterSprites();
  final kidCharacterSpritesIsometricEast = KidCharacterSprites();
  final kidCharacterSpritesIsometricSouth = KidCharacterSprites();
  final kidCharacterSpritesIsometricWest = KidCharacterSprites();
  final kidCharacterSpritesIsometricDiffuse = KidCharacterSprites();

  late final kidCharacterSpritesIsometric = {
    RenderDirection.south: kidCharacterSpritesIsometricSouth,
    RenderDirection.west: kidCharacterSpritesIsometricWest,
    RenderDirection.diffuse: kidCharacterSpritesIsometricDiffuse,
  };

  final kidCharacterSpritesFrontDiffuse = KidCharacterSprites();

  final totalImages = Watch(0);
  final totalImagesLoaded = Watch(0);
  final values = <Image>[];
  final _completerImages = Completer();

  late final CharacterShader characterShaderFallen;
  late final CharacterShader characterShaderFallenArmoured;
  late final CharacterShader characterShaderSkeleton;
  late final CharacterShader characterShaderWolf;
  late final CharacterShader characterShaderZombie;

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
  late final Sprite flame0;
  late final Sprite flame1;
  late final Sprite flame2;
  late final Sprite butterfly;
  late final Sprite moth;
  late final Sprite bat;
  late final Sprite crystalSouth;
  late final Sprite crystalWest;
  late final Sprite barrelWooden;

  late final CharacterSpriteGroup spriteGroupEmpty;

  late final Sprite spriteEmpty;
  late final dstEmpty = Uint16List(0);

  late final Image empty;
  late final Image shades;
  late final Image shadesTransparent;
  late final Image pixel;
  late final Image atlas_projectiles;
  late final Image atlas_particles;
  late final Image atlas_helms;
  late final Image atlas_hands;
  late final Image atlas_body;
  late final Image atlas_legs;
  late final Image atlas_shoes;
  late final Image atlas_gameobjects;
  late final Image atlas_nodes;
  late final Image atlas_characters;
  late final Image atlas_icons;
  late final Image atlas_consumables;
  late final Image atlas_treasures;
  late final Image atlas_weapons;
  late final Image atlas_spells;
  late final Image square;
  late final Image template_spinning;

  late final Sprite emptySprite;

  late final Map<int, Image> itemTypeAtlases;

  @override
  Future onComponentInit(SharedPreferences sharedPreferences) async {
    print('isometric.images.onComponentInitialize()');

    empty = await loadPng('empty');
    loadPng('shades').then((value) => shades = value);
    loadPng('shades_transparent').then((value) => shadesTransparent = value);
    loadPng('square').then((value) => square = value);
    loadPng('atlas_nodes').then((value) => atlas_nodes = value);
    loadPng('atlas_characters').then((value) => atlas_characters = value);
    loadPng('atlas_gameobjects').then((value) => atlas_gameobjects = value);
    loadPng('atlas_particles').then((value) => atlas_particles = value);
    loadPng('atlas_projectiles').then((value) => atlas_projectiles = value);
    loadPng('atlas_weapons').then((value) => atlas_weapons = value);
    loadPng('atlas_icons').then((value) => atlas_icons = value);
    loadPng('atlas_consumables').then((value) => atlas_consumables = value);
    loadPng('atlas_treasures').then((value) => atlas_treasures = value);
    loadPng('atlas_spells').then((value) => atlas_spells = value);
    loadPng('atlas_helms').then((value) => atlas_helms = value);
    loadPng('atlas_hands').then((value) => atlas_hands = value);
    loadPng('atlas_body').then((value) => atlas_body = value);
    loadPng('atlas_legs').then((value) => atlas_legs = value);
    loadPng('atlas_shoes').then((value) => atlas_shoes = value);

    emptySprite = Sprite(
        image: empty,
        src: Float32List(0),
        dst: Float32List(0),
        rows: 0,
        columns: 0,
        mode: 0,
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
        mode: AnimationMode.single,
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
      idle: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/idle', mode: AnimationMode.bounce),
      running: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/running', mode: AnimationMode.loop),
      change: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/change', mode: AnimationMode.bounce),
      dead: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/dead', mode: AnimationMode.single),
      fire: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/fire', mode: AnimationMode.single),
      strike1: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/strike_1', mode: AnimationMode.single),
      strike2: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/strike_2', mode: AnimationMode.single),
      hurt: emptySprite,
      casting: await loadSprite(name: 'assets/sprites/isometric/kid/shadow/casting', mode: AnimationMode.single),
    );

    for (final kidCharacterSpritesIsometric in kidCharacterSpritesIsometric.values){
      kidCharacterSpritesIsometric.handLeft[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.handRight[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.weapons[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.helm[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.bodyMale[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.bodyFemale[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.legs[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.hair[0] = spriteGroupEmpty;
      kidCharacterSpritesIsometric.shoes[0] = spriteGroupEmpty;
    }

    loadSpriteGroupFront(type: SpriteGroupType.Body_Male, subType: BodyType.Shirt_Blue);
    loadSpriteGroupFront(type: SpriteGroupType.Body_Male, subType: BodyType.Leather_Armour);
    loadSpriteGroupFront(type: SpriteGroupType.Body_Female, subType: BodyType.Leather_Armour);
    loadSpriteGroupFront(type: SpriteGroupType.Hand_Left, subType: HandType.Gauntlets);
    loadSpriteGroupFront(type: SpriteGroupType.Hand_Right, subType: HandType.Gauntlets);
    loadSpriteGroupFront(type: SpriteGroupType.Head, subType: HeadType.boy);
    loadSpriteGroupFront(type: SpriteGroupType.Head, subType: HeadType.girl);
    loadSpriteGroupFront(type: SpriteGroupType.Helm, subType: HelmType.Steel);
    loadSpriteGroupFront(type: SpriteGroupType.Helm, subType: HelmType.Wizard_Hat);
    loadSpriteGroupFront(type: SpriteGroupType.Legs, subType: LegType.Leather);
    loadSpriteGroupFront(type: SpriteGroupType.Torso, subType: Gender.male);
    loadSpriteGroupFront(type: SpriteGroupType.Torso, subType: Gender.female);
    loadSpriteGroupFront(type: SpriteGroupType.Weapon, subType: WeaponType.Bow);
    loadSpriteGroupFront(type: SpriteGroupType.Weapon, subType: WeaponType.Staff);
    loadSpriteGroupFront(type: SpriteGroupType.Weapon, subType: WeaponType.Shortsword);
    loadSpriteGroupFront(type: SpriteGroupType.Shoes, subType: ShoeType.Leather_Boots);
    loadSpriteGroupFront(type: SpriteGroupType.Shoes, subType: ShoeType.Iron_Plates);


    loadSpriteGroupIsometric(
      direction: RenderDirection.diffuse,
      type: SpriteGroupType.Weapon_Trail,
      subType: WeaponType.Shortsword,
      skipHurt: true,
      skipCasting: true,
      skipChange: true,
      skipDead: true,
      skipFire: true,
      skipIdle: true,
      skipRunning: true,
      skipStrike: false,
    );

    for (final direction in const[
      RenderDirection.south,
      RenderDirection.west,
      RenderDirection.diffuse,
    ]){
      for (final bodyType in BodyType.values) {
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Body_Female,
          subType: bodyType,
        );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Body_Male,
          subType: bodyType,
        );
      }
      for (final handType in HandType.values) {
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hand_Left,
          subType: handType,
        );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hand_Right,
          subType: handType,
        );
      }
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Head,
        subType: HeadType.boy,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Head,
        subType: HeadType.girl,
      );
      for (final headType in HelmType.values) {
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Helm,
          subType: headType,
        );
      }
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Legs,
        subType: LegType.Leather,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Torso,
        subType: Gender.male,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Torso,
        subType: Gender.female,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapon,
        subType: WeaponType.Bow,
        skipStrike: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapon,
        subType: WeaponType.Staff,
        skipFire: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapon,
        subType: WeaponType.Shortsword,
        skipFire: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapon,
        subType: WeaponType.Broadsword,
        skipFire: true,
      );
      loadSpriteGroupIsometric(
        direction: direction,
        type: SpriteGroupType.Weapon,
        subType: WeaponType.Sword_Heavy_Sapphire,
        skipFire: true,
      );
      for (final shoeType in ShoeType.values){
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Shoes,
          subType: shoeType,
        );
      }
      HairType.valuesNotNone.forEach((hairType) {
        loadSpriteGroupFront(
            type: SpriteGroupType.Hair,
            subType: hairType,
        );
        loadSpriteGroupIsometric(
          direction: direction,
          type: SpriteGroupType.Hair,
          subType: hairType,
        );
      });
    }

    await _completerImages.future;

    loadSprite(
        name: 'assets/sprites/isometric/butterfly/butterfly',
        mode: AnimationMode.loop,
    ).then((value) => butterfly = value);

    loadSprite(
        name: 'assets/sprites/isometric/moth/moth',
        mode: AnimationMode.loop,
    ).then((value) => moth = value);

    loadSprite(
        name: 'assets/sprites/isometric/crystal',
        mode: AnimationMode.single,
    ).then((value) => crystal = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/rock1',
        mode: AnimationMode.single,
    ).then((value) => rock1 = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/wooden_cart',
        mode: AnimationMode.single,
    ).then((value) => woodenCart = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/broom',
        mode: AnimationMode.single,
    ).then((value) => broom = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/bed',
        mode: AnimationMode.single,
    ).then((value) => bed = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/tree1',
        mode: AnimationMode.single,
    ).then((value) => tree1 = value);

    loadSprite(
        name: 'assets/sprites/isometric/tree_03',
        mode: AnimationMode.single,
    ).then((value) => tree03 = value);

    loadSprite(
        name: 'assets/sprites/isometric/tree_04',
        mode: AnimationMode.single,
    ).then((value) => tree04 = value);

    loadSprite(
        name: 'assets/sprites/isometric/tree_05',
        mode: AnimationMode.single,
    ).then((value) => tree05 = value);

    loadSprite(
        name: 'assets/sprites/isometric/tree_06',
        mode: AnimationMode.single,
    ).then((value) => tree06 = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/firewood',
        mode: AnimationMode.single,
    ).then((value) => firewood = value);

    loadSprite(
        name: 'assets/sprites/isometric/bat/bat',
        mode: AnimationMode.bounce,
    ).then((value) => bat = value);

    loadSprite(
        name: 'assets/sprites/isometric/crystal/south',
        mode: AnimationMode.loop,
    ).then((value) => crystalSouth = value);

    loadSprite(
        name: 'assets/sprites/isometric/crystal/west',
        mode: AnimationMode.loop,
    ).then((value) => crystalWest = value);

    loadSprite(
        name: 'assets/sprites/isometric/gameobjects/barrel',
        image: atlas_nodes,
        mode: AnimationMode.single,
        atlasX: 995,
        atlasY: 0,
    ).then((value) => barrelWooden = value);

    itemTypeAtlases = {
      ItemType.Weapon: atlas_weapons,
      ItemType.Object: atlas_gameobjects,
      ItemType.Helm: atlas_helms,
      ItemType.Body: atlas_body,
      ItemType.Legs: atlas_legs,
      ItemType.Shoes: atlas_shoes,
      ItemType.Consumable: atlas_consumables,
      ItemType.Hand: atlas_hands,
      ItemType.Treasure: atlas_treasures,
      ItemType.Spell: atlas_spells,
    };

    loadCharacterShader(dirFallen).then((value) => characterShaderFallen = value);
    loadCharacterShader(dirFallenArmoured).then((value) => characterShaderFallenArmoured = value);
    loadCharacterShader(dirSkeleton).then((value) => characterShaderSkeleton = value);
    loadCharacterShader(dirWolf).then((value) => characterShaderWolf = value);
    loadCharacterShader(dirZombie).then((value) => characterShaderZombie = value);

    flame0 = await loadSprite(
        name: 'assets/sprites/isometric/flame/wind0',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1681,
        image: atlas_nodes,
    );
    flame1 = await loadSprite(
        name: 'assets/sprites/isometric/flame/wind1',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1733,
        image: atlas_nodes,
    );
    flame2 = await loadSprite(
        name: 'assets/sprites/isometric/flame/wind2',
        mode: AnimationMode.loop,
        atlasX: 664,
        atlasY: 1778,
        image: atlas_nodes,
    );
  }

  Future<CharacterSpriteGroup> loadCharacterSpriteGroup(String directory) async =>
      CharacterSpriteGroup(
        idle: await loadSprite(
            name: '$directory/idle', mode: AnimationMode.bounce,
        ),
        running: await loadSprite(
            name: '$directory/running', mode: AnimationMode.loop,
        ),
        dead: await loadSprite(
            name: '$directory/dead', mode: AnimationMode.single,
        ),
        strike1: await loadSprite(
            name: '$directory/strike', mode: AnimationMode.single,
        ),
        strike2: await loadSprite(
          name: '$directory/strike', mode: AnimationMode.single,
        ),
        hurt: await loadSprite(
            name: '$directory/hurt', mode: AnimationMode.single,
        ),
        fire: await loadSprite(
          name: '$directory/fire', mode: AnimationMode.single,
        ),
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
        idle: skipIdle ? emptySprite : await loadSprite(name: '$directory/idle', mode: AnimationMode.bounce),
        running: skipRunning ? emptySprite : await loadSprite(name: '$directory/running', mode: AnimationMode.loop),
        change: skipChange ? emptySprite : await loadSprite(name: '$directory/change', mode: AnimationMode.bounce),
        dead: skipDead ? emptySprite : await loadSprite(name: '$directory/dead', mode: AnimationMode.single),
        fire: skipFire ? emptySprite : await loadSprite(name: '$directory/fire', mode: AnimationMode.single),
        strike1: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike_1', mode: AnimationMode.single),
        strike2: skipStrike ? emptySprite : await loadSprite(name: '$directory/strike_2', mode: AnimationMode.single),
        hurt: skipHurt ? emptySprite : await loadSprite(name: '$directory/hurt', mode: AnimationMode.single),
        casting: skipCasting ? emptySprite : await loadSprite(name: '$directory/casting', mode: AnimationMode.single),
    );
  }

  void loadSpriteGroupFront({
    required int type,
    required int subType,
  }) async {
    final typeName = SpriteGroupType.getName(type).toLowerCase();
    final subTypeName = SpriteGroupType.getSubTypeName(type, subType).toLowerCase().replaceAll(' ', '_');
    final kidCharacterSpriteGroup = kidCharacterSpritesFrontDiffuse.values[type] ?? (throw Exception('images.loadSpriteGroupFront($typeName, $subTypeName)'));
    final directory = 'assets/sprites/front/kid/diffuse/$typeName/$subTypeName';

    kidCharacterSpriteGroup[subType] = CharacterSpriteGroup(
      idle: await loadSprite(name: '$directory/idle', mode: AnimationMode.bounce),
      running: emptySprite,
      change: emptySprite,
      dead: emptySprite,
      fire: emptySprite,
      strike1: emptySprite,
      strike2: emptySprite,
      hurt: emptySprite,
      casting: emptySprite,
    );
  }

  parseListDouble(List<dynamic> values) =>
      (values.cast<num>()).map((e) => e.toDouble()).toList(growable: false);

  List<double> readDoubles(dynamic values)=> parseListDouble(values as List);

  Float32List readFloat32List(dynamic values) => Float32List.fromList(readDoubles(values));

  Future<Sprite> loadSprite({
    required String name,
    required int mode,
    Image? image,
    int atlasX = 0,
    int atlasY = 0,
  }) async {

    try {
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

      return Sprite(
        image: image,
        src: src,
        dst: dst,
        rows: json.getInt('rows'),
        columns: json.getInt('columns'),
        srcWidth: json.getDouble('width'),
        srcHeight: json.getDouble('height'),
        mode: mode,
      );
    } catch(e) {
      // print(e);
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



