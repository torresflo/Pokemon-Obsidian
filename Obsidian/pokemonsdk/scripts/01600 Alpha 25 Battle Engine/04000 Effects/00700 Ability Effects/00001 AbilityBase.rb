module Battle
  module Effects
    class Ability < EffectBase
      # Get the db_symbol of the ability
      # @return [Symbol]
      attr_reader :db_symbol
      # Get the target of the effect
      # @return [PFM::PokemonBattler]
      attr_reader :target
      # Detect if the ability affects allies
      # @return [Boolean]
      attr_reader :affect_allies

      @registered_abilities = {}

      # Create a new ability effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      # @param db_symbol [Symbol] db_symbol of the ability
      def initialize(logic, target, db_symbol)
        super(logic)
        @target = target
        @db_symbol = db_symbol
        @affect_allies = false
      end

      class << self
        # Register a new ability
        # @param db_symbol [Symbol] db_symbol of the ability
        # @param klass [Class<Ability>] class of the ability effect
        def register(db_symbol, klass)
          @registered_abilities[db_symbol] = klass
        end

        # Create a new Ability effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        # @return [Ability]
        def new(logic, target, db_symbol)
          klass = @registered_abilities[db_symbol] || Ability
          object = klass.allocate
          object.send(:initialize, logic, target, db_symbol)
          return object
        end
      end
    end
  end
end
