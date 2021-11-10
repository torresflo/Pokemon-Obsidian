module Battle
  class Move
    # Class managing OHKO moves
    class OHKO < Basic
      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        super
        scene.display_message_and_wait(parse_text(18, 100)) if actual_targets.any?(&:dead?) # "Its a one-hit KO!"
        return true
      end

      # Tell if the move is an OHKO move
      # @return [Boolean]
      def ohko?
        return true
      end

      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.type_ice? && db_symbol == :sheer_cold # Immunity after 7G

        return super
      end

      # Return the chance of hit of the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Float]
      def chance_of_hit(user, target)
        log_data("# OHKO move: chance_of_hit(#{user}, #{target}) for #{db_symbol}")
        return 100 if bypass_chance_of_hit?(user, target)

        return (user.level < target.level ? 0 : (user.level - target.level) + 30)
      end

      # Method calculating the damages done by the actual move
      # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        @critical = false
        @effectiveness = 1
        log_data('OHKO Move: 100% HP')
        return target.max_hp
      end
    end

    Move.register(:s_ohko, OHKO)
  end
end
