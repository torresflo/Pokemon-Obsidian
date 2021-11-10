module Battle
  class Move
    # Bide Move
    class Bide < BasicWithSuccessfulEffect
      # Get the types of the move with 1st type being affected by effects
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Array<Integer>] list of types of the move
      def definitive_types(user, target)
        [0]
      end

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        return super if user.effects.get(:bide)&.unleach?

        return true
      end

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if user.effects.get(:bide)&.unleach? && user.effects.get(:bide).damages == 0
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.effects.has?(:bide)

        user.effects.add(Effects::Bide.new(logic, user, self, actual_targets, 3))
      end

      # Method calculating the damages done by counter
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def damages(user, target)
        # @type [Effects::Bide]
        effect = user.effects.get(:bide)
        return ((effect&.damages || 1) * 2).clamp(1, Float::INFINITY)
      end

      # Method responsive testing accuracy and immunity.
      # It'll report the which pokemon evaded the move and which pokemon are immune to the move.
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Array<PFM::PokemonBattler>]
      def accuracy_immunity_test(user, targets)
        # @type [Array<PFM::PokemonBattler>]
        attackers = (logic.foes_of(user) + logic.allies_of(user)).sort { |a, b| b.attack_order <=> a.attack_order } # higher = first
        attacker = attackers.find { |foe| foe.move_history.last&.targets&.include?(user) && foe.move_history.last.turn == $game_temp.battle_turn }
        return [attacker || logic.foes_of(user).sample(random: logic.generic_rng)]
      end

      # Play the move animation (only without all the decoration)
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def play_animation_internal(user, targets)
        # TODO: Fix with 2 animation: charging, not doing anything
        super if user.effects.has?(:bide) && user.effects.get(:bide).unleach?
      end

      # Show the move usage message
      # @param user [PFM::PokemonBattler] user of the move
      def usage_message(user)
        if !user.effects.has?(:bide)
          super
        elsif user.effects.get(:bide).unleach?
          return scene.display_message_and_wait(parse_text_with_pokemon(19, 748, user))
        end
        scene.display_message_and_wait(parse_text_with_pokemon(19, 745, user))
      end
    end

    Move.register(:s_bide, Bide)
  end
end
