module Battle
  class Move
    # Moves that change the ability of a Pokémon
    # Template = Role Play
    class AbilityChanging < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return false if targets.empty?

        unless @logic.ability_change_handler.can_change_ability?(user, ability_symbol(user, targets.first), user, self)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next unless @logic.ability_change_handler.can_change_ability?(user, ability_symbol(user, target), user, self)

          @scene.visual.show_ability(user)
          @scene.visual.wait_for_animation
          @logic.ability_change_handler.change_ability(user, ability_symbol(user, target), user, self)
          @scene.visual.show_ability(user)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 619, user, PFM::Text::ABILITY[2] => target.ability_name,
                                                                                 PFM::Text::PKNICK[1] => target.given_name))
        end
      end

      # Function that returns the ability which will assigned to the target
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      def ability_symbol(user, target)
        return target.ability_db_symbol
      end
    end

    # Role Play move
    class Entrainment < AbilityChanging
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        can_change_ability = targets.any? do |target|          
          @logic.ability_change_handler.can_change_ability?(target, ability_symbol(user, target), user, self) && 
          target.ability_db_symbol != ability_symbol(user, target)
        end

        unless can_change_ability
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next unless @logic.ability_change_handler.can_change_ability?(target, ability_symbol(user, target), user, self)

          @scene.visual.show_ability(target)
          @scene.visual.wait_for_animation
          @logic.ability_change_handler.change_ability(target, ability_symbol(user, target), user, self)
          @scene.visual.show_ability(target)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 405, target, PFM::Text::ABILITY[1] => target.ability_name))
        end
      end
    end

    # Simple Beam move
    class SimpleBeam < Entrainment
      # Function that returns the ability which will assigned to the target
      def ability_symbol(user, target)
        return :simple
      end
    end

    # Worry Seed move
    class WorrySeed < Entrainment
      # Function that returns the ability which will assigned to the target
      def ability_symbol(user, target)
        return :insomnia
      end
    end

    # Skill Swap move
    # Move that exchanges ability between user and target
    class AbilitySwap < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return false if targets.empty?

        unless @logic.ability_change_handler.can_change_ability?(user, targets.first.ability_db_symbol, user, self) &&
               @logic.ability_change_handler.can_change_ability?(targets.first, user.ability_db_symbol, user, self)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next unless @logic.ability_change_handler.can_change_ability?(user, target.ability_db_symbol, user, self) &&
                      @logic.ability_change_handler.can_change_ability?(target, user.ability_db_symbol, user, self)

          @scene.visual.show_ability(user)
          @scene.visual.show_ability(target)
          @scene.visual.wait_for_animation
          user_ability = user.ability_db_symbol
          @logic.ability_change_handler.change_ability(user, target.ability_db_symbol, user, self)
          @logic.ability_change_handler.change_ability(target, user_ability, user, self)
          @scene.visual.show_ability(user)
          @scene.visual.show_ability(target)
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 508, user))
        end
      end
    end

    Move.register(:s_entrainment, Entrainment)
    Move.register(:s_simple_beam, SimpleBeam)
    Move.register(:s_skill_swap, AbilitySwap)
    Move.register(:s_role_play, AbilityChanging)
    Move.register(:s_worry_seed, WorrySeed)
  end
end
