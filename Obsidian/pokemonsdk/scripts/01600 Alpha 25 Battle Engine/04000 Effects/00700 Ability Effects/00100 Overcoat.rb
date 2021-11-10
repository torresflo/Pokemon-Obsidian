module Battle
  module Effects
    class Ability
      # A Pokémon with Overcoat does not take damage from the weather conditions sandstorm and hailstorm.
      # Also protects from powder and spore moves, as well as Effect Spore.
      # @see https://pokemondb.net/ability/overcoat
      # @see https://bulbapedia.bulbagarden.net/wiki/Overcoat_(Ability)
      # @see https://www.pokepedia.fr/Envelocape
      class Overcoat < Ability
        # Weather is managed in Sandstorm and Hail.

        # Function called when we try to check if the effect changes the definitive priority of the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Boolean] if the target is immune to the move
        def on_move_ability_immunity(user, target, move)
          return false if target != @target

          @logic.scene.visual.show_ability(target) if move.powder?
          return move.powder?
        end
      end
      register(:overcoat, Overcoat)
    end
  end
end