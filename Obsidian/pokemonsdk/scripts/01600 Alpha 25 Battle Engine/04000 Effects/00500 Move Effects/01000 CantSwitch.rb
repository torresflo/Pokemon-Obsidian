module Battle
  module Effects
    # CantSwitch Effect
    class CantSwitch < PokemonTiedEffectBase
      # The Pokemon that launched the attack
      # @return [PFM::PokemonBattler]
      attr_reader :origin
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param origin [PFM::PokemonBattler] Pokemon that used the move dealing this effect
      # @param move [Battle::Move] move responsive of the effect
      def initialize(logic, pokemon, origin, move)
        super(logic, pokemon)
        @origin = origin
        @move = move
      end

      # Function called when testing if pokemon can switch (when he couldn't passthrough)
      # @param handler [Battle::Logic::SwitchHandler]
      # @param pokemon [PFM::PokemonBattler]
      # @param skill [Battle::Move, nil] potential skill used to switch
      # @param reason [Symbol] the reason why the SwitchHandler is called
      # @return [:prevent, nil] if :prevent, can_switch? will return false
      def on_switch_prevention(handler, pokemon, skill, reason)
        return if pokemon != @pokemon

        return handler.prevent_change do
          handler.scene.display_message_and_wait(message)
        end
      end

      # Function called when a Pokemon has actually switched with another one
      # @param _handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(_handler, who, with)
        kill if who == @origin && !who.effects.has?(:baton_pass)
      end

      # Tell if the effect is dead
      # @return [Boolean]
      def dead?
        super || !@origin.position
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :cantswitch
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with, @origin, @move)
      end

      # Get the message text
      # @return [String]
      def message
        return parse_text_with_pokemon(19, 878, @pokemon)
      end
    end
  end
end
