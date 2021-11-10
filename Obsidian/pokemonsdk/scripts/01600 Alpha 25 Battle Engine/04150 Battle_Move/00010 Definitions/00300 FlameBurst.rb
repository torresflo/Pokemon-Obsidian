module Battle
  class Move
    # Flame Burst deals damage and will also cause splash damage to any Pokémon adjacent to the target.
    # @see https://pokemondb.net/move/flame-burst
    # @see https://bulbapedia.bulbagarden.net/wiki/Flame_Burst_(move)
    # @see https://www.pokepedia.fr/Rebondifeu
    class FlameBurst < Basic
      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        super
        splash_targets = []
        splash_damages = []
        actual_targets.each do |target|
          targets = logic.adjacent_allies_of(target)
          targets.each do |sub_target|
            damage = calc_splash_damage(user, target)
            logic.damage_handler.damage_change(damage, sub_target)
            splash_targets << sub_target
            splash_damages << -damage
          end
        end
        scene.visual.show_hp_animations(splash_targets, splash_damages)
      end

      # Calculate the damage dealt by the splash
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the splash
      # @return [Integer]
      def calc_splash_damage(user, target)
        return (target.max_hp / 16)
      end
    end
    register(:s_flame_burst, FlameBurst)
  end
end
