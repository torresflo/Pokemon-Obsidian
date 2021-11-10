module Battle
  module Effects
    # Embargo prevents the target using any items for five turns. This includes both held items and items used by the trainer such as medicines.
    # @see https://pokemondb.net/move/embargo
    # @see https://bulbapedia.bulbagarden.net/wiki/Embargo_(move)
    # @see https://www.pokepedia.fr/Embargo
    class Embargo < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param turncount [Integer]
      def initialize(logic, pokemon, turncount = 5)
        super(logic, pokemon)
        self.counter = turncount
      end


      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :embargo
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(delete_message)
      end

      private
      
      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with, @counter)
      end

      # Message displayed when the effect prevent item usage
      # @return [String]
      def prevent_message
        parse_text_with_pokemon(19, 730, @pokemon)
      end

      # Message displayed when the effect wear off
      # @return [String]
      def delete_message
        parse_text_with_pokemon(19, 730, @pokemon)
      end
    end
  end
end