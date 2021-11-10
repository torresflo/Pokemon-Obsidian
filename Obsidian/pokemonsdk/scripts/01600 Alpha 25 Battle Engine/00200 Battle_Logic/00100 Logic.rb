module Battle
  # Logic part of Pokemon Battle
  #
  # This class helps to access to the battle information & to process some part of the battle
  class Logic
    # @return [Array<Array>] list of messages to send to an interpreter (AI/Scene)
    attr_reader :messages
    # @return [Array<Actions::Base>] list of the current actions to proccess during the scene
    attr_reader :actions
    # 0 : Victory, 1 : Flee, 2 : Defeat, -1 : undef
    # @return [Integer]
    attr_accessor :battle_result
    # @return [Array<Array<PFM::Bag>>] bags of each banks
    attr_reader :bags
    # @return [Battle::Logic::BattleInfo]
    attr_reader :battle_info
    # Get the evolve requests
    # @return [Array<PFM::PokemonBattler>]
    attr_reader :evolve_request
    # Get the Mega Evolve helper
    # @return [MegaEvolve]
    attr_reader :mega_evolve
    # Get the switch requests
    # @return [Array<Hash>]
    attr_reader :switch_request
    # Get the scene used to instanciate this Logic instance
    # @return [Battle::Scene]
    attr_reader :scene
    # Get the move damage rng
    # @return [Random]
    attr_reader :move_damage_rng
    # Get the move critical rng
    # @return [Random]
    attr_reader :move_critical_rng
    # Get the move accuracy rng
    # @return [Random]
    attr_reader :move_accuracy_rng
    # Get the generic rng
    # @return [Random]
    attr_reader :generic_rng

    # Create a new Logic instance
    # @param scene [Scene] scene that hold the logic object
    def initialize(scene)
      @scene = scene
      @battle_info = scene.battle_info
      Message.setup(self)
      @messages = []
      # @type [Array<Actions::Base>]
      @actions = []
      @bags = @battle_info.bags
      # @type [Array<Array<PFM::PokemonBattler>>]
      @battlers = []
      init_effects
      # Mega Evolve helper
      @mega_evolve = MegaEvolve.new(scene)
      # TODO: Remove global_states bank_states
      @global_states = {}
      @bank_states = Hash.new({})
      @battle_result = -1
      @switch_request = []
      @evolve_request = []
      $game_temp.battle_turn = 0
    end

    # Safe to_s & inspect
    def to_s
      format('#<%<class>s:%<id>08X>', class: self.class, id: __id__)
    end
    alias inspect to_s

    # Return the number of bank in the current battle
    # @return [Integer]
    def bank_count
      return @battlers.size
    end

    # Tell if the battle can continue
    # @return [Boolean]
    def can_battle_continue?
      return false if @battle_result >= 0

      banks_that_can_fight = @battlers.map.with_index { |battlers, bank| battlers.any?(&:alive?) ? bank : nil }.compact
      # It's a victory if the player still have a Pokemon on its bank
      if banks_that_can_fight.size <= 1
        @battle_result = banks_that_can_fight.include?(0) ? 0 : 2
        return false
      end
      return true
    end

    # Load the RNG for the battle logic
    # @param seeds [Hash] seeds for the RNG
    def load_rng(seeds = Hash.new(Random.new_seed))
      @move_damage_rng = Random.new(seeds[:move_damage_rng])
      @move_critical_rng = Random.new(seeds[:move_critical_rng])
      @move_accuracy_rng = Random.new(seeds[:move_accuracy_rng])
      @generic_rng = Random.new(seeds[:generic_rng])
    end

    # Get the current RNG Seeds
    # @return [Hash{ Symbol => Integer }]
    def rng_seeds
      {
        move_damage_rng: @move_damage_rng.seed,
        move_critical_rng: @move_critical_rng.seed,
        move_accuracy_rng: @move_accuracy_rng.seed,
        generic_rng: @generic_rng.seed
      }
    end
  end
end
