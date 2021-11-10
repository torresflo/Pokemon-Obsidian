module Battle
  class Move
    # Class managing moves that deal double power & cure status
    class HitThenCureStatus < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return power * 2 if status_check(target)

        return super
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next unless status_check(target)

          @logic.status_change_handler.status_change(:cure, target, user)
        end
      end

      # Check the status
      # @return [Boolean] tell if the Pokemon has this status
      def status_check(target)
        log_error('Move Implementation Error: status_check should be overwritten in child class.')
      end
    end

    # Class managing Smelling Salts move
    class SmellingSalts < HitThenCureStatus
      # Check the status
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean] tell if the Pokemon has this status
      def status_check(target)
        return target.paralyzed?
      end
    end

    # Class managing Wake-Up Slap move
    class WakeUpSlap < HitThenCureStatus
      # Check the status
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean] tell if the Pokemon has this status
      def status_check(target)
        return target.asleep?
      end
    end

    Move.register(:s_smelling_salt, SmellingSalts)
    Move.register(:s_wakeup_slap, WakeUpSlap)
  end
end
