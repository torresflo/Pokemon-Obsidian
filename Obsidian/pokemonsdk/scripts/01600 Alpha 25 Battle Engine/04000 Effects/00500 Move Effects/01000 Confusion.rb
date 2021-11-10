module Battle
  module Effects
    # Effect describing confusion
    class Confusion < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param turn_count [Integer] number of turn for the confusion (not including current turn)
      def initialize(logic, pokemon, turn_count = logic.generic_rng.rand(4..6))
        super(logic, pokemon)
        self.counter = turn_count + 1
      end

      # Return the amount of damage the Pokemon receive from confusion
      # @return [Integer]
      def confuse_damage
        return ((@pokemon.level * 2 / 5 + 2) * 40 * @pokemon.atk / @pokemon.dfe / 50).floor
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if dead? || user != @pokemon

        if @counter == 1 # Last turn
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 351, user))
          kill
        else
          move.scene.visual.show_rmxp_animation(user, 475)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 348, user))
          if bchance?(damage_chance)
            move.scene.visual.show_hp_animations([user], [-confuse_damage])
            move.scene.display_message_and_wait(parse_text(18, 83))
            return :prevent
          end
        end
      end

      # Get the damage chance (between 0 & 1) of the confusion
      # @return [Float]
      def damage_chance
        0.5 # 50% in Gen6 and 33% in Gen7
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        :confusion
      end
    end
  end
end
