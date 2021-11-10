#encoding: utf-8

module Yuki
  # Module that contain every constants associated to a Variable ID of $game_variables.
  # The description of the constants are the meaning of the variable
  module Var
    # Player ID (31bits)
    Player_ID = 1
    # Number of Pokemon Seen
    Pokedex_Seen = 2
    # Number of Pokemon caught
    Pokedex_Catch = 3
    # Current Box (0 is Box 1)
    Boxes_Current = 4
    # Number the in the GamePlay::InputNumber interface (default variable)
    EnteredNumber = 5
    # Number of Pokemon to select for creating temporary team
    Max_Pokemon_Select = 6
    # ID (in the database) of the trainer battle to start
    Trainer_Battle_ID = 8
    # ID of the particle data to use in order to show particle
    PAR_DatID = 9
    # InGame hour
    TJN_Hour = 10
    # InGame minute
    TJN_Min = 11
    # InGame seconds (unused)
    TJN_Sec = 12
    # InGame day of the week (1 = Monday)
    TJN_WDay = 13
    # InGame week
    TJN_Week = 14
    # InGame Month
    TJN_Month = 15
    # InGame day of the month
    TJN_MDay = 16
    # Current Tone (0 : Night, 1 : Sunset, 3 : Day, 2 : Morning)
    TJN_Tone = 17
    # Number of Following Human
    FM_N_Human = 18
    # Number of Following Pokemon (actors one)
    FM_N_Pokem = 19
    # Number of Friend's Following Pokemon
    FM_N_Friend = 20
    # The selected Follower (1 = first, 0 = none)
    FM_Sel_Foll = 21

    # ID of the map where Dig send the player out
    E_Dig_ID = 23
    # X position where Dig send the player out
    E_Dig_X = 24
    # Y position where Dig send the player out
    E_Dig_Y = 25
    # Temporary variable 1
    TMP1 = 26
    # Temporary variable 2
    TMP2 = 27
    # Temporary variable 3
    TMP3 = 28
    # Temporary variable 4
    TMP4 = 29
    # Temporary variable 5
    TMP5 = 30
    # Trainer transition type (0 = 6G, 1 = 5G)
    TrainerTransitionType = 31
    # Map Transition type (1 = Circular, 2 = Directed)
    MapTransitionID = 32

    # Level of the AI
    AI_LEVEL = 34
    # ID (in the database) of the second trainer of the duo battle
    Second_Trainer_ID = 35
    # ID (in the database) of the allied trainer of the duo battle
    Allied_Trainer_ID = 36

    # Coin case amount of coin
    CoinCase = 41

    # Index of the Pokemon that use its skill in the Party_Menu
    Party_Menu_Sel = 43
    # ID of the map where the player return (Teleport, defeat)
    E_Return_ID = 47
    # X position of the map where the player return
    E_Return_X = 48
    # Y position of the map where the player return
    E_Return_Y = 49
    # Battle mode, 0 : Normal, 1 : P2P server, 2 : P2P Client
    BT_Mode = 50
  end
end
