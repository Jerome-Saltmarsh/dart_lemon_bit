const commandSpawn = 1;
const commandUpdate = 2;
const commandAttack = 3;
const commandSpawnZombie = 4;
const commandEquip = 5;

const characterStateIdle = 0;
const characterStateWalking = 1;
const characterStateDead = 2;
const characterStateAiming = 3;
const characterStateFiring = 4;

const directionUp = 0;
const directionUpRight = 1;
const directionRight = 2;
const directionDownRight = 3;
const directionDown = 4;
const directionDownLeft = 5;
const directionLeft = 6;
const directionUpLeft = 7;

const weaponUnarmed = 0;
const weaponHandgun = 1;
const weaponShotgun = 2;

const typeNpc = 1;
const typeHuman = 0;

const keyFrame = 'f';
const keyPositionX = 'x';
const keyPositionY = 'y';
const keyDirection = 'd';
const keyState = 's';
const keyCommand = 'c';
const keyId = 'i';
const keyRotation = 'r';
const keyCharacters = 'characters';
const keyBullets = 'bullets';
const keyFrameOfDeath = 'z';
const keyPlayerName = 'n';
const keyLastUpdateFrame = 'lf';
const keyAimAngle = 'a';
const keyStartX = 'sx';
const keyStartY = 'sy';
const keyRange = 'ra';
const keyHealth = 'h';
const keyAccuracy = 'ka';
const keyEquipValue = 'equip';
const keyWeapon = 'w';
// private
const keyType = 't';
const keyNpcTargetId = 'nt';
const keyVelocityX = 'vX';
const keyVelocityY = 'vY';
const keyDestinationX = 'dX';
const keyDestinationY = 'dY';
const keyPreviousState = 'ps';
const keyStateDuration = 'sd';
const keyShotCoolDown = 'sc';

const double bulletRadius = 3;
const double characterRadius = 7;
const double characterRadius2 = characterRadius * 2;
const double characterBulletRadius = characterRadius + bulletRadius;
const double bulletRange = 220;