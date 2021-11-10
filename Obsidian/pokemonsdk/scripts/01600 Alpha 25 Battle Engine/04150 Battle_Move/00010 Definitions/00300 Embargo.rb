module Battle
  class Move
    # Embargo prevents the target using any items for five turns. This includes both held items and items used by the trainer such as medicines.
    # @see https://pokemondb.net/move/embargo
    # @see https://bulbapedia.bulbagarden.net/wiki/Embargo_(move)
    # @see https://www.pokepedia.fr/Embargo
    class Embargo < Move
      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return true if super
        return true if target.effects.has?(effect_symbol)
        return false
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(effect_symbol)

          target.effects.add(create_effect(user, target))
          scene.display_message_and_wait(proc_message(user, target))
        end
      end

      # Symbol name of the effect
      # @return [Symbol]
      def effect_symbol
        :embargo
      end

      # Duration of the effect including the current turn
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @return [Effects::EffectBase]
      def create_effect(user, target)
        Effects::Embargo.new(logic, target, 5)
      end

      def proc_message(user, target)
        return parse_text_with_pokemon(19, 727, target)
      end
    end
    Move.register(:s_embargo, Embargo)
  end
end