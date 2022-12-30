[COMMANDS]
flutter build web --web-renderer canvaskit --release
firebase deploy

[shortcut-keys]
navigate to next method: ctrl + shift + up / down arrows
ctrl + w:   minimal mode

[IDEAS]
[ ] repeat killing same enemies yields no reward
[ ] loud noises draw attention
[ ] talk with other players
[ ] trade with other players
[ ] weapon torch flame

[OPTIMIZATIONS]
[ ] optimize front end - do not use objects to store projectiles
[ ] optimize front end - do not use objects to store characters
[ ] optimize front end - do not use objects to store gameobjects
[ ] optimize front end - do not use objects to store particles
[ ] optimize client applyShadowAt

[TODO]
[ ] cache region
[ ] fix android app title gamestream_flutter
[ ] option fullscreen dialog on game start if it fails to do so automatically
[ ] add mobile share (whatsapp, facebook) button

[GAMEPLAY]
[ ] highlight cursor gameobject item
[ ] feature separate head-type and helm-type

[EDITOR]
[ ] editor spawn-node character type
[ ] editor tool elevation
[ ] scene edit tool pause ai
[ ] scene edit tool pause time
[ ] editor tab gameobjects
[ ] editor tab characters

[FEATURES]
[ ] feature light source hue
[ ] feature inventory tabs
[ ] feature inventory max weight
[ ] feature attributes
[ ] feature skills
[ ] feature loot gameobjects

[CONTENT]
[ ] item type army clothes
[ ] weapon type crossbow
[ ] gameobject type car
[ ] fix particle shade

[GAMES]
[ ] game dark-age
[ ] game royal
[ ] game waves
[ ] game moba

[RELEASE 31ST JANUARY]
[ ] game practice design scene
[ ] game survival design scene
[ ] game 5v5

[CRITICAL]
[ ] design suburbia house kitchen
[ ] design suburbia cemetery
[ ] design suburbia school
[ ] fix ai spots player through walls
[ ] fix characters teleport through walls on struck
[ ] model weapon blunderbuss
[ ] fix color near midnight
[ ] feature survival random treasure spawns

30.12.2022
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



