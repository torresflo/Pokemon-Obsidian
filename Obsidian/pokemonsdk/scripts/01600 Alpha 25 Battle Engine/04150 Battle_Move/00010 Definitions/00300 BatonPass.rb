module Battle
  class Move
    # Baton Pass causes the user to switch out for another Pokémon, passing any stat changes to the Pokémon that switches in.
    # @see https://pokemondb.net/move/baton-pass
    # @see https://bulbapedia.bulbagarden.net/wiki/Baton_Pass_(move)
    # @see https://www.pokepedia.fr/Relais
    class BatonPass < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false unless logic.battle_info.party(user).count(&:alive?) > 1 + logic.allies_of(user).length
        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Battle::Effects::BatonPass.new(logic, target))
          logic.request_switch(target, nil)
        end
      end
    end
    Move.register(:s_baton_pass, BatonPass)
  end
end