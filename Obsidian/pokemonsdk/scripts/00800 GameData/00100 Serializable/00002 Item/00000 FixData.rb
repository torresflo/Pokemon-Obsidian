module GameData
  class Item
    class << self
      # Fix the data from .24 to .25
      def fix_data
        old_data = load_data(old_data_filename)
        new_data = old_data.map(&:to_new_format)
        save_data(new_data, data_filename)
      end

      alias original_load load
      # Load the items
      def load
        fix_data unless File.exist?(data_filename) || PSDK_CONFIG.release?
        original_load
      end
    end

    # Create a new Item
    # @param id [Integer] ID of the item
    # @param db_symbol [Symbol] db_symbol of the item
    # @param icon [String] Icon of the item
    # @param price [Integer] price of the item
    # @param socket [Integer] socket of the item
    # @param position [Integer] order of the item in the socket
    # @param battle_usable [Boolean] if the item is usable in battle
    # @param map_usable [Boolean] if the item is usable in map
    # @param limited [Boolean] if the item is consumable
    # @param holdable [Boolean] if the item can be held by a Pokemon
    # @param fling_power [Integer] power of the item in fling move
    def initialize(id, db_symbol, icon, price, socket, position, battle_usable, map_usable, limited, holdable, fling_power)
      @id = id.to_i
      @db_symbol = db_symbol.is_a?(Symbol) ? db_symbol : :__undef__
      @icon = icon.to_s
      @price = price.to_i.clamp(0, Float::INFINITY)
      @socket = socket.to_i
      @position = position.to_i
      @battle_usable = battle_usable
      @map_usable = map_usable
      @limited = limited
      @holdable = holdable
      @fling_power = fling_power
    end

    # Get the parameters of the item
    # @return [Array]
    def initialize_params
      [@id, @db_symbol, @icon, @price, @socket, @position, @battle_usable, @map_usable, @limited, @holdable, @fling_power]
    end

    # Convert an item to the new format
    # @return [GameData::Item]
    def to_new_format
      return GameData::Item.new(*initialize_params) unless @heal_data || @ball_data || @misc_data # Regular item no need to convert
      return convert_to_ball_item if @ball_data
      return convert_to_heal_item if @heal_data

      return convert_to_other_kind_item
    end

    private

    # Convert this item to a ball item
    # @return [GameData::BallItem]
    def convert_to_ball_item
      # @type [GameData::BallData]
      data = @ball_data
      return BallItem.new(*initialize_params, data.img, data.catch_rate, data.color || Color.new(255, 0, 0))
    end

    # Convert this item to an other kind of item
    # @return [GameData::EventItem, GameData::FleeingItem, GameData::RepelItem, GameData::StoneItem, GameData::TechItem, GameData::Item]
    def convert_to_other_kind_item
      # @type [GameData::ItemMisc]
      data = @misc_data
      return EventItem.new(*initialize_params, data.event_id) if data.event_id && data.event_id > 0
      return FleeingItem.new(*initialize_params) if data.flee
      return RepelItem.new(*initialize_params, data.repel_count) if data.repel_count && data.repel_count > 0
      return StoneItem.new(*initialize_params) if data.stone
      return TechItem.new(*initialize_params, data.skill_learn, data.cs_id ? true : false) if data.skill_learn

      return GameData::Item.new(*initialize_params)
    end

    # Convert this item to a HealingItem
    # @return [GameData::HealingItem]
    def convert_to_heal_item
      # @type [GameData::ItemHeal]
      data = @heal_data
      loyalty = -data.loyalty.to_i
      if data.hp && data.hp > 0
        return StatusConstantHealItem.new(*initialize_params, loyalty, data.hp, data.states) if data.states

        return ConstantHealItem.new(*initialize_params, loyalty, data.hp)
      elsif data.hp_rate && data.hp_rate > 0
        return StatusRateHealItem.new(*initialize_params, loyalty, data.hp_rate / 100.0, data.states) if data.states

        return RateHealItem.new(*initialize_params, loyalty, data.hp_rate / 100.0)
      end
      return StatusHealItem.new(*initialize_params, loyalty, data.states) if data.states
      return convert_to_battle_boost_item(loyalty, data.battle_boost) if data.battle_boost
      return convert_to_ev_boost_item(loyalty, data.boost_stat) if data.boost_stat
      return AllPPHealItem.new(*initialize_params, loyalty, data.all_pp) if data.all_pp
      return PPHealItem.new(*initialize_params, loyalty, data.pp) if data.pp
      return PPIncreaseItem.new(*initialize_params, loyalty, data.add_pp == 2) if data.add_pp
      return LevelIncreaseItem.new(*initialize_params, loyalty, data.level) if data.level

      return HealingItem.new(*initialize_params, loyalty)
    end

    # Convert this item to a StatBoostItem
    # @param loyalty [Integer] loyalty_malus
    # @param boost [Integer] kind of boost
    # @return [StatBoostItem]
    def convert_to_battle_boost_item(loyalty, boost)
      return StatBoostItem.new(*initialize_params, loyalty, boost % 7, boost / 7 + 1)
    end

    # Convert this item to a EVBoostItem
    # @param loyalty [Integer] loyalty_malus
    # @param boost [Integer] kind of boost
    # @return [EVBoostItem]
    def convert_to_ev_boost_item(loyalty, boost)
      return EVBoostItem.new(*initialize_params, loyalty, boost % 10, boost >= 10 ? 10 : 1)
    end
  end
end
