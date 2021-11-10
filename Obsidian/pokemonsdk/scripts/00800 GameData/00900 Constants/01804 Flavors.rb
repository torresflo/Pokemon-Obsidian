module GameData
  # Flavors ID
  module Flavors
    # ID of Spicy Flavor
    SPICY = 0
    # ID of Dry Flavor
    DRY = 1
    # ID of Sweet Flavor
    SWEET = 2
    # ID of Bitter Flavor
    BITTER = 3
    # ID of Sour Flavor
    SOUR = 4

    # Array of natures which don't have a preference
    NO_PREF_NATURES = [
      GameData::Natures::BASHFUL,
      GameData::Natures::DOCILE,
      GameData::Natures::HARDY,
      GameData::Natures::QUIRKY,
      GameData::Natures::SERIOUS
    ]
    # Hash containing Arrays of natures which like flavors
    LIKED_FLAVORS = {
      spicy: [GameData::Natures::ADAMANT, GameData::Natures::BRAVE, GameData::Natures::NAUGHTY, GameData::Natures::LONELY],
      dry: [GameData::Natures::MODEST, GameData::Natures::QUIET, GameData::Natures::RASH, GameData::Natures::MILD],
      sweet: [GameData::Natures::TIMID, GameData::Natures::JOLLY, GameData::Natures::NAIVE, GameData::Natures::HASTY],
      bitter: [GameData::Natures::CALM, GameData::Natures::CAREFUL, GameData::Natures::SASSY, GameData::Natures::GENTLE],
      sour: [GameData::Natures::BOLD, GameData::Natures::IMPISH, GameData::Natures::RELAXED, GameData::Natures::LAX]
    }
    # Hash containing Arrays of natures which dislike flavors
    DISLIKED_FLAVORS = {
      spicy: [GameData::Natures::MODEST, GameData::Natures::TIMID, GameData::Natures::CALM, GameData::Natures::BOLD],
      dry: [GameData::Natures::ADAMANT, GameData::Natures::JOLLY, GameData::Natures::CAREFUL, GameData::Natures::IMPISH],
      sweet: [GameData::Natures::BRAVE, GameData::Natures::QUIET, GameData::Natures::SASSY, GameData::Natures::RELAXED],
      bitter: [GameData::Natures::NAUGHTY, GameData::Natures::RASH, GameData::Natures::NAIVE, GameData::Natures::LAX],
      sour: [GameData::Natures::LONELY, GameData::Natures::MILD, GameData::Natures::HASTY, GameData::Natures::GENTLE]
    }
    FLAVORS_SYMBOLS = {
      spicy: GameData::Flavors::SPICY,
      dry: GameData::Flavors::DRY,
      sweet: GameData::Flavors::SWEET,
      bitter: GameData::Flavors::BITTER,
      sour: GameData::Flavors::SOUR
    }
  end
end
