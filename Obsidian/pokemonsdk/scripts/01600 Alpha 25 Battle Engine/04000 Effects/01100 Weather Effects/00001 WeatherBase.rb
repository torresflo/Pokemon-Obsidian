module Battle
  module Effects
    class Weather < EffectBase
      # Get the db_symbol of the weather
      # @return [Symbol]
      attr_reader :db_symbol

      @registered_weathers = {}

      # Create a new weather effect
      # @param logic [Battle::Logic]
      # @param db_symbol [Symbol] db_symbol of the weather
      def initialize(logic, db_symbol)
        super(logic)
        @db_symbol = db_symbol
      end

      class << self
        # Register a new weather
        # @param db_symbol [Symbol] db_symbol of the weather
        # @param klass [Class<Weather>] class of the weather effect
        def register(db_symbol, klass)
          @registered_weathers[db_symbol] = klass
        end

        # Create a new Weather effect
        # @param logic [Battle::Logic]
        # @param db_symbol [Symbol] db_symbol of the weather
        # @return [Weather]
        def new(logic, db_symbol)
          klass = @registered_weathers[db_symbol] || Weather
          object = klass.allocate
          object.send(:initialize, logic, db_symbol)
          return object
        end
      end
    end
  end
end
