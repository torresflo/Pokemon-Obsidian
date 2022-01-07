module GamePlay
  # Module defining the IO of the PartyMenu
  module PartyMenuMixin
    # Return data of the Party Menu
    # @return [Integer]
    attr_accessor :return_data
    # Return the skill process to call
    # @return [Array(Proc, PFM::Pokemon, PFM::Skill), Proc, nil]
    attr_accessor :call_skill_process

    # Tell if a Pokemon was selected
    # @return [Boolean]
    def pokemon_selected?
      return return_data >= 0
    end

    # Tell if a party was selected
    # @return [Boolean]
    def party_selected?
      return false if @mode != :select

      return $game_temp.temp_team&.any?
    end

    # Get all the selected Pokemon
    # @return [Array<PFM::Pokemon>]
    def selected_pokemons
      return [] unless party_selected?

      return $game_temp.temp_team
    end
  end
end

GamePlay.party_menu_mixin = GamePlay::PartyMenuMixin
