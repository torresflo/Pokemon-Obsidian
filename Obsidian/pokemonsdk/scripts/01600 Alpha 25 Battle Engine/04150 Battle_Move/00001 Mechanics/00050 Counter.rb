module Battle
  class Move
    module Mechanics
      # Preset used for counter attacks
      # Should be included only in a Battle::Move class or a class with the same interface
      # The includer must overwrite the following methods:
      # - counter_fails?(attacker, user, targets)
      module Counter
        # Function that tests if the user is able to use the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
        # @return [Boolean] if the procedure can continue
        def move_usable_by_user(user, targets)
          return false unless super
          return show_usage_failure(user) && false if counter_fails?(last_attacker(user), user, targets)

          return true
        end
        alias counter_move_usable_by_user move_usable_by_user

        # Method calculating the damages done by counter
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @return [Integer]
        def damages(user, target)
          @effectiveness = 1
          @critical = false
          return 1 unless (attacker = last_attacker(user))

          log_data("damages = #{(attacker.move_history.last.move.damage_dealt * damage_multiplier).floor.clamp(1, Float::INFINITY)} # after counter")
          return (attacker.move_history.last.move.damage_dealt * damage_multiplier).floor.clamp(1, Float::INFINITY)
        end
        alias counter_damages damages

        private

        # Test if the attack fails
        # @param attacker [PFM::PokemonBattler] the last attacker
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @return [Boolean] does the attack fails ?
        def counter_fails?(attacker, user, targets)
          log_error("#{self.class} should overwrite #{__method__}")
          return false
        end

        # Damage multiplier if the effect proc
        # @return [Integer, Float]
        def damage_multiplier
          2
        end

        # Method responsive testing accuracy and immunity.
        # It'll report the which pokemon evaded the move and which pokemon are immune to the move.
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @return [Array<PFM::PokemonBattler>]
        def accuracy_immunity_test(user, targets)
          super(user, [last_attacker(user)].compact)
        end
        alias counter_accuracy_immunity_test accuracy_immunity_test

        # Get the last pokemon that used a skill over the user
        # @param user [PFM::PokemonBattler]
        # @return [PFM::PokemonBattler, nil]
        def last_attacker(user)
          # @type [Array<PFM::PokemonBattler>]
          foes = logic.foes_of(user).sort { |a, b| b.attack_order <=> a.attack_order } # higher = first
          attacker = foes.find { |foe| foe.move_history&.last&.targets&.include?(user) && foe.move_history.last.turn == $game_temp.battle_turn }
          return attacker
        end
        alias counter_last_attacker last_attacker
      end
    end
  end
end
