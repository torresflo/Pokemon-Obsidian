module Battle
  module Effects
    class Item < EffectBase
      # Get the db_symbol of the item
      # @return [Symbol]
      attr_reader :db_symbol
      # Get the target of the effect
      # @return [PFM::PokemonBattler]
      attr_reader :target

      @registered_items = {}

      # Create a new item effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      # @param db_symbol [Symbol] db_symbol of the item
      def initialize(logic, target, db_symbol)
        super(logic)
        @target = target
        @db_symbol = db_symbol
      end

      class << self
        # Register a new item
        # @param db_symbol [Symbol] db_symbol of the item
        # @param klass [Class<Item>] class of the item effect
        def register(db_symbol, klass)
          @registered_items[db_symbol] = klass
        end

        # Create a new Item effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the item
        # @return [Item]
        def new(logic, target, db_symbol)
          klass = @registered_items[db_symbol] || Item
          object = klass.allocate
          object.send(:initialize, logic, target, db_symbol)
          return object
        end
      end
    end
  end
end
