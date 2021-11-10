module Battle
  module Effects
    # Implement the Substitute effect
    class Substitute < PokemonTiedEffectBase
      # Get the substitute hp
      # @return [Integer]
      attr_accessor :hp
      # Get the substitute max hp
      attr_reader :max_hp

      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      def initialize(logic, pokemon)
        super
        @hp = @max_hp = pokemon.max_hp / 4
      end

      # Function called when a stat_increase_prevention is checked
      # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the stat increase cannot apply
      def on_stat_increase_prevention(handler, stat, target, launcher, skill)
        return if target != @pokemon
        return :prevent if target != launcher && skill && skill.db_symbol != :defog

        return nil
      end

      # Function called when a stat_decrease_prevention is checked
      # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the stat decrease cannot apply
      def on_stat_decrease_prevention(handler, stat, target, launcher, skill)
        return if target != @pokemon
        return :prevent if target != launcher && skill && skill.db_symbol != :defog

        return nil
      end

      # Function called when a damage_prevention is checked
      # @param handler [Battle::Logic::DamageHandler]
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
      def on_damage_prevention(handler, hp, target, launcher, skill)
        return if target != @pokemon || !skill
        return if skill.sound_attack?

        result_hp = hp - @hp
        handler.prevent_change do
          @hp -= hp
          if @hp <= 0
            kill
            target.effects.delete_specific_dead_effect(:substitute)
            handler.scene.visual.show_switch_form_animation(target)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 794, target))
          else
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 791, target))
          end
        end

        # We modify the HP if the substitute broke
        return result_hp <= 0 ? :prevent : result_hp
      end

      # Function called when a status_prevention is checked
      # @param handler [Battle::Logic::StatusChangeHandler]
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the status cannot be applied
      def on_status_prevention(handler, status, target, launcher, skill)
        return if target != @pokemon || !skill || status == :cure || launcher == target

        return handler.prevent_change do
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 24, target))
        end
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :substitute
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with)
      end
    end
  end
end
