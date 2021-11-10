module Battle
  class Move
    # Class that manage the move Beat Up
    # Beat Up inflicts damage on the target from the user, and each conscious Pokémon in the user's party that does not have a non-volatile status.
    # @see https://bulbapedia.bulbagarden.net/wiki/Beat_Up_(move)
    # @see https://pokemondb.net/move/beat-up
    # @see https://www.pokepedia.fr/Baston
    class BeatUp < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if (@bu_battlers = battlers_that_hit(user, targets)).empty?
        return true
      end

      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        unless @bu_current_battler # @bu_current_battler = nil when called by AI
          bu_power = 0
          @logic.all_battlers do |battler|
            bu_power += (battler.atk_basis / 10 + 5).ceil if battler.bank == user.bank
          end
          return bu_power
        end
        bu_power = (@bu_current_battler.atk_basis / 10 + 5).ceil
        log_data("power = %i # BeatUp from %s on %s (through %s)" % [bu_power, @bu_current_battler.name, target.name, user.name])
        return bu_power
      end

      private

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        nb_hit = @bu_battlers.size.times.count do |i|
          next false unless actual_targets.any?(&:alive?)

          play_animation(user, actual_targets) if i > 0 # First hit animation played by Move
          @bu_current_battler = @bu_battlers[i]
          actual_targets.each do |target|
            next if target.dead?

            deal_damage_to_target(user, actual_targets, target)
          end
        end
        final_message(nb_hit)
      end

      # Function that deal the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @param target [PFM::PokemonBattler] the current target
      def deal_damage_to_target(user, actual_targets, target)
        hp = damages(user, target)
        @logic.damage_handler.damage_change_with_process(hp, target, user, self) do
          if critical_hit?
            critical_hit_message(target, actual_targets, target)
          elsif hp > 0 && target == actual_targets.last
            efficent_message(effectiveness, target)
          end
        end
        recoil(hp, user) if recoil?
      end

      # Function that retrieve the battlers that hit the targets
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Array[PFM::Battler]]
      def battlers_that_hit(user, actual_targets)
        logic.battle_info.party(user).select { |battler| battler.alive? && !battler.status? }
      end

      # Display the right message in case of critical hit
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @param target [PFM::PokemonBattler] the current target
      # @return [String]
      def critical_hit_message(user, actual_targets, target)
        scene.display_message_and_wait(actual_targets.size == 1 ? parse_text(18, 84) : parse_text_with_pokemon(19, 384, target))
      end

      # Display the message after all the hit have been performed
      # @param nb_hit [Integer] amount of hit performed
      def final_message(nb_hit)
        @scene.display_message_and_wait(parse_text(18, 33, PFM::Text::NUMB[1] => nb_hit.to_s))
      end
    end
    Move.register(:s_beat_up, BeatUp)
  end
end
