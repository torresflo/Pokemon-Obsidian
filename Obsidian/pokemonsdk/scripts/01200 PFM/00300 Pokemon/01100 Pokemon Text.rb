module PFM
  class Pokemon
    # Return the Pokemon name in the Pokedex
    # @return [String]
    def name
      return GameData::Text.get(0,@step_remaining==0 ? @id : 0)
    end

    # Return the Pokemon name upcase in the Pokedex
    # @return [String]
    def name_upper
      return GameData::Text.get(0,@step_remaining==0 ? @id : 0).upcase
    end

    # Return the given name of the Pokemon (Pokedex name if no given name)
    # @return [String]
    def given_name
      return @given_name || name
    end
    alias nickname given_name

    # Give a new name to the Pokemon
    # @param nickname [String] the new name of the Pokemon
    def given_name=(nickname)
      @given_name = nickname
      @given_name = nil if nickname == name
    end
    alias nickname= given_name=

    # Convert the Pokemon to a string (battle debug)
    # @return [String]
    def to_s
      return "<P:#{self.given_name}_#{@code.to_s(36)}_#{@position}>"
    end

    # Return the text of the nature
    # @return [String]
    def nature_text
      return text_get(8, nature.first)
    end

    # Return the name of the zone where the Pokemon has been caught
    # @return [String]
    def captured_zone_name
      zone_name = _utf8(GameData::Zone.get(zone_id).map_name.to_s)
      return PFM::Text.parse_string_for_messages(zone_name)
    end

    # Return the name of the zone where the egg has been obtained
    # @return [String]
    def egg_zone_name
      zone_name = _utf8(GameData::Zone.get(zone_id(@egg_in)).map_name.to_s)
      return PFM::Text.parse_string_for_messages(zone_name)
    end

    # Return the name of the item the Pokemon is holding
    # @return [String]
    def item_name
      return GameData::Item[item_db_symbol].name
    end

    # Return the name of the current ability of the Pokemon
    # @return [String]
    def ability_name
      return GameData::Abilities.name(ability_db_symbol)
    end

    # Reture the description of the current ability of the Pokemon
    # @return [String]
    def ability_descr
      return GameData::Abilities.descr(ability_db_symbol)
    end

    # Return the normalized text trainer id of the Pokemon
    # @return [String]
    def trainer_id_text
      return sprintf("%05d", self.trainer_id)
    end

    # Returns the level text
    # @return [String]
    def level_text
      @level.to_s
    end
    # Return the level text (to_pokemon_number)
    # @return [String]
    def level_pokemon_number
      @level.to_s.to_pokemon_number
    end

    # Return the level text with "Level: " inside
    # @return [String]
    def level_text2
      "#{text_get(27, 29)}#@level"
    end

    # Returns the HP text
    # @return [String]
    def hp_text
      "#@hp / #{self.max_hp}"
    end

    # Returns the HP text (to_pokemon_number)
    # @return [String]
    def hp_pokemon_number
      "#@hp / #{self.max_hp}".to_pokemon_number
    end

    # Return the text of the Pokemon ID
    # @return [String]
    def id_text
      sprintf("%03d", $pokedex.national? ? @id : primary_data.id_bis)
    end

    # Return the text of the Pokemon ID with N°
    # @return [String]
    def id_text2
      sprintf("N°%03d", $pokedex.national? ? @id : primary_data.id_bis)
    end

    # Return the text of the Pokemon ID to pokemon number
    # @return [String]
    def id_text3
      sprintf("%03d", $pokedex.national? ? @id : primary_data.id_bis).to_pokemon_number
    end
  end
end
