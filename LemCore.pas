{$include lem_directives.inc}

unit LemCore;

interface

const
  MINIMUM_SI = 4;
  MAXIMUM_SI = 102;

(*
  { TODO : find good settings }
    we cannot get a nice minimapscale 1/16 so instead we chose the following:

    image width of game                 = 1584
    imagewidth of minimap               = 104
    width of white rectangle in minimap = 25





//  GAME_BMPWIDTH = 1664; // this is too far I think, but now it fits with the minimap!

  { the original dos lemmings show pixels 0 through 1583 (so including pixel 1583)
    so the imagewidth should be 1584, which means 80 pixels less then 1664


  MiniMapBounds: TRect = (
    Left: 208;   // width =about 100
    Top: 18;
    Right: 311;  // height =about 20
    Bottom: 37
  );
  *)





  clMask32  = $00FF00FF; // color used for "shape-only" masks

{•}

type
  TBasicLemmingAction = (
    baNone,
    baWalking,
    baAscending,
    baDigging,
    baClimbing,
    baDrowning,
    baHoisting,
    baBuilding,
    baBashing,
    baMining,
    baFalling,
    baFloating,
    baSplatting,
    baExiting,
    baVaporizing,
    baBlocking,
    baShrugging,
    baOhnoing,
    baExploding,
    baToWalking,
    baPlatforming,
    baStacking,
    baStoning,
    baStoneFinish,
    baSwimming,
    baGliding,
    baFixing,
    baCloning,
    baFencing,
    baReaching,
    baShimmying,
    baJumping,
    baDehoisting,
    baSliding,
    baLasering,
    baSleeping
  );

const
  MAX_SKILL_TYPES_PER_LEVEL = 10;

type
  TSkillPanelButton = (


    spbWalker,
    spbJumper,
    spbShimmier,
    spbSlider,
    spbClimber,
    spbSwimmer,
    spbFloater,
    spbGlider,
    spbDisarmer,
    spbBomber,
    spbStoner,
    spbBlocker,
    spbPlatformer,
    spbBuilder,
    spbStacker,
    spbLaserer,
    spbBasher,
    spbFencer,
    spbMiner,
    spbDigger,
    spbCloner,

    spbNone,
    spbSlower,
    spbFaster,
    spbPause,
    spbNuke,

    spbFastForward,
    spbRestart,
    spbBackOneFrame,
    spbDirLeft,
    spbPhysicsView,

    // These three are the bottom part of a vertical split
    spbForwardOneFrame,
    spbDirRight,
    spbLoadReplay
  );

const
  LAST_SKILL_BUTTON = spbCloner;

  SKILL_NAMES: array[Low(TSkillPanelButton)..LAST_SKILL_BUTTON] of String = (
    'walker',
    'jumper',
    'shimmier',
    'slider',
    'climber',
    'swimmer',
    'floater',
    'glider',
    'disarmer',
    'bomber',
    'stoner',
    'blocker',
    'platformer',
    'builder',
    'stacker',
    'laserer',
    'basher',
    'fencer',
    'miner',
    'digger',
    'cloner');

  SKILL_PLURAL_NAMES: array[Low(TSkillPanelButton)..LAST_SKILL_BUTTON] of String = (
    'walkers',
    'jumpers',
    'shimmiers',
    'sliders',
    'climbers',
    'swimmers',
    'floaters',
    'gliders',
    'disarmers',
    'bombers',
    'stoners',
    'blockers',
    'platformers',
    'builders',
    'stackers',
    'laserers',
    'bashers',
    'fencers',
    'miners',
    'diggers',
    'cloners');

const
  AssignableSkills = [
    baDigging,
    baClimbing,
    baBuilding,
    baBashing,
    baMining,
    baFloating,
    baBlocking,
    baExploding,
    baToWalking,
    baPlatforming,
    baStacking,
    baStoning,
    baSwimming,
    baGliding,
    baFixing,
    baCloning,
    baFencing,
    baShimmying,
    baJumping,
    baSliding,
    baLasering
  ];

const
  ActionToSkillPanelButton: array[TBasicLemmingAction] of TSkillPanelButton = (
    spbNone,
    spbWalker,
    spbNone,
    spbDigger,
    spbClimber,
    spbNone,
    spbNone,
    spbBuilder,
    spbBasher,
    spbMiner,
    spbNone,
    spbFloater,
    spbNone,
    spbNone,
    spbNone,
    spbBlocker,
    spbNone,
    spbNone,
    spbBomber,
    spbWalker,
    spbPlatformer,
    spbStacker,
    spbStoner,
    spbNone,
    spbSwimmer,
    spbGlider,
    spbDisarmer,
    spbCloner,
    spbFencer,
    spbNone,
    spbShimmier,
    spbJumper,
    spbNone,
    spbSlider,
    spbLaserer,
    spbNone
  );

const
  SkillPanelButtonToAction: array[TSkillPanelButton] of TBasicLemmingAction = (

    baToWalking,
    baJumping,
    baShimmying,
    baSliding,
    baClimbing,
    baSwimming,
    baFloating,
    baGliding,
    baFixing,
    baExploding,
    baStoning,
    baBlocking,
    baPlatforming,
    baBuilding,
    baStacking,
    baLasering,
    baBashing,
    baFencing,
    baMining,
    baDigging,
    baCloning,
    baNone, //Null
    baNone, //RR-
    baNone, //RR+
    baNone, //Pause
    baNone,  //Nuke
    baNone,  // FF
    baNone,  // Restart
    baNone,  // -1f
    baNone,  // +1f
    baNone,  // Physics View
    baNone,  // Dir Sel Left
    baNone,  // Load Replay
    baNone   // Dir Sel Right
  );

type
  // This isn't the list that must match LemGadgetsConstants - see below for that
  TTriggerTypes = (
    trExit,
    trForceLeft,
    trForceRight,
    trTrap,
    trAnim,
    trWater,
    trFire,
    trOWLeft,
    trOWRight,
    trOWDown,
    trOWUp,
    trSteel,
    trBlocker,
    trTeleport,
    trPickup,
    trButton,
    trUpdraft,
    trFlipper,
    trNoSplat,
    trSplat,
    trPortal,
    trAddSkill,
    trRemoveSkills,
    trNeutralizer,
    trDeneutralizer,
    trZombie
  );

const
  // This must match the list of objects in LemGadgetsConstants

  // All objects that don't have trigger areas got mapped to trZombie
  // This only works as long as there are no object types that create Zombie fields!!!
  ObjectTypeToTrigger: array[-1..33] of TTriggerTypes = (
    trZombie,        // -1 DOM_NOOBJECT
    trZombie,        //  0 DOM_NONE
    trZombie,        //  1 DOM_WINDOW
    trExit,          //  2 DOM_EXIT
    trExit,          //  3 DOM_LOCKEXIT
    trButton,        //  4 DOM_BUTTON
    trZombie,        //  5 DOM_BLOCKER
    trForceLeft,     //  6 DOM_FORCELEFT
    trForceRight,    //  7 DOM_FORCERIGHT
    trTrap,          //  8 DOM_TRAP
    trTrap,          //  9 DOM_TRAPONCE
    trWater,         // 10 DOM_WATER
    trFire,          // 11 DOM_FIRE
    trOWLeft,        // 12 DOM_ONEWAYLEFT
    trOWRight,       // 13 DOM_ONEWAYRIGHT
    trOWUp,          // 14 DOM_ONEWAYUP
    trOWDown,        // 15 DOM_ONEWAYDOWN
    trTeleport,      // 16 DOM_TELEPORT
    trZombie,        // 17 DOM_RECEIVER
    trPickup,        // 18 DOM_PICKUP
    trUpdraft,       // 19 DOM_UPDRAFT
    trFlipper,       // 20 DOM_FLIPPER
    trNoSplat,       // 21 DOM_NOSPLAT
    trSplat,         // 22 DOM_SPLAT
    trNeutralizer,   // 23 DOM_NEUTRALIZER
    trDeneutralizer, // 24 DOM_DENEUTRALIZER
    trAddSkill,      // 25 DOM_ADDSKILL
    trRemoveSkills,  // 26 DOM_REMOVESKILLS
    trPortal,        // 27 DOM_PORTAL

    trZombie,        // 28 DOM_BACKGROUND
    trZombie,        // 29 DOM_PAINT
    trAnim,          // 30 DOM_ANIMATION
    trAnim,          // 31 DOM_ANIMONCE

    trSteel,         // 32 DOM_STEEL
    trZombie         // 33 DOM_LEMMING
  );

type
  TRecordDisplay = (rdNone, rdUser, rdWorld);

  function ReleaseRateToSpawnInterval(aRR: Integer): Integer;
  function SpawnIntervalToReleaseRate(aSI: Integer): Integer;

implementation

function ReleaseRateToSpawnInterval(aRR: Integer): Integer;
begin
  Result := 103 - aRR;
end;

function SpawnIntervalToReleaseRate(aSI: Integer): Integer;
begin
  Result := 103 - aSI;
end;

end.

