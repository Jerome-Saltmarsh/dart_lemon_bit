[COMMANDS]
flutter build web --web-renderer canvaskit --release
firebase deploy

[shortcut-keys]
navigate to next method: ctrl + shift + up / down arrows
ctrl + w            : minimal mode
ctrl + shift + e    : view recent changes

25.04.2023
[x] aeon mobile support

15.04.2023
[x] fix player score

08.04.2023
[x] deploy server to all countries
[x] disable play for mobile

07.04.2023
[x] fix remove sound death on join game

24.03.2023
[x] fix power icon resolution
[x] fix use power while busy
[x] track-02

23.03.2023
[x] window main menu
[x] fix cursor mouse position
[x] fix respawn window position

22.03.2023
[x] music track 02 
[x] multiple music tracks

21.03.2023
[x] music track 01
[x] feature respawn timer
[x] fix fall through floor

20.03.2023
[x] fix edit key codes
[x] fix edit camera centers player on spawn
[x] improve power shield sprite
[x] feature show perception where mouse is
[x] feature lightning particle power shock used
[x] improve render order

18.03.2023
[x] fix render order bug

17.03.2023
[x] power invisible
[x] power stun
[x] optimize collider on same team
[x] remove character state dying

15.03.2023
[x] fix bug melee attack doesn't change weapon
[x] weapon portal gun
[x] fix cutting grass regenerates randoms

14.03.2023
[x] scene warehouse

13.03.2023
[x] fix sprite weapon knife
[x] optimized handle key event
[x] fixed columns cast shadows
[x] purchasable weapons

10.03.2023
[x] polish collect credits
[x] fix items dropped by enemies disappear too quickly
[x] fixed plasma rifle sprite
[x] fix render gameobject clipping
[x] fix editor gameobjects tab
[x] fix van sprite

09.03.2023
[x] fix render pickaxe idle
[x] fix render flame thrower idle
[x] feature instant draw weapon
[x] feature auto melee nearby targets
[x] melee attack unarmed should only hit closest target
[x] fix bug when enter underground

08.03.2023
[x] fixed weapon icons
[x] coins give credits
[x] fix bombs ui

19.02.2023
[x] feature torch light flicker
[x] feature game object barrel flame flicker
[x] feature ambient light intensity

18.02.2023
[x] feature flicker light
[x] feature light intensity

17.02.2023
[x] feature editor duplicate gameobject button
[x] item type pipe vertical
[x] node type glass
[x] feature credits
[x] feature grenade instruction tooltip
[x] fix physics fall through stairs
[x] fix editor select node type column 
[x] fix render vertical half height
[x] node type scaffold

16.02.2023
[x] feature debug stack display connection information
[x] fix hue interpolation

15.02.2023
[x] gameobject neon sign 2
[x] fix delete game object
[x] client side scene decompression

13.02.2023
[x] gameobject neon sign
[x] remove previous mini map
[x] milestone feature colored lights

12.02.2023
[x] gameobject type computer
[x] feature hud total grenades
[x] fix starting items
[x] fix zombie death animation angle

11.02.2023
[x] feature melee strike weapon
[x] optimize server playerUpdateAimTarget
[x] move ease library to lemon engine
[x] feature quick throw grenade 
[x] upgrade flutter version

10.02.2023
[x] feature item type van
[x] feature item type bottle
[x] feature check player projection for perception map
[x] fix do not shine light through half and corner orientations
[x] improvement move enable shadows to settings window

09.02.2023
[x] item type car tire
[x] node type bricks red
[x] fix house wall color on first floor
[x] feature game settings ambient color
[x] feature light ease functions

08.02.2023
[x] fix physics teleport upwards
[x] gameobject washing machine
[x] gameobject chair
[x] gameobject sink
[x] node type bookshelf
[x] feature grass and trees shed half shadow
[x] fix bug gravity

27.01.2023
[x] fixed throw grenade

26.01.2023
[x] clamp velocity after apply force 
[x] fixed node visibility algorithm

