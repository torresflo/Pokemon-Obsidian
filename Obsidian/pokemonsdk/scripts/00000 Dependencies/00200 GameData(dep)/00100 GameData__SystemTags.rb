# Module that defines every data class, data reader module or constants
module GameData
  # Module that contain the ids of every SystemTag
  # @author Nuri Yuri
  module SystemTags
    module_function

    # Generation of the SystemTag id
    # @param x [Integer] X coordinate of the SystemTag on the w_prio tileset
    # @param y [Integer] Y coordinate of the SystemTag on the w_prio tileset
    def gen(x, y)
      return 384 + x + (y * 8)
    end
    # SystemTag that is used to remove the effet of SystemTags like TSea or TPond.
    Empty = gen 0, 0
    # Ice SystemTag, every instance of Game_Character slide on it.
    TIce = gen 1, 0
    # Grass SystemTag, used to display grass particles and start Wild Pokemon Battle.
    TGrass = gen 5, 0
    # Taller grass SystemTag, same purpose as TGrass.
    TTallGrass = gen 6, 0
    # Cave SystemTag, used to start Cave Wild Pokemon Battle.
    TCave = gen 7, 0
    # Mount SystemTag, used to start Mount Wild Pokemon Battle.
    TMount = gen 5, 1
    # Sand SystemTag, used to start Sand Pokemon Battle.
    TSand = gen 6, 1
    # Wet sand SystemTag, used to display a particle when walking on it, same purpose as TSand.
    TWetSand = gen 2, 0
    # Pond SystemTag, used to start Pond/River Wild Pokemon Battle.
    TPond = gen 7, 1
    # Sea SystemTag, used to start Sea/Ocean Wild Pokemon Battle.
    TSea = gen 5, 2
    # Under water SystemTag, used to start Under water Wild Pokemon Battle.
    TUnderWater = gen 6, 2
    # Snow SystemTag, used to start Snow Wild Pokemon Battle.
    TSnow = gen 7, 2
    # SystemTag that is used by the pathfinding system as a road.
    Road = gen 7, 5
    # Defines a Ledge SystemTag where you can jump to the right.
    JumpR = gen 0, 1
    # Defines a Ledge SystemTag where you can jump to the left.
    JumpL = gen 0, 2
    # Defines a Ledge SystemTag where you can jump down.
    JumpD = gen 0, 3
    # Defines a Ledge SystemTag where you can jump up.
    JumpU = gen 0, 4
    # Defines a WaterFall (aid for events).
    WaterFall = gen 3, 0
    # Define a HeadButt tile
    HeadButt = gen 4, 0
    # Defines a tile that force the player to move left.
    RapidsL = gen 1, 1
    # Defines a tile that force the player to move down.
    RapidsD = gen 2, 1
    # Defines a tile that force the player to move up.
    RapidsU = gen 3, 1
    # Defines a tile that force the player to move Right.
    RapidsR = gen 4, 1
    # Defines a Swamp tile.
    SwampBorder = gen 5, 4
    # Defines a Swamp tile that is deep (player can be stuck).
    DeepSwamp = gen 6, 4
    # Defines a upper left stair.
    StairsL = gen 1, 4
    # Defines a up stair when player moves up.
    StairsD = gen 2, 4
    # Defines a up stair when player moves down.
    StairsU = gen 3, 4
    # Defines a upper right stair.
    StairsR = gen 4, 4
    # Defines the left slope
    SlopesL = gen 7, 3
    # Defines the right slope
    SlopesR = gen 7, 4
    # Defines a Ledge "passed through" by bunny hop (Acro bike).
    AcroBike = gen 6, 3
    # Defines a bike bridge that only allow right and left movement (and up down jump with acro bike).
    AcroBikeRL = gen 4, 3
    # Same as AcroBikeRL but up and down with right and left jump.
    AcroBikeUD = gen 3, 3
    # Defines a tile that require high speed to pass through (otherwise you fall down).
    MachBike = gen 5, 3
    # Defines a tile that require high speed to not fall in a Hole.
    CrackedSoil = gen 1, 3
    # Defines a Hole tile.
    Hole = gen 2, 3
    # Defines a bridge (crossed up down).
    BridgeUD = gen 2, 2
    # Defines a bridge (crossed right/left).
    BridgeRL = gen 4, 2
    # Define tiles that change the z property of a Game_Character.
    ZTag = [gen(0, 5), gen(1, 5), gen(2, 5), gen(3, 5), gen(4, 5), gen(5, 5), gen(6, 5)]
  end
end
