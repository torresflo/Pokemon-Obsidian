module Battle
  class Move
    module Mechanics
      # Move that takes two turns
      #
      # **REQUIREMENTS**
      # None
      module TwoTurn
        private

        # Internal procedure of the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        def proceed_internal(user, targets)
          @turn = (@turn || 0) + 1

          # Turn 1
          if @turn == 1
            decrease_pp(user, targets)
            play_animation_turn1(user, targets)
            proceed_message_turn1(user, targets)
            deal_effects_turn1(user, targets)
            return prepare_turn2(user, targets) unless shortcut?(user, targets)
          end

          # Turn 2
          @turn = nil
          kill_turn1_effects(user)
          super
        end

        # Check if the two turn move is executed in one turn
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @return [Boolean]
        def shortcut?(user, targets)
          @logic.each_effects(user) do |effect|
            return true if effect.on_two_turn_shortcut(user, targets, self)
          end
          return false
        end
        alias two_turns_shortcut? shortcut?

        # Add the effects to the pokemons (first turn)
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        def deal_effects_turn1(user, targets)
          stat_changes_turn1(user, targets)&.each do |(stat, value)|
            @logic.stat_change_handler.stat_change_with_process(stat, value, user)
          end
        end
        alias two_turn_deal_effects_turn1 deal_effects_turn1

        # Give the force next move and other effects
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        def prepare_turn2(user, targets)
          user.effects.add(Effects::ForceNextMoveBase.new(@logic, user, self, targets))
          user.effects.add(Effects::OutOfReachBase.new(@logic, user, can_hit_moves)) if can_hit_moves
        end
        alias two_turn_prepare_turn2 prepare_turn2

        # Remove effects from the first turn
        # @param user [PFM::PokemonBattler]
        def kill_turn1_effects(user)
          user.effects.get(&:out_of_reach?)&.kill
        end
        alias two_turn_kill_turn1_effects kill_turn1_effects

        # Display the message and the animation of the turn
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        def proceed_message_turn1(user, targets)
          nil
        end

        # Display the message and the animation of the turn
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        def play_animation_turn1(user, targets)
          nil
        end

        # Return the stat changes for the user
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @return [Array<Array<[Symbol, Integer]>>] exemple : [[:dfe, -1], [:atk, 1]]
        def stat_changes_turn1(user, targets)
          nil
        end

        # Return the list of the moves that can reach the pokemon event in out_of_reach, nil if all attack reach the user
        # @return [Array<Symbol>]
        def can_hit_moves
          nil
        end
      end
    end
  end
end
