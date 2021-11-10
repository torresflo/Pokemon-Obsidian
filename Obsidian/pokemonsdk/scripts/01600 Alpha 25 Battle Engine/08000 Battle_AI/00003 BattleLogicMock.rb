module Battle
  # Module responsive of mocking the battle logic so nothing happen on the reality
  #
  # Note: super inside this script might call the original function
  module LogicMock
    class << self
      # Method called when a visual gets mocked (through extend)
      # @param mod [Battle::Logic]
      def extended(mod)
        mod.instance_variable_set(:@battle_info, mod.scene.battle_info)
        mod.instance_variable_set(:@messages, [])
        mod.instance_variable_set(:@actions, [])
        mod.instance_eval do
          @battlers.each do |battler_arr|
            battler_arr.map! do |battler|
              # @type [PFM::PokemonBattler]
              battler = battler.clone
              battler.instance_variable_set(:@scene, mod.scene)
              next battler
            end
          end
        end
        # @type [Array<PFM::PokemonBattler>]
        battlers = mod.instance_variable_get(:@battlers).flatten
        battlers.each do |battler|
          battler.instance_variable_set(:@effects, mock_effect_handler(battler.effects, battlers))
        end
        mod.instance_variable_set(:@terrain_effects, mock_effect_handler(mod.terrain_effects, battlers))
        mod.bank_effects.map { |effects| mock_effect_handler(effects, battlers) }
        mod.position_effects.each { |bank| bank&.map! { |effects| mock_effect_handler(effects, battlers) } }
        mod.instance_variable_set(:@evolve_request, [])
        mod.instance_variable_set(:@switch_request, [])
        mod.instance_variable_set(:@battle_result, -1)
        mod.instance_variable_set(:@env, Marshal.load(Marshal.dump($env)))
      end

      # Mock the effect handler
      # @param handler [Effects::EffectsHandler]
      # @param battlers [Array<PFM::PokemonBattler>]
      def mock_effect_handler(handler, battlers)
        handler = handler.clone
        # @type [Array<Object>]
        effects = handler.instance_variable_get(:@effects).clone
        effects.map! do |effect|
          effect = effect.clone
          effect.instance_variables.each do |iv|
            obj = effect.instance_variable_get(iv)
            next unless obj.is_a?(PFM::PokemonBattler)

            obj = battlers.find { |battler| battler.original == obj.original }
            effect.instance_variable_set(iv, obj) if obj
          end
          next effect
        end
        handler.instance_variable_set(:@effects, effects)
        return handler
      end
    end

    # Get a new weather change handler
    # @return [Battle::Logic::WeatherChangeHandler]
    def weather_change_handler
      return Logic::WeatherChangeHandler.new(self, @scene, @env)
    end

    # Get a new field terrain change handler
    # @return [Battle::Logic::WeatherChangeHandler]
    def fterrain_change_handler
      return Logic::FTerrainChangeHandler.new(self, @scene, @env)
    end

    # Get the env object
    # @return [PFM::Environnement]
    attr_reader :env
  end
end
