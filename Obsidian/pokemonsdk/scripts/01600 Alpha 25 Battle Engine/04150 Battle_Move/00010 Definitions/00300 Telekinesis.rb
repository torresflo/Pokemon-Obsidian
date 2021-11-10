module Battle
  class Move
    # Telekinesis raises the target into the air for three turns, guaranteeing that all attacks against 
    # the target (except OHKO moves) will hit, regardless of Accuracy or Evasion.
    # @see https://pokemondb.net/move/telekinesis
    # @see https://bulbapedia.bulbagarden.net/wiki/Telekinesis_(move)
    # @see https://www.pokepedia.fr/L%C3%A9vikin%C3%A9sie
    # @see [Effects::Telekinesis]
    class Telekinesis < Move
      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return true if super
        return true if target.effects.has?(effect_name)
        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(effect_name)

          target.effects.add(create_effect(user, target))
        end
      end

      private

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :telekinesis
      end

      # Create the effect applied to the target
      # @return [Effects::EffectBase]
      def create_effect(user, target)
        Effects::Telekinesis.new(logic, target, 4)
      end
    end
    Move.register(:s_telekinesis, Telekinesis)
  end
end