21.01.2023
[x] fix particle blood direction
[x] reload with key code R
[x] currently equipped ammo hud

20.01.2023
[x] improve grid visibility algorithm
[x] feature gameobject persistable variable

19.01.2023
[x] feature gameobject car
[x] replace SizedBox empty with singleton
[x] fix gameobject inventory image 

18.01.2023
[x] feature editor pause game
[x] feature editor toggle gameobject movable enabled
[x] feature editor toggle gameobject collider enabled
[x] new gameobject fire hydrant
[x] fix physics bullet applies force in direction of travel
[x] feature water splash on collider enter water
[x] fix gameobject node collision
[x] fix half collision distance from half to third
[x] fix editor gameobject stays selected during play mode
[x] fix crystal render

17.01.2023
[x] feature hide gameobjects above player
[x] fix zombies strike from far away
[x] optimize render particle do not render offscreen particles
[x] feature flaming barrels emit smoke particle
[x] new gameobject bed
[x] new gameobject desk
[x] implement vending machine as gameobject instead of node

16.01.2023
[x] feature explosions hit gameobjects
[x] feature game script
[x] new gameobject wooden crate
[x] new gameobject toilet
[x] make respawn button more obvious
[x] disable auto connect
[x] optimize hsv to color 
[x] use ease function ease out quad to determine lighting interpolation

15.01.2023
[x] rest

14.01.2023
[x] show live demo to Jack and friends

13.01.2023
[x] fix ai inactive bug
[x] toggle map visibility key 
[x] fix dog render animation
[x] bullet impact nodes cause particles to emit
[x] feature barrel struck audio
[x] feature bullet struck audio
[x] new node type sandbags
[x] fix sprite legs brown
[x] fix sprite legs white
[x] fix sprite body empty
[x] feature explosive barrels explode when shot
[x] feature gameobjects fall into water
[x] fix flaming barrel collision physics
[x] fix flaming barrel stops emitting light when offscreen
[x] optimize client do not emit offscreen light sources

12.01.2023
[x] new gameobject flaming barrel
[x] fix physics barrel collision detection
[x] zombies and dogs emit attack wave animation
[x] read write byte 24
[x] new gameobject explosive barrel
[x] disable teleport on production
[x] improve animation sword strike
[x] fix sprite swat pants
[x] animate shot fired
[x] punch strike animation

11.01.2023
[x] new node type cupboards
[x] new weapon type crowbar
[x] feature unequip current weapon if selected
[x] short cut key unequip weapon
[x] fix weapon bow sprite
[x] ui item info display replenish energy amount
[x] fixed editor node orientation none sprite
[x] optimize load images

10.01.2023
[x] fix render bullet glitch
[x] fix template head sprite
[x] fix ai running into water and walls
[x] fix bug server spawn jobs
[x] respawn cut grass
[x] fix render grenade
[x] fix grenade physics

09.01.2023
[x] rain effected by wind
[x] save scene recover destroyed nodes such as cut grass
[x] fix node type boulder
[x] melee attack sounds
[x] melee attack slash effect
[x] fix engine render sprite rotated

08.01.2023
[BREAK]

07.01.2023
[x] purple explosion emits light
[x] fix attack unarmed audio
[?] fix physics characters teleport through walls on struck

06.01.2023
[x] fix render transparent node during day
[x] ui player stats add energy bar
[x] fix prevent item type empty stats displayed
[x] fix item stats hover dialog appearing behind belt ui
[x] replace health and damage text with icons

05.01.2023
[x] knife attack sounds
[x] melee items deplete energy
[x] fix repeat error message
[x] game debug ui modify ambient color
[x] compress scenes using gzip
[x] item type sprite axe 
[x] item type sprite hammer 
[x] item type sprite staff 

04.01.2023
[x] fix melee attack animations
[x] reduce light during rain
[x] fix stats damage incorrect
[x] feature light source hue and intensity

