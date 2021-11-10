module Battle
  class Move
    # Function that calculate the type modifier (for specific uses)
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def type_modifier(user, target)
      types = definitive_types(user, target)
      n = calc_type_n_multiplier(target, :type1, types) *
          calc_type_n_multiplier(target, :type2, types) *
          calc_type_n_multiplier(target, :type3, types)
      return n
    end

    # STAB calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param types [Array<Integer>] list of definitive types of the move
    # @return [Numeric]
    def calc_stab(user, types)
      if types.any? { |type| user.type1 == type || user.type2 == type || user.type3 == type }
        return 2 if user.has_ability?(:adaptability)

        return 1.5
      end
      return 1
    end

    # Get the types of the move with 1st type being affected by effects
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Array<Integer>] list of types of the move
    def definitive_types(user, target)
      type = self.type
      exec_hooks(Move, :move_type_change, binding)
      return [*type]
    ensure
      log_data(format('types = %<types>s # ie: %<ie>s', types: type.to_s, ie: [*type].map { |t| GameData::Type[t].name }.join(', ')))
    end

    private

    # Calc TypeN multiplier of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param type_to_check [Symbol] type to check on the target
    # @param types [Array<Integer>] list of types the move has
    # @return [Numeric]
    def calc_type_n_multiplier(target, type_to_check, types)
      target_type = target.send(type_to_check)
      result = types.inject(1) { |product, type| product * calc_single_type_multiplier(target, target_type, type) }
      if @effectiveness >= 0
        @effectiveness *= result
        log_data("multiplier of #{type_to_check} (#{GameData::Type[target_type].name}) = #{result} => new_eff = #{@effectiveness}")
      end
      return result
    end

    # Calc the single type multiplier
    # @param target [PFM::PokemonBattler] target of the move
    # @param target_type [Integer] one of the type of the target
    # @param type [Integer] one of the type of the move
    # @return [Float] definitive multiplier
    def calc_single_type_multiplier(target, target_type, type)
      exec_hooks(Move, :single_type_multiplier_overwrite, binding)
      return GameData::Type[target_type].hit_by(type)
    rescue Hooks::ForceReturn => e
      log_data("# calc_single_type_multiplier(#{target}, #{target_type}, #{type})")
      log_data("# FR: calc_single_type_multiplier #{e.data} from #{e.hook_name} (#{e.reason})")
      return e.data
    end

    class << self
      # Function that registers a move_type_change hook
      # @param reason [String] reason of the move_type_change registration
      # @yieldparam user [PFM::PokemonBattler]
      # @yieldparam target [PFM::PokemonBattler]
      # @yieldparam move [Battle::Move]
      # @yieldparam type [Integer] current type of the move
      # @yieldreturn [Integer, nil] new move type
      def register_move_type_change_hook(reason)
        Hooks.register(Move, :move_type_change, reason) do |hook_binding|
          result = yield(hook_binding.local_variable_get(:user), hook_binding.local_variable_get(:target), self,
                         hook_binding.local_variable_get(:type))
          hook_binding.local_variable_set(:type, result) if result.is_a?(Integer)
        end
      end

      # Function that registers a single_type_multiplier_overwrite hook
      # @param reason [String] reason of the single_type_multiplier_overwrite registration
      # @yieldparam target [PFM::PokemonBattler]
      # @yieldparam target_type [Integer] one of the type of the target
      # @yieldparam type [Integer] one of the type of the move
      # @yieldparam move [Battle::Move]
      # @yieldreturn [Float, nil] overwritten
      def register_single_type_multiplier_overwrite_hook(reason)
        Hooks.register(Move, :single_type_multiplier_overwrite, reason) do |hook_binding|
          result = yield(hook_binding.local_variable_get(:target),
                         hook_binding.local_variable_get(:target_type),
                         hook_binding.local_variable_get(:type), self)
          force_return(result) if result
        end
      end
    end

    Move.register_move_type_change_hook('PSDK Effect process') do |user, target, move, type|
      move.logic.each_effects(user, target) do |e|
        result = e.on_move_type_change(user, target, move, type)
        type = result if result.is_a?(Integer)
      end
      next type
    end

    Move.register_single_type_multiplier_overwrite_hook('PSDK Effect process') do |target, target_type, type, move|
      overwrite = nil
      move.logic.each_effects(target) do |e|
        next if overwrite

        result = e.on_single_type_multiplier_overwrite(target, target_type, type, move)
        overwrite = result if result
      end
      next overwrite
    end

    Move.register_single_type_multiplier_overwrite_hook('PSDK Freeze-Dry') do |_, target_type, _, move|
      next 2 if move.db_symbol == :freeze_dry && target_type == GameData::Types::WATER

      next nil
    end

    Move.register_single_type_multiplier_overwrite_hook('PSDK Grounded: Levitate & Air Balloon') do |target, _, type|
      next 0 if type == GameData::Types::GROUND && !target.grounded?

      next nil
    end
  end
end
