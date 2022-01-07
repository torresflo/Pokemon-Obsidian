module Battle
  module Effects
    class Ability
      class PowerOfAlchemy < Ability
        # Create a new PowerOfAlchemy effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          user = @target
          return if target == user
          return unless @logic.ability_change_handler.can_change_ability?(user, target.ability_db_symbol)

          @logic.ability_change_handler.change_ability(user, target.ability_db_symbol)
          handler.scene.visual.show_ability(user)
          handler.scene.display_message_and_wait(parse_text(5, 222))
        end
      end
      register(:power_of_alchemy, PowerOfAlchemy)
      register(:receiver, PowerOfAlchemy)
    end
  end
end
