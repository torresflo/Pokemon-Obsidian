module Battle
  class Move
    module Mechanics
      # Preset used for item based attacks
      # Should be included only in a Battle::Move class or a class with the same interface
      # The includer must overwrite the following methods:
      # - private consume_item?
      # - private valid_item_hold?
      module ItemBased
        # Function that tests if the user is able to use the move
        # @param user [PFM::PokemonBattler] user of the move
        # @param targets [Array<PFM::PokemonBattler>] expected targets
        # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
        # @return [Boolean] if the procedure can continue
        def move_usable_by_user(user, targets)
          return false unless super
          return show_usage_failure(user) && false unless valid_held_item?(user.item_db_symbol)

          return true
        end
        alias item_based_move_usable_by_user move_usable_by_user

        private

        # Function that deals the damage to the pokemon
        # @param user [PFM::PokemonBattler] user of the move
        # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
        def deal_damage(user, actual_targets)
          super
          consume_item(user)
        end
        alias item_based_deal_damage deal_damage

        # Remove the item from the battler
        # @param battler [PFM::PokemonBattler]
        def consume_item(battler)
          return unless consume_item?

          @logic.item_change_handler.change_item(:none, true, battler, battler, self)
        end

        # Tell if the move consume the item
        # @return [Boolean]
        def consume_item?
          log_error("#{__method__} should be overwritten by #{self.class}")
          false
        end

        # Test if the held item is valid
        # @param name [Symbol]
        # @return [Boolean]
        def valid_held_item?(name)
          log_error("#{__method__} should be overwritten by #{self.class}")
          return false
        end
      end

      # Preset used for attacks with power based on held item.
      # Should be included only in a Battle::Move class or a class with the same interface
      # The includer must overwrite the following methods:
      # - private consume_item?
      # - private valid_item_hold?
      # - private get_power_by_item
      module PowerBasedOnItem
        include ItemBased

        # Get the real base power of the move (taking in account all parameter)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @return [Integer]
        def real_base_power(user, target)
          return super unless valid_held_item?(user.item_db_symbol)

          log_data("power = #{get_power_by_item(user.item_db_symbol)} # move based on held item")
          return get_power_by_item(user.item_db_symbol)
        end
        alias power_based_on_item_real_base_power real_base_power

        private

        # Get the real power of the move depending on the item
        # @param name [Symbol]
        # @return [Integer]
        def get_power_by_item(name)
          log_error("#{__method__} should be overwritten by #{self.class}")
          return 0
        end
      end

      # Preset used for attacks with power based on held item.
      # Should be included only in a Battle::Move class or a class with the same interface
      # The includer must overwrite the following methods:
      # - private consume_item?
      # - private valid_item_hold?
      # - private get_types_by_item
      module TypesBasedOnItem
        include ItemBased

        # Get the types of the move with 1st type being affected by effects
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @return [Array<Integer>] list of types of the move
        def definitive_types(user, target)
          return super unless valid_held_item?(user.item_db_symbol)

          log_data("types = #{get_types_by_item(user.item_db_symbol)} # move based on held item")
          return get_types_by_item(user.item_db_symbol)
        end
        alias types_based_on_item_definitive_types definitive_types

        private

        # Get the real types of the move depending on the item
        # @param name [Symbol]
        # @return [Array<Integer>]
        def get_types_by_item(name)
          log_error("#{__method__} should be overwritten by #{self.class}")
          return []
        end
      end
    end
  end
end
