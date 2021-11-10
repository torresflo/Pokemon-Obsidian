module Battle
  class Logic
    # Handler responsive of answering properly transform requests
    class TransformHandler < ChangeHandlerBase
      include Hooks
      # Function responsive of transforming a Pokemon when initialized
      # @param target [PFM::PokemonBattler]
      def initialize_transform_attempt(target)
        exec_hooks(TransformHandler, :on_initialize_transform, binding)
      end

      # Function that tells if the Pokemon can transform or not
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def can_transform?(target)
        return !target.transform
      end

      # Function that tells if the pokemon can copy another pokemon
      # @param copied [PFM::PokemonBattler]
      # @return [Boolean]
      def can_copy?(copied)
        return false if copied&.effects&.has?(:substitute)
        return false if copied.has_ability?(:illusion) && !can_transform?(copied)

        return true
      end

      class << self
        # Function that registers a on_initialize_transform hook
        # @param reason [String] reason of the on_initialize_transform registration
        # @yieldparam handler [TransformHandler]
        # @yieldparam target [PFM::PokemonBattler] pokemon to try to transform on initialize
        # @yieldreturn [nil]
        def register_on_initialize_transform(reason)
          Hooks.register(TransformHandler, :on_initialize_transform, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:target)
            )
          end
        end
      end
    end

    TransformHandler.register_on_initialize_transform('PSDK: Illusion') do |handler, target|
      next if target.original.ability_db_symbol != :illusion
      next unless handler.can_transform?(target)

      party = handler.logic.battle_info.party(target)
      party = party&.reject(&:dead?)
      next if party.empty? || party.index(target) == (party.size - 1)

      target.transform = party.last
    end

    TransformHandler.register_on_initialize_transform('PSDK transform : Effects') do |handler, target|
      next unless target.effects

      next handler.logic.each_effects(target) do |e|
        next e.on_transform_event(handler, target)
      end
    end
  end
end
