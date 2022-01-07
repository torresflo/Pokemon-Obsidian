module GameData
  # Items that repels Pokemon for a certain amount of steps
  class RepelItem < Item
    # Get the number of steps this item repels
    # @return [Integer]
    attr_reader :repel_count

    # Create a new TechItem
    # @param initialize_params [Array] params to create the Item object
    # @param repel_count [Integer] number of steps this item repels
    def initialize(*initialize_params, repel_count)
      super(*initialize_params)
      @repel_count = repel_count.to_i.clamp(1, Float::INFINITY)
    end
  end
end

safe_code('Register RepelItem ItemDescriptor') do
  PFM::ItemDescriptor.define_bag_use(GameData::RepelItem, true) do |item, scene|
    if PFM.game_state.get_repel_count <= 0
      $game_temp.last_repel_used_id = item.id
      next PFM.game_state.set_repel_count(GameData::RepelItem.from(item).repel_count)
    end

    scene.display_message_and_wait(parse_text(22, 47))
    next :unused
  end
end
