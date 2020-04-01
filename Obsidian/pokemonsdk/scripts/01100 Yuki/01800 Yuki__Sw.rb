#encoding: utf-8

module Yuki
  # Module that contain every constants associated to a Swicth ID of $game_switches.
  # The description of the constants are the meaning of the switch
  module Sw
    # If the player is a female
    Gender = 1
    # If the shadow are shown under the Sprite_Character
    CharaShadow = 2
    # If the Game_Event doesn't collide with other Game_Event when they slide
    ThroughEvent = 3
    # If the surf message doesn't display when the player collide with the water tiles
    NoSurfContact = 4
    # If the common event did its work as expected or not
    EV_Acted = 5
    # If the Maplinker is disabled
    MapLinkerDisabled = 6
    # If InGame time use the SystemTime
    TJN_RealTime = 7
    # If the InGame time doesn't update
    TJN_NoTime = 8
    # If the added Pokemon has been stored
    SYS_Stored = 9
    # If the time tone is shown
    TJN_Enabled = 10
    # It's the day time
    TJN_DayTime = 11
    # It's the night time
    TJN_NightTime = 12
    # It's the moring time
    TJN_MorningTime = 13
    # It's sunset time
    TJN_SunsetTime = 14
    # BW transition when going from outside to inside (No fade on the warp)
    WRP_Transition = 15
    # If the nuzlocke is enabled
    Nuzlocke_ENA = 16
    # If the player is on AccroBike (and not on the normal bike)
    EV_AccroBike = 17
    # Disable the reset_position of Yuki::FollowMe
    FM_NoReset = 18
    # If the Yuki::FollowMe system is enabled
    FM_Enabled = 19
    # If the player can use Fly thus is outside
    Env_CanFly = 20
    # If the player can use Dig thus is in a cave
    Env_CanDig = 21
    # If the Follower are repositionned like the player warp between two exterior map
    Env_FM_REP = 22
    # If the player is on the Bicycle
    EV_Bicycle = 23
    # If the player has a Pokemon with Strength and Strength is active
    EV_Strength = 24
    # If the message system calculate the line break automatically
    MSG_Recalibrate = 25
    # If the choice are shown on top left
    MSG_ChoiceOnTop = 26
    # If the message system break lines on some punctuations
    MSG_Ponctuation = 27
    # If the actor doesn't turn to the event that show the message
    MSG_Noturn = 28
    # If the Pokemon FollowMe should use Let's Go Mode
    FollowMe_LetsGoMode = 29
    # If the battle is updating the phase (inside battle event condition)
    BT_PhaseUpdate = 30
    # If the phase 1 of the battle is running (Intro)
    BT_Phase1 = 31
    # If the phase 2 of the battle is running (Action choice)
    BT_Phase2 = 32
    # If the phase 3 of the battle is running (Target choice)
    BT_Phase3 = 33
    # If the phase 4 of the battle is running (Action display)
    BT_Phase4 = 34
    # If the phase 5 of the battle is running (Defeat/Victory/Catch)
    BT_Phase5 = 35
    # If the player was defeated
    BT_Defeat = 36
    # If the player was victorious
    BT_Victory = 37
    # If the player caught the Wild Pokemon
    BT_Catch = 38
    # If the weather in Battle change the Weather outside
    MixWeather = 39
    # If the experience calculation is harder
    BT_HardExp = 40
    # If the player cant escape the battle
    BT_NoEscape = 41
    # If the battle doesn't give exp
    BT_NoExp = 42
    # If the catch is forbidden
    BT_NoCatch = 43
    
    # If the player is running
    EV_Run = 52
    # If the player can run
    EV_CanRun = 53
    # If the player automatically turn on himself when walking on Rapid SystemTag
    EV_TurnRapids = 54 #Indique si le joueur tourne dans les rapides
    # If the player triggered flash
    EV_Flash = 55
    # Weather is rain
    WT_Rain = 56
    # Weather is sunset
    WT_Sunset = 57
    # Weather is sandstorm
    WT_Sandstorm = 58
    # Weather is snow
    WT_Snow = 59
    # Weather is fog
    WT_Fog = 60
    # Disable player detection by all the detection methods
    Env_Detection = 75

    # Failure switch (do not use)
    Alola = 96
    # Victory on the Alpha Ruins game
    RuinsVictory = 97
    # If the Yuki::FollowMe system was enabled
    FM_WasEnabled = 98
    # If the Pokedex is in National Mode
    Pokedex_Nat = 99
    # If the player got the Pokedex
    Pokedex = 100
  end
end
