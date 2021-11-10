module GameData
  # Kind of item that allows the Pokemon to learn a move
  class TechItem < Item
    # HM/TM text
    HM_TM_TEXT = '%s %s'
    # Get the ID of the move it teach
    # @return [Integer]
    attr_reader :move_learnt
    # Get if the item is a Hidden Move or not
    # @return [Boolean]
    attr_reader :is_hm
    # Create a new TechItem
    # @param initialize_params [Array] params to create the Item object
    # @param move_learnt [Integer] ID of the move it teach
    # @param is_hm [Boolean] if the item is an Hidden Move
    def initialize(*initialize_params, move_learnt, is_hm)
      super(*initialize_params)
      @move_learnt = move_learnt.to_i.clamp(1, Float::INFINITY)
      @is_hm = is_hm
    end

    # Get the db_symbol of the move it teaches
    # @return [Symbol]
    def move_db_symbol
      GameData::Skill.db_symbol(@move_learnt)
    end

    # Get the exact name of the item
    # @return [String]
    def exact_name
      return format(HM_TM_TEXT, name, Skill[move_learnt].name)
    end
  end
end

safe_code('Register TechItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::TechItem) do
    next $game_temp.in_battle
  end

  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::TechItem) do |item, pokemon|
    next false if pokemon.egg?

    next pokemon.can_learn?(GameData::TechItem.from(item).move_learnt)
  end
end