03.01.2023
[x] remove grenade and apple from inventory on empty
[x] pine tree bottom shadow
[x] fix editor select node sprites
[x] fix render tree top

02.01.2023
[x] interactable node type vending machine
[x] projectiles can hit barrels
[x] vending trade machine
[x] fix detect vendors which aren't the top
[x] minimap icon vendor
[x] killing enemies drop items

01.01.2023
[x] survival mode enemies drop random ammunition on killed
[x] survival mode random cloths on spawn

31.12.2022
[x] fix render row index out of bounds exception
[x] fix mini map trees

30.12.2022
[x] remove ambient shade
[x] fix fire minigun
[x] model weapon blunderbuss
[x] fix survival time not visible
[x] fix cursor speak on enemy players
[x] fix survival inventory not reset on respawn
[x] mini map indicate enemies
[x] optimize lemon bytes using bit operations

29.12.2022
[x] feature generate mini-map
[x] fix rocket sprite
[x] fix sniper rifle aiming render
[x] fix grenade explosion forces in wrong direction
[x] fix render grenade
[x] survival mode time passes
[x] decouple environment and time

28.12.2022
[x] standardized node type wooden plank  
[x] refactor render game
[x] optimize render nodes
[x] fix melee strike no damage

27.12.2022
[x] node type pine tree
[x] fix run mouse target
[x] node orientation windows
[x] fix gameobject shading
[x] fix grass node solid variation two
[x] fix editor player health stats incorrect
[x] remove node type plain
[x] fix transparent not shaded by hue

26.12.2022
[x] fix modify grid size z

22.12.2022
[x] upload scene with bytes instead of base64 encoded string

18.12.2022
[x] fix lightning
[x] optimize update lighting

17.12.2022
[x] fix torches not illuminating
[x] fix torch emission

16.12.2022
[x] fixed rain heavy
[x] fix lightning not activating
[x] practice mode lightning
[x] lightning shade
[x] practice mode environment
[x] render torch shaded
[x] upgrade server dart docker image

15.12.2022
[x] fix render stone half
[x] fix node transparency for shaded nodes

14.12.2022
[x] node type stone orientations
[x] ai fire weapons
[x] practice mode enemy player cursor incorrect
[x] fix players always visible
[x] Running backwards causes legs to disappear
[x] fig bug volume greater than one error
[x] fix bullets do not collide with enemy

13.12.2022
[x] fix render node error when running on right corner of map
[x] fix template perform animation

12.12.2022
[x] particle myst

11.12.2022
[x] fix mouse cursor hides tree tops
[x] transparent nodes
[x] dog shadow

10.12.2022
[x] character dog

09.12.2022
[x] fix bug consuming apple consumes all
[x] fix bug purchasing weapon only 1 ammo
[x] compile and read scene dynamically

08.12.2022
[x] compile gameobjects to scene file
[x] fix editor upload and download
[x] save saves as byte array instead of json

07.12.2022
[x] editor generate random map
[x] item type sprite green pants
[x] inventory open and closable

06.12.2022
[x] fix editor map size

05.12.2022
[x] fix player spawn points
[x] fix zombie wander
[x] fix bug picking up weapon loses quantity
[x] random item types
[x] node visible on mouse

04.12.2022
[x] atlas item type swat pants 
[x] fix sword slash animation
[x] fix sword aim animation
[x] editor fixed navigation icons
[x] editor fixed weather controls layout
[x] editor canvas size window

03.12.2022
[x] max item quantity 
[x] stack item type resources 
[x] ai mode pause
[x] ai mode chase
[x] ai mode circle
[x] ai mode wander
[x] ai mode evade

02.12.2022
[x] fix player stats window

01.12.2022
[x] weapon bolt action rifle

30.11.2022
[x] weapon revolver
[x] weapon m4
[x] weapon heavy machine gun

29.11.2022
[x] weapon oozie
[x] weapon bazooka
[x] weapon flame thrower
[x] weapon knife
[x] weapon ak47
[x] weapon sniper rifle

