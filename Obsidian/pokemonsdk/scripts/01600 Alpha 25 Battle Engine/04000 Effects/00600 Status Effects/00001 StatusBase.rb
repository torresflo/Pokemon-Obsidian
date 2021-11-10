module Battle
  module Effects
    class Status < EffectBase
      # Get the ID of the status
      # @return [Integer]
      attr_reader :status_id
      # Get the target of the effect
      # @return [PFM::PokemonBattler]
      attr_reader :target

      @registered_statuses = {}

      # Create a new status effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      # @param status_id [Integer] ID of the status
      def initialize(logic, target, status_id)
        super(logic)
        @target = target
        @status_id = status_id
      end

      # Tell if the status effect is poisoning
      # @return [Boolean]
      def poison?
        status_id == GameData::States::POISONED
      end

      # Tell if the status effect is paralysis
      # @return [Boolean]
      def paralysis?
        status_id == GameData::States::PARALYZED
      end

      # Tell if the status effect is burn
      # @return [Boolean]
      def burn?
        status_id == GameData::States::BURN
      end

      # Tell if the status effect is asleep
      # @return [Boolean]
      def asleep?
        status_id == GameData::States::ASLEEP
      end

      # Tell if the status effect is frozen
      # @return [Boolean]
      def frozen?
        status_id == GameData::States::FROZEN
      end

      # Tell if the status effect is toxic
      # @return [Boolean]
      def toxic?
        status_id == GameData::States::TOXIC
      end

      # Tell if the effect is a global poisoning effect (poison or toxic)
      # @return [Boolean]
      def global_poisoning?
        poison? || toxic?
      end

      class << self
        # Register a new status
        # @param status_id [Integer] ID of the status
        # @param klass [Class<Status>] class of the status effect
        def register(status_id, klass)
          @registered_statuses[status_id] = klass
        end

        # Create a new Status effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param status_id [Integer] ID of the status
        # @return [Status]
        def new(logic, target, status_id)
          klass = @registered_statuses[status_id] || Status
          object = klass.allocate
          object.send(:initialize, logic, target, status_id)
          return object
        end
      end
    end
  end
end
