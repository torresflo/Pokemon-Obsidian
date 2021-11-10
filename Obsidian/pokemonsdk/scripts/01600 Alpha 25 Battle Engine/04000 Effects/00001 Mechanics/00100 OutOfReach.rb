module Battle
  module Effects
    module Mechanics
      # Make the pokemon out of reach
      #
      # **Requirement**
      # - Call initialize_out_of_reach
      module OutOfReach
        # Init the mechanic
        # @param pokemon [PFM::PokemonBattler]
        # @param exceptions [Array<Symbol>] move that hit the target while out of reach
        def initialize_out_of_reach(pokemon, exceptions)
          @oor_pokemon = pokemon
          @oor_exceptions = exceptions
        end

        # Tell if the effect make the pokemon out reach
        # @return [Boolean]
        def out_of_reach?
          return true
        end
        alias oor_out_of_reach? out_of_reach?

        # Check if the attack can hit the pokemon. Should be called after testing out_of_reach?
        # @param name [Symbol]
        # @return [Boolean]
        def can_hit_while_out_of_reach?(name)
          return @oor_exceptions.include?(name)
        end
        alias oor_can_hit_while_out_of_reach? can_hit_while_out_of_reach?

        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false if target != @oor_pokemon

          result = !can_hit_while_out_of_reach?(move.db_symbol)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 213, target)) if result
          return result
        end
        alias oor_on_move_prevention_target on_move_prevention_target
      end
    end
  end
end
