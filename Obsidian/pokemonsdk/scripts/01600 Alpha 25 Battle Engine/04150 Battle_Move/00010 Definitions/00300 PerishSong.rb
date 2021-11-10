module Battle
  class Move
    # Any Pokemon in play when this attack is used faints in 3 turns.
    # @see https://pokemondb.net/move/perish-song
    # @see https://bulbapedia.bulbagarden.net/wiki/Perish_Song_(move)
    # @see https://www.pokepedia.fr/Requiem
    class PerishSong < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each { |target| target.effects.add(create_effect(user, target)) }
        @scene.display_message_and_wait(message_after_animation(user, actual_targets))
      end

      # Return the effect of the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target that will be affected by the effect
      # @return [Effects::EffectBase]
      def create_effect(user, target)
        Effects::PerishSong.new(logic, target, 4)
      end

      # Return the parsed message to display once the animation is played
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [String]
      def message_after_animation(user, actual_targets)
        parse_text(18,125)
      end
    end
    Move.register(:s_perish_song, PerishSong)
  end
end
