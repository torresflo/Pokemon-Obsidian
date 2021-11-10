module Battle
  class Logic
    # Class describing the informations about the battle
    class BattleInfo
      # List of item decupling money
      MONEY_ITEMS = %i[amulet_coin luck_incense]
      # List of base money giving AI levels (if strictly below the value)
      AI_LEVELS_BASE_MONEY = [16, 20, 36, 48, 80, 100, 200, Float::INFINITY]
      # @return [Array<Array<String>>] List of the name of the battlers according to the bank & their position
      attr_accessor :names
      # @return [Array<Array<String>>] List of the classes of the battlers according to the bank & their position
      attr_accessor :classes
      # @return [Array<Array<String>>] List of the battler (image) name of the battlers according to the bank
      attr_accessor :battlers
      # @return [Array<Array<PFM::Bag>>] List of the bags of the battlers according to the bank
      attr_accessor :bags
      # @return [Array<Array<Array<PFM::Pokemon>>>] List of the "Party" of the battlers according to the bank & their position
      attr_accessor :parties
      # @return [Array<Array<Integer>>]
      attr_accessor :ai_levels
      # @return [Array<Array<Integer>>] List of the base money of the battlers according to the bank
      attr_accessor :base_moneys
      # @return [Integer, nil] Maximum level allowed for the battle
      attr_accessor :max_level
      # @return [Integer] Number of Pokemon fighting at the same time
      attr_accessor :vs_type
      # @return [Integer] Reason of the wild battle
      attr_accessor :wild_battle_reason
      # @return [Boolean] if the trainer battle is a "couple" battle
      attr_accessor :trainer_is_couple
      # @return [Integer] ID of the battle (for event loading)
      attr_accessor :battle_id
      # Get the number of time the player tried to flee
      # @return [Integer]
      attr_accessor :flee_attempt_count
      # Tell if the battle follows a fishing attempt
      # @return [Boolean]
      attr_accessor :fishing
      # Get the caught Pokemon
      # @return [PFM::PokemonBattler]
      attr_accessor :caught_pokemon
      # Get the victory BGM
      # @return [String]
      attr_accessor :victory_bgm
      # Get the battle bgm
      # @return [String]
      attr_accessor :battle_bgm
      # Get the additionnal money
      # @return [Integer]
      attr_accessor :additional_money

      # Create a new Battle Info
      # @param hash [Hash] basic info about the battle
      def initialize(hash = {})
        @names = hash[:names] || [[], []]
        @classes = hash[:classes] || [[], []]
        @battlers = hash[:battlers] || [[], []]
        @bags = hash[:bags] || [[], []]
        @parties = hash[:parties] || [[], []]
        @ai_levels = hash[:ai_levels] || [[], []]
        @base_moneys = hash[:base_moneys] || [[], []]
        @max_level = hash[:max_level] || nil
        @vs_type = hash[:vs_type] || 1
        @trainer_is_couple = hash[:couple] || false
        @battle_id = hash[:battle_id] || -1
        @flee_attempt_count = 0
        @fishing = hash[:fishing] || false
        @victory_bgm = hash[:victory_bgm] || guess_victory_bgm
        @battle_bgm = hash[:battle_bgm] || guess_battle_bgm
        @additional_money = 0
      end

      # Tell if the battle allow exp
      # @return [Boolean]
      def disallow_exp?
        return @max_level || $game_switches[Yuki::Sw::BT_NoExp]
      end

      class << self
        # Configure a PSDK battle from old settings
        # @param id_trainer1 [Integer]
        # @param id_trainer2 [Integer]
        # @param id_friend [Integer]
        # @return [Battle::Logic::BattleInfo]
        def from_old_psdk_settings(id_trainer1, id_trainer2 = 0, id_friend = 0)
          battle_info = BattleInfo.new
          # Add Player party
          battle_info.add_party(0, *battle_info.player_basic_info)
          # Add 1st enemy
          add_trainer(battle_info, 1, id_trainer1)
          # Add 2nd enemy
          add_trainer(battle_info, 1, id_trainer2) if id_trainer2 != 0
          # Add friend
          add_trainer(battle_info, 0, id_friend) if id_friend != 0
          battle_info.vs_type = 2 if battle_info.trainer_is_couple || battle_info.parties[1]&.size == 2
          return battle_info
        end

        # Add a trainer to the battle_info object
        # @param battle_info [BattleInfo]
        # @param bank [Integer] bank of the trainer
        # @param id_trainer [Integer] ID of the trainer in the database
        def add_trainer(battle_info, bank, id_trainer)
          trainer = GameData::Trainer[id_trainer]
          klass = GameData::Trainer.class_name(id_trainer)
          battler = trainer.battler
          name = trainer.internal_names[battle_info.parties[1]&.size || 0]
          party = trainer.team.map { |hash| PFM::Pokemon.generate_from_hash(hash) }
          battle_info.add_party(bank, party, name, klass, battler, nil, nil, ai_level(trainer.base_money || 0))
          battle_info.base_moneys[bank] << trainer.base_money if bank == 1
          battle_info.trainer_is_couple = battle_info.parties[1].size == 1 if bank == 1 && trainer.vs_type == 2
          battle_info.battle_id = trainer.special_group if trainer.special_group != 0
        end

        # Guess the AI level based on the base money (or a variable)
        # @param base_money [Integer]
        # @return [Integer]
        def ai_level(base_money)
          return $game_variables[Yuki::Var::AI_LEVEL] if $game_variables[Yuki::Var::AI_LEVEL] > 0

          return AI_LEVELS_BASE_MONEY.find_index { |base_money_limit| base_money < base_money_limit } || 1
        end
      end

      # Tell if the battle is a trainer battle
      # @return [Boolean]
      def trainer_battle?
        !@names[1].empty?
      end

      # Return the basic info about the player
      # @return [Array]
      def player_basic_info
        battler_name = $game_actors[1].battler_name
        battler_name = $game_player.charset_base if !battler_name || battler_name.empty?
        return $actors, $trainer.name, GameData::Trainer.class_name(0), battler_name, $bag
      end

      # Add a party to a bank
      # @param bank [Integer] bank where the party should be defined
      # @param party [Array<PFM::Pokemon>] Pokemon of the battler
      # @param name [String, nil] name of the battler (don't set it if Wild Battle)
      # @param klass [String, nil] name of the battler (don't set it if Wild Battle)
      # @param battler [String, nil] name of the battler image (don't set it if Wild Battle)
      # @param bag [String, nil] bag used by the party
      # @param base_money [Integer]
      # @param ai_level [Integer]
      def add_party(bank, party, name = nil, klass = nil, battler = nil, bag = nil, base_money = nil, ai_level = nil)
        @parties[bank] ||= []
        @parties[bank] << party
        @names[bank] ||= []
        @names[bank] << name if name
        @classes[bank] ||= []
        @classes[bank] << klass if klass
        @battlers[bank] ||= []
        @battlers[bank] << battler if battler
        @bags[bank] ||= []
        @bags[bank] << (bag || PFM::Bag.new)
        @base_moneys[bank] ||= []
        @base_moneys[bank] << base_money if base_money
        @ai_levels[bank] ||= []
        @ai_levels[bank] << ai_level
      end

      # Get the trainer name of a battler
      # @param battler [PFM::PokemonBattler]
      # @return [String]
      def trainer_name(battler)
        return @names[battler.bank][party_index(battler)]
      end

      # Get the trainer class of a battler
      # @param battler [PFM::PokemonBattler]
      # @return [String]
      def trainer_class(battler)
        return @classes[battler.bank][party_index(battler)]
      end

      # Get the bag of a battler
      # @param battler [PFM::PokemonBattler]
      # @return [PFM::Bag]
      def bag(battler)
        return @bags[battler.bank][party_index(battler)]
      end

      # Get the party of a battler
      # @param battler [PFM::PokemonBattler]
      # @return [Array<PFM::Pokemon>]
      def party(battler)
        return @parties[battler.bank][party_index(battler)] if battler.bank

        @parties.find { |parties| parties.any? { |party| party.include?(battler.original) } }&.find { |party| party.include?(battler.original) }
      end

      # Get the base money of a battler
      # @param battler [PFM::PokemonBattler]
      # @return [Integer]
      def base_money(battler)
        return @base_moneys.dig(battler.bank, party_index(battler)) || 1
      end

      # Get the total money
      # @param logic [Battle::Logic]
      def total_money(logic)
        # @type [Array<PFM::PokemonBattler>]
        pokemon = $game_temp.vs_type.times.map { |i| logic.battler(1, i) }.compact
        money = additional_money + pokemon.reduce(0) { |acc, curr| curr.level * base_money(curr) + acc }
        money *= 2 if logic.terrain_effects.has?(:happy_hour)
        money *= 2 if $game_temp.vs_type.times.any? { |i| MONEY_ITEMS.include?(logic.battler(0, i)&.item_db_symbol) }
        return money
      end

      private

      # Function that guess the battle bgm
      # @return [Array, String]
      def guess_battle_bgm
        audio_file = $game_system.battle_bgm || $game_system.playing_bgm
        return 'audio/bgm/rosa_wild_battle' if audio_file.name.empty?

        return ["audio/bgm/#{audio_file.name}", audio_file.volume, audio_file.pitch]
      end

      # Function that guess the victory bgm
      # @return [Array, String]
      def guess_victory_bgm
        audio_file = $game_system.battle_end_me
        filename = "audio/bgm/#{audio_file.name}"
        return 'audio/bgm/xy_trainer_battle_victory' unless File.exist?(filename)

        return [filename, audio_file.volume, audio_file.pitch]
      end

      # Find the party index of a battler
      # @param battler [PFM::PokemonBattler]
      # @return [Integer]
      def party_index(battler)
        return @parties[battler.bank].index(battler.original) || 0
      end
    end
  end
end
