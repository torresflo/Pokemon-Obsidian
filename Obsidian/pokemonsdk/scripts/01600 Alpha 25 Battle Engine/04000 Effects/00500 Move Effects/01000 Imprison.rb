module Battle
  module Effects
    class Imprison < PokemonTiedEffectBase
      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :imprison
      end

      # Check if the effect prevent the move
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_global(user, targets, move)
        return unless @logic.foes_of(@pokemon).include?(user) && @pokemon.moveset.any? { |pkm_move| move.id == pkm_move.id }

        move.logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 589, user))
        return :prevent
      end
    end
  end
end
