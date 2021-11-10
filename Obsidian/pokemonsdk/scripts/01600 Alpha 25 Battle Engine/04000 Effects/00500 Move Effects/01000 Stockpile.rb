module Battle
  module Effects
    # Stockpile raises the user's Defense and Special Defense by one stage each and charges up power for use with companion moves Spit Up or Swallow.
    # @see https://pokemondb.net/move/stockpile
    # @see https://bulbapedia.bulbagarden.net/wiki/Stockpile_(move)
    # @see https://www.pokepedia.fr/Stockage
    class Stockpile < PokemonTiedEffectBase
      # Return the amount in stockpile
      # @return [Integer]
      attr_reader :stockpile

      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      def initialize(logic, pokemon)
        super
        @stockpile = 0
        @stages_bonus = Hash.new(0)
      end

      # Is the effect increasable?
      # @return [Boolean]
      def increasable?
        return @stockpile < maximum
      end

      # Is the effect usable ?
      # @return [Boolean]
      def usable?
        return @stockpile > 0
      end

      # Increase the stockpile value with animation
      # @param amount [Integer] (default: 1)
      # @return [Boolean] if the increase proc or not
      def increase(amount = 1)
        return false unless increasable?

        @stockpile += amount
        log_data("stockpile #{@stockpile}")
        @logic.scene.display_message_and_wait(on_increase_message)
        edit_stages
        return true
      end

      # Function called when the effect is being used
      # @return [Boolean] if the effect has been used or not
      def use
        return false unless usable?

        restore_stages
        @logic.scene.display_message_and_wait(on_clear_message)
        kill
        return true
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :stockpile
      end

      # Maximum stockpile
      # @return [Integer]
      def maximum
        3
      end

      private

      # Apply the change of the stat changes
      def edit_stages
        old_dfe_stage, old_dfs_stage = @pokemon.dfe_stage, @pokemon.dfs_stage
        @logic.stat_change_handler.stat_change_with_process(:dfe, 1, @pokemon)
        @logic.stat_change_handler.stat_change_with_process(:dfs, 1, @pokemon)
        @stages_bonus[:dfe] += @pokemon.dfe_stage - old_dfe_stage
        @stages_bonus[:dfs] += @pokemon.dfs_stage - old_dfs_stage
        log_data("stockpile # increase stages <dfe:#{@pokemon.dfe_stage}(+#{@stages_bonus[:dfe]}), dfs:#{@pokemon.dfs_stage}(+#{@stages_bonus[:dfs]})>")
      end

      # Reset the effect of stockpile on stat stage
      def restore_stages
        @logic.stat_change_handler.stat_change_with_process(:dfe, -@stages_bonus[:dfe], @pokemon)
        @logic.stat_change_handler.stat_change_with_process(:dfs, -@stages_bonus[:dfs], @pokemon)
        log_data("stockpile # restore stages <dfe:#{@pokemon.dfe_stage}, dfs:#{@pokemon.dfs_stage}>")
      end

      # Message displayed after a pokemon stockpile
      # @return [String]
      def on_increase_message
        parse_text_with_pokemon(19, 721, @pokemon, PFM::Text::NUMB[2] => @stockpile.to_s)
      end

      # Message displayed when the stockpile is being cleared
      # @return [String]
      def on_clear_message
        parse_text_with_pokemon(19, 724, @pokemon)
      end
    end
  end
end
