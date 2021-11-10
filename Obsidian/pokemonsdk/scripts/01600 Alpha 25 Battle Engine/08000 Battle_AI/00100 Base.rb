module Battle
  # Module holding the whole AI code
  module AI
    # Base class of AI, it holds the most important data
    class Base
      include Hooks
      # Get the scene that initialized the AI
      # @return [Battle::Scene]
      attr_reader :scene
      # Get the bank the AI controls
      # @return [Integer]
      attr_reader :bank
      # Get the party the AI controls
      # @return [Integer]
      attr_reader :party_id

      # List of AI by ai_level
      @ai_class_by_level = {}

      # Create a new AI instance
      # @param scene [Battle::Scene] scene that hold the logic object
      # @param bank [Integer] bank where the AI acts
      # @param party_id [Integer] ID of the party the AI look for Pokemon info
      # @param level [Integer] level of tha AI
      def initialize(scene, bank, party_id, level)
        @scene = scene
        @bank = bank
        @party_id = party_id
        @level = level
        @move_heuristic_cache = Hash.new { |hash, key| hash[key] = MoveHeuristicBase.new(key.be_method, @level) }
        init_capability
      end

      # Get the action the AI wants to do
      # @return [Array<Actions::Base>]
      def trigger
        return controlled_pokemon.flat_map do |pokemon|
          # @type [Battle::Effects::ForceNextMove]
          effect = pokemon.effects.get(&:force_next_move?)
          next effect.make_action if effect

          battle_action_for(pokemon)
        end.compact
      end

      class << self
        # Register a new AI
        # @param level [Integer] level of the AI
        # @param klass [Class<Base>]
        def register(level, klass)
          @ai_class_by_level[level] = klass
        end

        # Get a registered AI
        # @param level [Integer] level of the AI
        # @return [Class<Battle::AI::Base>]
        def registered(level)
          @ai_class_by_level[level] || Base
        end
      end

      # Get all Pokemon in the party of the AI
      # @return [Array<PFM::PokemonBattler>]
      def party
        @scene.logic.all_battlers.select { |battler| battler.bank == @bank && battler.party_id == @party_id }
      end

      # Get all the controlled Pokemon
      # @return [Array<PFM::PokemonBattler>]
      def controlled_pokemon
        0.upto(@scene.battle_info.vs_type - 1).map { |i| @scene.logic.battler(@bank, i) }.compact.select { |battler| battler.party_id == @party_id }
      end

      private

      # Try to find the battle action for a dedicated pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @return [Actions::Base, Array<Actions::Base>]
      # @note Actions are internally structured this way in the action array: [heuristic, action]
      def battle_action_for(pokemon)
        actions = usable_moves(pokemon).map { |move| move_action_for(move, pokemon) }
        move_heuristics = actions.compact.map(&:first)
        mega = mega_evolve_action_for(pokemon) if @can_mega_evolve
        actions.concat(clean_switch_trigger_actions(switch_actions_for(pokemon, move_heuristics))) if @can_switch
        actions.concat(item_actions_for(pokemon, move_heuristics)) if @can_use_item
        actions.concat([flee_action_for(pokemon)].compact) if @can_flee

        exec_hooks(Base, :battle_action_for, binding)
        final_action = actions.compact.shuffle(random: @scene.logic.generic_rng).max_by(&:first)&.last
        mega = nil if final_action.is_a?(Actions::Switch)

        return mega ? [mega, final_action] : final_action
      end

      # Function that returns a mocked version of the scene
      # @return [Battle::Scene<Battle::SceneMock>]
      def mocked_scene
        @scene.clone.extend(SceneMock)
      end

      # Function responsive of initializing all the IA capatibility flags
      def init_capability
        @can_see_effectiveness = false
        @can_see_power = false
        @can_see_move_kind = false
        @can_switch = false
        @can_use_item = false
        @can_heal = false # If set to false but can use item, AI will only choose boosting item!
        @can_choose_target = false
        @can_flee = false
        @can_read_opponent_movepool = false
        @can_mega_evolve = false
        @heal_threshold = 0.1
      end

      # Get all the move the pokemon can use
      # @param pokemon [PFM::PokemonBattler]
      # @return [Array<Battle::Move>]
      def usable_moves(pokemon)
        moves = pokemon.moveset.reject { |move| move.disable_reason(pokemon) || move.instance_of?(Battle::Move) || oblivious_reject?(pokemon, move) }
        return moves if moves.any?

        return [Battle::Move[:s_struggle].new(GameData::Skill[:struggle].id, 1, 1, @scene)]
      end

      # Function that check if the move is not usable because of oblivious
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @return [Boolean] if the move should be rejeced from the moveset
      def oblivious_reject?(pokemon, move)
        return move.status? && pokemon.effects.has?(:oblivious)
      end
    end
  end
end
