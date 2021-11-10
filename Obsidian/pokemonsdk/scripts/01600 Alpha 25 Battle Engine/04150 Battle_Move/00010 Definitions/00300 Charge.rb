module Battle
  class Move
    # Charge raises the user's Special Defense by one stage, and if this Pokémon's next move is a damage-dealing Electric-type attack, it will deal double damage.
    # @see https://pokemondb.net/move/charge
    # @see https://bulbapedia.bulbagarden.net/wiki/Charge_(move)
    # @see https://www.pokepedia.fr/Chargeur
    class Charge < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(effect_name)

          target.effects.add(create_effect(user, target))
          scene.display_message_and_wait(effect_message(user, target))
        end
      end

      # Symbol name of the effect
      # @return [Symbol]
      def effect_name
        :charge
      end

      # Create the effect
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @return [Effects::EffectBase]
      def create_effect(user, target)
        Effects::Charge.new(@logic, target, 2)
      end

      # Message displayed when the effect is created
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @return [String]
      def effect_message(user, target)
        parse_text_with_pokemon(19, 664, target)
      end
    end
    Move.register(:s_charge, Charge)
  end
end