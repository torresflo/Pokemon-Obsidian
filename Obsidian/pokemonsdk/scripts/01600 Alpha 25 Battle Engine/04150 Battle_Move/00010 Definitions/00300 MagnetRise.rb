module Battle
  class Move
    # User becomes immune to Ground-type moves for 5 turns.
    # @see https://pokemondb.net/move/magnet-rise
    # @see https://bulbapedia.bulbagarden.net/wiki/Magnet_Rise_(move)
    # @see https://www.pokepedia.fr/Vol_Magn%C3%A9tik
    class MagnetRise < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if targets.all? { |target| target.effects.has?(effect_name)}
        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(effect_name)

          target.effects.add(create_effect(user, target))
          @logic.scene.display_message_and_wait(on_create_message(user, target))
        end
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :magnet_rise
      end

      # Create the effect
      # @return [Battle::Effects::EffectBase]
      def create_effect(user, target)
        return Effects::MagnetRise.new(logic, target, 5)
      end

      # Message displayed when the effect is added to the target
      # @return [String]
      def on_create_message(user, target)
        parse_text_with_pokemon(19, 658, target)
      end
    end
    Move.register(:s_magnet_rise, MagnetRise)
  end
end