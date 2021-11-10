module Battle
  class Move
    # Class that manage the splash move
    # @see https://bulbapedia.bulbagarden.net/wiki/Splash_(move)
    # @see https://pokemondb.net/move/splash
    # @see https://www.pokepedia.fr/Trempette
    class Splash < Move
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        @scene.display_message_and_wait(parse_text(18, 106))
      end
    end

    # Class that manage moves like Celebrate & Hold Hands
    class DoNothing < Move
      alias deal_effect void_true
    end
    Move.register(:s_splash, Splash)
    Move.register(:s_do_nothing, DoNothing)
  end
end
