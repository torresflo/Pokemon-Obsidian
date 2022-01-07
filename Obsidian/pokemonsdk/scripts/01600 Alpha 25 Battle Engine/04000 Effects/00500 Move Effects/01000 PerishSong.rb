module Battle
  module Effects
    # Effect used by Perish Song move
    class PerishSong < EffectBase
      def origin
        return nil # @todo delete this line when Rey fixed the problem
      end

      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      # @param pokemon [PFM::PokemonBattler] target that will be affected by the effect
      # @param countdown [Integer] number of turn before the effect proc (including the current one)
      def initialize(logic, pokemon, countdown)
        super(logic)
        @pokemon = pokemon
        self.counter = countdown
      end

      # If the effect can proc
      # @return [Boolean]
      def triggered?
        return @counter == 1
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :perish_song
      end

      # Function called at the end of a turn
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene] battle scene
      # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
      def on_end_turn_event(logic, scene, battlers)
        return if @pokemon.dead?

        scene.display_message_and_wait(parse_text_with_pokemon(19, 863, @pokemon, { PFM::Text::NUMB[2] => (@counter - 1).to_s }))
        logic.damage_handler.damage_change(@pokemon.max_hp, @pokemon) if triggered?
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with, @counter)
      end
    end
  end
end
