module Battle
  module Effects
    # Implement the Lock-On and Mind Reader effect
    class LockOn < PokemonTiedEffectBase
      # The Pokemon that launched the attack
      # @return [PFM::PokemonBattler]
      attr_reader :target

      # Create a new Pokemon Lock-On effect
      # @param logic [Battle::Logic]
      # @param user [PFM::PokemonBattler] pokemon aiming
      # @param target [PFM::PokemonBattler] pokemon aimed
      # @param turncount [Integer] (default: 2)
      def initialize(logic, user, target, turncount = 2)
        super(logic, user)
        @target = target
        self.counter = turncount
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :lock_on
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with, @target, @counter + 1)
      end
    end
  end
end
