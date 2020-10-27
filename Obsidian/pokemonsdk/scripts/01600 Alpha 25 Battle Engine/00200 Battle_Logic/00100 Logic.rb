module Battle
  # Logic part of Pokemon Battle
  #
  # This class helps to access to the battle information & to process some part of the battle
  class Logic
    # @return [Array<Array>] list of messages to send to an interpreter (AI/Scene)
    attr_reader :messages
    # @return [Array<Hash>] list of the current actions to proccess during the scene
    attr_reader :actions
    # @return [Integer] 0 : Victory, 1 : Defeat, 2 : Flee, -1 : undef
    attr_reader :battle_result
    # @return [Array<PFM::Bag>] bags of each banks
    attr_reader :bags
    # @return [Battle::Logic::BattleInfo]
    attr_reader :battle_info
    # Create a new Logic instance
    # @param battle_scene [Scene] scene that hold the logic object
    def initialize(battle_scene)
      @battle_scene = battle_scene
      @battle_info = battle_scene.battle_info
      Message.setup(self)
      @messages = []
      # @type [Array<Hash>]
      @actions = []
      @bags = []
      @battlers = []
      @global_states = {}
      @bank_states = Hash.new({})
      @battle_result = -1
    end

    # Return the number of bank in the current battle
    # @return [Integer]
    def bank_count
      return @battlers.size
    end

    # Tell if the battle can continue
    # @return [Boolean]
    def can_battle_continue?
      return false if @battle_result >= 0
      banks_that_can_fight = []
      @battlers.each_with_index do |battler_bank, bank|
        battler_bank.each do |battler|
          break(banks_that_can_fight << bank) if battler&.can_fight?
        end
      end
      # It's a victory if the player still have a Pokemon on its bank
      if banks_that_can_fight.size <= 1
        @battle_result = banks_that_can_fight.include?(0) ? 0 : 1
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
    end

    # Get the current RNG Seeds
    # @return [Hash{ Symbol => Integer }]
    def rng_seeds
      {
        move_damage_rng: @move_damage_rng.seed,
        move_critical_rng: @move_critical_rng.seed,
        move_accuracy_rng: @move_accuracy_rng.seed
      }
    end
  end
end
