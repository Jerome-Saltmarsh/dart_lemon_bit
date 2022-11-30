[shortcut-keys]
navigate to next method: ctrl + shift + up / down arrows

[ideas]
[ ] talk with other players
[ ] trade with other players
[ ] stash
[ ] player-charge-attack
[ ] select skin color
[ ] separate head-type and helm-type
[ ] render foreground zombie walking while connecting
[ ] item weight
[ ] inventory max weight

[engine]
[ ] save scene as byte stream
[ ] cache region
[ ] fix android app title gamestream_flutter
[ ] add mobile share (whatsapp, facebook) button
[ ] optimize front end - do not use objects to store projectiles
[ ] optimize front end - do not use objects to store characters
[ ] optimize front end - do not use objects to store gameobjects
[ ] optimize front end - do not use objects to store particles
[ ] optimize client applyShadowAt
[ ] option fullscreen dialog on game start if it fails to do so automatically
[ ] editor - gameobjects
[ ] fix editor add remove columns
[ ] highlight cursor gameobject item
[ ] engine improve grid invisibility
[ ] player attributes ui
[ ] repeat killing same enemies yields no reward
[ ] scene edit tool pause ai
[ ] editor tool elevation
[ ] generate mini-map
[ ] particle myst
[ ] character butterfly
[ ] character bird
[ ] character chicken
[ ] Loud Noises Draw Attention
[ ] skill critical shot
[ ] attribute gunslinger 
[ ] attribute vampire steals health
[ ] scene cave
[ ] scene forest
[ ] scene wilderness
[ ] scene swamp
[ ] scene city
[ ] skill freeze
[ ] speed boost
[ ] model character alien
[ ] model character skeleton
[ ] model character ranger
[ ] model character goblin
[ ] model character vampire
[ ] model character wolf
[ ] model weapon bolt action rifle
[ ] model weapon handgun silenced

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

[COMMANDS]
flutter build web --web-renderer canvaskit --release
firebase deploy


#Story
Earth is invaded by an alien race.

The alien's spread a virus which turns the dead into zombies which the aliens control.



#DESIGN
HUNTER
Players spawn around different parts of the game world. 

The objective is to kill all the creeps in the world

Once all the creeps have been killed the level increases and a new wave of creeps respawns

Creeps appear on the mini map

The aim of the game is to kill as many creeps as possible

killing creeps rewards the player with loot and experience

Team Hunt
Solo Hunt

