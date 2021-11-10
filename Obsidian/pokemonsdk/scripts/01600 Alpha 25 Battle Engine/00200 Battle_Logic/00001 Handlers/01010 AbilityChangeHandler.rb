module Battle
  class Logic
    # Handler responsive of answering properly ability changes requests
    class AbilityChangeHandler < ChangeHandlerBase
      include Hooks

      CANT_OVERWRITE_ABILITIES = %i[battle_bond comatose disguise multitype power_construct rks_system schooling shields_down stance_change zen_mode]
      # Case of a move that fail if the target has this ability
      SKILL_BLOCKING_ABILITIES = {
        entrainment: %i[truant],
        role_play: %i[flower_gift forecast illusion imposter power_of_alchemy receiver trace wonder_guard],
        simple_beam: %i[simple truant],
        skill_swap: %i[illusion wonder_guard]
      }
      # Case of a ability that fail
      ABILITY_BLOCKING_ABILITIES = {
        mummy: %i[mummy],
        wandering_spirit: %i[wandering_spirit],
        trace: %i[flower_gift forecast illusion imposter multitype stance_change trace zen_mode]
      }
      # Case of a move that fail if the launcher has this ability
      USER_BLOCKING_ABILITIES = {
        # TODO: Gestion des cas d'un fail de l'attaque si l'utilisateur possède tel talent
        entrainment: %i[disguise forecast flower_gift illusion imposter power_construct power_of_alchemy receiver trace zen_mode],
        role_play: CANT_OVERWRITE_ABILITIES
      }

      # Function that change the ability of a Pokemon
      # @param target [PFM::PokemonBattler]
      # @param ability_symbol [Symbol, :none] Symbol ID of the Ability
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def change_ability(target, ability_symbol, launcher = nil, skill = nil)
        return unless can_change_ability?(target, ability_symbol, launcher, skill)

        target.ability = (ability_symbol == :none ? 0 : GameData::Abilities.get_id(ability_symbol)) || 0
      end

      # Function that tell if this is possible to change the ability of a Pokemon
      # @param target [PFM::PokemonBattler]
      # @param ability_symbol [Symbol, :none] Symbol ID of the Ability
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def can_change_ability?(target, ability_symbol, launcher = nil, skill = nil)
        log_data("# can_change_ability?(#{target}, #{ability_symbol}, #{launcher}, #{skill})")
        exec_hooks(AbilityChangeHandler, :ability_change_prevention, binding)
        return true
      rescue Hooks::ForceReturn => e
        log_data("# FR: can_change_ability? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      class << self
        # Function that registers a ability_change_prevention hook
        # @param reason [String] reason of the ability_change_prevention registration
        # @yieldparam handler [AbilityChangeHandler]
        # @yieldparam target [PFM::PokemonBattler]
        # @yieldparam ability_symbol [Symbol] Symbol of the Ability which will be set
        # @yieldparam launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @yieldparam skill [Battle::Move, nil] Potential move used
        # @yieldreturn [:prevent, nil] :prevent if the ability cannot be changed
        def register_ability_prevention_hook(reason)
          Hooks.register(AbilityChangeHandler, :ability_change_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:target),
              hook_binding.local_variable_get(:ability_symbol),
              hook_binding.local_variable_get(:launcher),
              hook_binding.local_variable_get(:skill)
            )
            force_return(false) if result == :prevent
          end
        end
      end
    end

    # Cannot overwrite specific abilities
    AbilityChangeHandler.register_ability_prevention_hook('PSDK Ability Prev: Cannot OW Target Ability') do |handler, target, _, _, _|
      next unless AbilityChangeHandler::CANT_OVERWRITE_ABILITIES.include?(target.ability_db_symbol)

      next handler.prevent_change # silent
    end

    # Cannot overwrite specific abilities with a skill
    AbilityChangeHandler.register_ability_prevention_hook('PSDK Ability Prev: Cannot OW Target Ability With Skill') do |handler, target, _, launcher, skill|
      next unless skill && launcher != target && AbilityChangeHandler::SKILL_BLOCKING_ABILITIES[skill.db_symbol]&.include?(target.ability_db_symbol)

      next handler.prevent_change # silent
    end

    # Cannot overwrite specific abilities with an ability
    AbilityChangeHandler.register_ability_prevention_hook('PSDK Ability Prev: Cannot OW Target Ability With Ability') do |handler, target, ability_symbol, _, skill|
      next unless AbilityChangeHandler::ABILITY_BLOCKING_ABILITIES[ability_symbol]&.include?(target.ability_db_symbol) && !skill

      next handler.prevent_change # silent
    end

    # Cannot overwrite specific abilities with a skill
    AbilityChangeHandler.register_ability_prevention_hook('PSDK Ability Prev: Cannot OW User Ability With Skill') do |handler, target, _, launcher, skill|
      next unless skill && launcher == target && AbilityChangeHandler::SKILL_BLOCKING_ABILITIES[skill.db_symbol]&.include?(launcher.ability_db_symbol)

      next handler.prevent_change # silent
    end
  end
end
