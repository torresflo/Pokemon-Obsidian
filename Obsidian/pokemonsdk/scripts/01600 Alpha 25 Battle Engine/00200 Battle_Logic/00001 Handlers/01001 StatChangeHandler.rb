module Battle
  class Logic
    # Handler responsive of answering properly statistic changes requests
    class StatChangeHandler < ChangeHandlerBase
      include Hooks
      # Position of text for Attack depending on the power
      TEXT_POS = {
        atk: atk = [0, 27, 48, 69, 153, 174, 132, 111, 90],
        dfe: atk.map { |i| i + 3 },
        ats: atk.map { |i| i + 6 },
        dfs: atk.map { |i| i + 9 },
        spd: atk.map { |i| i + 12 },
        acc: atk.map { |i| i + 15 },
        eva: atk.map { |i| i + 18 }
      }
      # ID of the animation depending on the stat
      ANIMATION = { atk: 478, dfe: 480, spd: 482, dfs: 486, ats: 484, eva: 488, acc: 490 }
      # Index of the stages depending on the stat to change
      # @return [Hash{ Symbol => Integer }]
      STAT_INDEX = safe_const(:STAT_INDEX) do
        {
          atk: GameData::Stages::ATK_STAGE,
          dfe: GameData::Stages::DFE_STAGE,
          ats: GameData::Stages::ATS_STAGE,
          dfs: GameData::Stages::DFS_STAGE,
          spd: GameData::Stages::SPD_STAGE,
          acc: GameData::Stages::ACC_STAGE,
          eva: GameData::Stages::EVA_STAGE
        }
      end
      # Array containing all the possible stats
      ALL_STATS = %i[atk dfe spd dfs ats eva acc]
      # Array containing all the attack kind stat
      ATTACK_STATS = %i[atk ats]
      # Array containing all the defense kind stat
      DEFENSE_STATS = %i[dfe dfs]
      # Array containing the physical stats
      PHYSICAL_STATS = %i[atk dfe]
      # Array containing the special stats
      SPECIAL_STATS = %i[ats dfs]
      # Function telling if a stat can be increased
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @note Thing that prevents the stat from increasoing should be defined using :stat_increase_prevention Hook.
      # @return [Boolean]
      def stat_increasable?(stat, target, launcher = nil, skill = nil)
        return false if target.hp <= 0

        reset_prevention_reason
        exec_hooks(StatChangeHandler, :stat_increase_prevention, binding)
        return true
      rescue Hooks::ForceReturn => e
        log_data("# stat = #{stat}; target = #{target}; launcher = #{launcher}; skill = #{skill}")
        log_data("# FR: stat_increasable? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function telling if a stat can be decreased
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @note Thing that prevents the stat from decreasing should be defined using :stat_decrease_prevention Hook.
      # @return [Boolean]
      def stat_decreasable?(stat, target, launcher = nil, skill = nil)
        return false if target.hp <= 0

        reset_prevention_reason
        exec_hooks(StatChangeHandler, :stat_decrease_prevention, binding)
        return true
      rescue Hooks::ForceReturn => e
        log_data("# stat = #{stat}; target = #{target}; launcher = #{launcher}; skill = #{skill}")
        log_data("# FR: stat_decreasable? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that actually change a stat
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param power [Integer] power of the stat change
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param no_message [Boolean] if the message about stat increase should be shown
      def stat_change(stat, power, target, launcher = nil, skill = nil, no_message: false)
        log_data("# stat_change(#{stat}, #{power}, #{target}, #{launcher}, #{skill})")
        exec_hooks(StatChangeHandler, :stat_change, binding)
        amount = target.change_stat(STAT_INDEX[stat], power)
        show_stat_change_text_and_animation(stat, power, amount, target, no_message)
        exec_hooks(StatChangeHandler, :stat_change_post_event, binding)
      rescue Hooks::ForceReturn => e
        log_data("# FR: stat_change #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that test if the change is possible and perform the change if so
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param power [Integer] power of the stat change
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @param no_message [Boolean] if the message about stat increase should be shown
      def stat_change_with_process(stat, power, target, launcher = nil, skill = nil, no_message: false)
        if power < 0
          result = stat_decreasable?(stat, target, launcher, skill)
        else
          result = stat_increasable?(stat, target, launcher, skill)
        end
        return process_prevention_reason unless result

        stat_change(stat, power, target, launcher, skill, no_message: no_message)
      end

      # Get the text index in the TEXT_POS array depending on amount & power
      # @param amount [Integer]
      # @param power [Integer]
      # @return [Integer] text pos
      def stat_text_index(amount, power)
        if amount != 0
          return -3 if power < -2

          return (power > 2 ? 3 : power)
        end
        return (power > 0 ? 4 : 5)
      end

      private

      # Play the animation & display the text depending on the stat
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param power [Integer] expected power of the stat increase
      # @param amount [Integer] actual amount changed
      # @param target [PFM::PokemonBattler]
      # @param no_message [Boolean] if the message about stat increase should be shown
      def show_stat_change_text_and_animation(stat, power, amount, target, no_message)
        text_index = stat_text_index(amount, power)
        @scene.visual.show_rmxp_animation(target, ANIMATION[stat] + (power < 0 ? 1 : 0)) if amount != 0
        @scene.display_message_and_wait(parse_text_with_pokemon(19, TEXT_POS[stat][text_index], target)) unless no_message
      end

      class << self
        # Function that registers a stat_increase_prevention hook
        # @param reason [String] reason of the stat_increase_prevention registration
        # @yieldparam handler [StatChangeHandler]
        # @yieldparam stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        # @yieldreturn [:prevent, nil] :prevent if the stat increase cannot apply
        def register_stat_increase_prevention_hook(reason)
          Hooks.register(StatChangeHandler, :stat_increase_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:stat),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
            force_return(false) if result == :prevent
          end
        end

        # Function that registers a stat_decrease_prevention hook
        # @param reason [String] reason of the stat_decrease_prevention registration
        # @yieldparam handler [StatChangeHandler]
        # @yieldparam stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        # @yieldreturn [:prevent, nil] :prevent if the stat decrease cannot apply
        def register_stat_decrease_prevention_hook(reason)
          Hooks.register(StatChangeHandler, :stat_decrease_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:stat),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
            force_return(false) if result == :prevent
          end
        end

        # Function that register a stat_change_post_event hook
        # @param reason [String] reason of the stat_change_post_event registration
        # @yieldparam handler [StatChangeHandler]
        # @yieldparam stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @yieldparam power [Integer] power of the stat change
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        def register_stat_change_post_event_hook(reason)
          Hooks.register(StatChangeHandler, :stat_change_post_event, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:stat),
              hook_binding.local_variable_get(:power),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
          end
        end

        # Function that register a stat_change hook
        # @param reason [String] reason of the stat_change registration
        # @yieldparam handler [StatChangeHandler]
        # @yieldparam stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @yieldparam power [Integer] power of the stat change
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        # @yieldreturn [Integer, nil] if integer, it will change the power
        def register_stat_change_hook(reason)
          Hooks.register(StatChangeHandler, :stat_change, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:stat),
              hook_binding.local_variable_get(:power),
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
            hook_binding.local_variable_set(:power, result) if result.is_a?(Integer)
          end
        end
      end
    end

    # Register native impossibilities
    StatChangeHandler.register_stat_decrease_prevention_hook('PSDK stat decr: self stage') do |handler, stat, target, _, _|
      next if target.battle_stage[StatChangeHandler::STAT_INDEX[stat]] != PFM::PokemonBattler::MIN_STAGE

      next handler.prevent_change do
        text_index = handler.stat_text_index(0, -1)
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, StatChangeHandler::TEXT_POS[stat][text_index], target))
      end
    end
    StatChangeHandler.register_stat_increase_prevention_hook('PSDK stat incr: self stage') do |handler, stat, target, _, _|
      next if target.battle_stage[StatChangeHandler::STAT_INDEX[stat]] != PFM::PokemonBattler::MAX_STAGE

      next handler.prevent_change do
        text_index = handler.stat_text_index(0, 1)
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, StatChangeHandler::TEXT_POS[stat][text_index], target))
      end
    end

    # Register the effects
    StatChangeHandler.register_stat_decrease_prevention_hook('PSDK stat decr: Effects') do |handler, stat, target, launcher, skill|
      next handler.logic.each_effects(target, launcher) do |effect|
        next effect.on_stat_decrease_prevention(handler, stat, target, launcher, skill)
      end
    end
    StatChangeHandler.register_stat_increase_prevention_hook('PSDK stat incr: Effects') do |handler, stat, target, launcher, skill|
      next handler.logic.each_effects(target, launcher) do |effect|
        next effect.on_stat_decrease_prevention(handler, stat, target, launcher, skill)
      end
    end
    StatChangeHandler.register_stat_change_hook('PSDK stat_change: Effects') do |handler, stat, power, target, launcher, skill|
      handler.logic.each_effects(target, launcher) do |effect|
        result = effect.on_stat_change(handler, stat, power, target, launcher, skill)
        power = result if result.is_a?(Integer)
      end
      next power
    end
    StatChangeHandler.register_stat_change_post_event_hook('PSDK stat_change_post: Effects') do |handler, stat, power, target, launcher, skill|
      next handler.logic.each_effects(target, launcher) do |effect|
        next effect.on_stat_change_post(handler, stat, power, target, launcher, skill)
      end
    end
  end
end
