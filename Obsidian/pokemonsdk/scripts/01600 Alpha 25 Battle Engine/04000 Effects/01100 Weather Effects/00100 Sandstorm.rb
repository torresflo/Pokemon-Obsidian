module Battle
  module Effects
    class Weather
      class Sandstorm < Weather
        # List of abilities that blocks sandstorm damages
        SANDSTORM_BLOCKING_ABILITIES = %i[magic_guard sand_veil sand_rush sand_force overcoat]
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          if $env.decrease_weather_duration
            scene.display_message_and_wait(parse_text(18, 94))
            logic.weather_change_handler.weather_change(:none, 0)
          else
            scene.visual.show_rmxp_animation(battlers.first || logic.battler(0, 0), 494)
            scene.display_message_and_wait(parse_text(18, 98))
            battlers.each do |battler|
              next if battler.dead?
              next if battler.type_rock? || battler.type_ground? || battler.type_steel?
              next if SANDSTORM_BLOCKING_ABILITIES.include?(battler.battle_ability_db_symbol)

              logic.damage_handler.damage_change((battler.max_hp / 16).clamp(1, Float::INFINITY), battler)
            end
          end
        end

        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if move.physical?
          return 1 unless target.type_rock?

          return 1.5
        end
      end
      register(:sandstorm, Sandstorm)
    end
  end
end
