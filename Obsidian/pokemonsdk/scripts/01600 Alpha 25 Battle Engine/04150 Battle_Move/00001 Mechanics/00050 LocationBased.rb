module Battle
  class Move
    module Mechanics
      # Move based on the location type
      #
      # **REQUIREMENTS**
      # - define element_table
      module LocationBased
        # Function that tests if the targets blocks the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] expected target
        # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
        # @return [Boolean] if the target evade the move (and is not selected)
        def move_blocked_by_target?(user, target)
          return super || element_by_location.nil?
        end
        alias lb_move_blocked_by_target? move_blocked_by_target?

        private

        # Return the current location type
        # @return [Symbol]
        def location_type
          return logic.field_terrain_effect.db_symbol unless logic.field_terrain_effect.none?

          return $game_map.location_type($game_player.x, $game_player.y)
        end

        # Find the element using the given location using randomness.
        # @return [object, nil]
        def element_by_location
          element_table[location_type]&.sample(random: logic.generic_rng)
        end

        # Element by location type.
        # @return [Hash<Symbol, Array<Symbol>]
        def element_table
          log_error("#{__method__} should be overwritten by #{self.class}.")
          {}
        end
      end
    end
  end
end