28.11.2022
[x] model sniper rifle
[x] model flint lock pistol
[x] model standard issue police handgun
[x] handgun desert eagle
[x] change weapons while walking
[x] reload while walking
[x] grenade throw distance
[x] reload text
[x] weapon grenade

27.11.2022
[x] weapon accuracy
[x] mouse aim
[x] fixed cursor alignment

25.11.2022
[x] weapon capacity
[x] weapon reload

18.11.2022
[x] fix window trade
[x] fixed mobile layout bug
[x] fix mobile attack button position
[x] fix do not save collectable game items to scene
[x] fix on zombie killed bug
[x] move thunder flash state from client to server
[x] refactor client applyBakeMapEmissions

17.11.2022
[x] remove enum Rain
[x] remove enum Wind
[x] fix reconnecting to scene cursor is not visible
[x] fixed common library directory structure
[x] refactor lightning enum
[x] display scene name on enter

16.11.2022
[x] scene edit tool respawn ai
[x] scene edit tool clear ai
[x] fix rain bug
[x] edit save button
[x] mute sounds
[x] auto check for latest version
[x] connection lost error message
[x] inventory layout equipped items vertically
[x] fix active belt drag target
[x] fix fire handgun animation
[x] show server error message

15.11.2022
[x] fix drop equipped item by dragging
[x] make hotkeys draggable
[x] hotkeys to change weapons

11.11.2022
[x] ui inventory icon
[x] optimize spawn nodes
[x] fix editor icons
[x] fix character state changing

10.11.2022
[x] gameobject items timeout
[x] player experience
[x] consume food to heal
[x] item sell
[x] item buy
[x] prevent item-type information panel from going off screen
[x] player gold

09.11.2022
[x] dropped gameobject quantity
[x] render item quantities in inventory dialog
[x] item quantities
[x] gun-powder
[x] respawn dead enemies
[x] merge game-object-types into item-type

08.11.2022
[x] fix fire shotgun
[x] trade hover information container
[x] fix player renders behind stairs
[x] trade drag to sell
[x] trade drag to buy

07.11.2022
[x] fix character state spawning
[x] talk to npc
[x] trade with npc
[x] right click to drop item
[x] fix rain
[x] dark-age cursor interact with npc
[x] dark-age loot-drop

02.11.2022
[x] editor adding tree auto adds tree top
[x] attack button has weapon icon
[x] fix equip sword

01.11.2022
[x] fix torch goes out during lightning strike at night
[x] zoom icon
[x] fix player body does not turn with mouse when idle
[x] zoom key shortcut
[x] optimize render node
[x] fix render arrow
[x] fix weapon render order
[x] button toggle zoom in and out
[x] shift left click - stand attack
[x] fix touch screen - attack button while running

31.10.2022
[x] on click enemy - attack
[x] Touchscreen auto aim
[x] mobile disable movement tutorial
[x] fix on change scene center cursor on player
[x] fix on death center cursor on player
[x] fix on touch on change scene center cursor on player
[x] fix mobile cursor starts on player

30.10.2022
[x] render run target circle

29.10.2022
[x] space bar to attack
[x] left shift + left click to attack (same as diablo 2)
[x] mobile attack controls
[x] left click to run to mouse
[x] right click to attack
[x] mobile movement controls

28.10.2022
[x] add editor time control in menu 
[x] fix auto fullscreen error message
[x] android app icon
[x] fix staff orb kills zombie bug
[x] fix zombie shadow

27.10.2022
[x] aim cursor
[x] loading screen
[x] fix particle blood color
[x] mobile device auto connect on first visit
[x] auto detect region
[x] fix editor-ui orientations do not fit for bauhaus
[x] fix wood half north
[x] fix bauhaus corners
[x] fix bauhaus halves
[x] fix brick corners
[x] fix brick halves
[x] fixed editor change time
[x] fixed editor weather icons
[x] fixed editor menu icons



