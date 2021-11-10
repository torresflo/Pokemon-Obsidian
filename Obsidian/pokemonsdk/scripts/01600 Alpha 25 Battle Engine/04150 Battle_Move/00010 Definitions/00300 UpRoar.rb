module Battle
  class Move
    # Uproar inflicts damage for 3 turns. During this time, no Pokémon on the field will be able to sleep, and any sleeping Pokémon will be woken up.
    # @see https://pokemondb.net/move/uproar
    # @see https://bulbapedia.bulbagarden.net/wiki/Uproar_(move)
    # @see https://www.pokepedia.fr/Brouhaha
    class UpRoar < BasicWithSuccessfulEffect
      # List the targets of this move
      # @param pokemon [PFM::PokemonBattler] the Pokemon using the move
      # @param logic [Battle::Logic] the battle logic allowing to find the targets
      # @return [Array<PFM::PokemonBattler>] the possible targets
      # @note use one_target? to select the target inside the possible result
      def battler_targets(pokemon, logic)
        @uproaring = pokemon.effects.has?(effect_name)
        return super
      end

      # Return the target symbol the skill can aim
      # @return [Symbol]
      def target
        return @uproaring ? :adjacent_foe : super
      end

      private

      # Event called if the move failed
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @param reason [Symbol] why the move failed: :usable_by_user, :accuracy, :immunity
      def on_move_failure(user, targets, reason)
        user.effects.get(effect_name)&.kill
        scene.display_message_and_wait(calm_down_message(user))
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.effects.has?(effect_name)

        user.effects.add(create_effect(user, actual_targets))
        logic.terrain_effects.add(Effects::UpRoar::SleepPrevention.new(logic, user))
      end

      # Method responsive testing accuracy and immunity.
      # It'll report the which pokemon evaded the move and which pokemon are immune to the move.
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Array<PFM::PokemonBattler>]
      def accuracy_immunity_test(user, targets)
        [super.sample(random: logic.generic_rng)]
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :uproar
      end

      # Create the effect
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets
      # @return [Effects::EffectBase]
      def create_effect(user, actual_targets)
        Effects::UpRoar.new(logic, user, self, actual_targets, 3)
      end

      # Message displayed when the move fails and the pokemon calm down
      # @param user [PFM::PokemonBattler] user of the move
      # @return [String]
      def calm_down_message(user)
        parse_text_with_pokemon(19, 718, user)
      end
    end
    Move.register(:s_uproar, UpRoar)
  end
end
