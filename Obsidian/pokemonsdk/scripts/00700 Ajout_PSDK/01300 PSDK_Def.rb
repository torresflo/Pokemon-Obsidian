class Object
  # Parse a text from the text database with specific informations and a pokemon
  # @param file_id [Integer] ID of the text file
  # @param text_id [Integer] ID of the text in the file
  # @param pokemon [PFM::Pokemon] pokemon that will introduce an offset on text_id (its name is also used)
  # @param additionnal_var [nil, Hash{String => String}] additional remplacements in the text
  # @return [String] the text parsed and ready to be displayed
  def parse_text_with_pokemon(file_id, text_id, pokemon, additionnal_var = nil)
    PFM::Text.parse_with_pokemon(file_id, text_id, pokemon, additionnal_var)
  end

  # Parse a text from the text database with 2 pokemon & specific information
  # @param file_id [Integer] ID of the text file
  # @param text_id [Integer] ID of the text in the file
  # @param pokemon1 [PFM::Pokemon] pokemon we're talking about
  # @param pokemon2 [PFM::Pokemon] pokemon who originated the "problem" (eg. bind)
  # @param additionnal_var [nil, Hash{String => String}] additional remplacements in the text
  # @return [String] the text parsed and ready to be displayed
  def parse_text_with_2pokemon(file_id, text_id, pokemon1, pokemon2, additionnal_var = nil)
    PFM::Text.parse_with_2pokemon(file_id, text_id, pokemon1, pokemon2, additionnal_var)
  end

  # Parse a text from the text database with specific informations
  # @param file_id [Integer] ID of the text file
  # @param text_id [Integer] ID of the text in the file
  # @param additionnal_var [nil, Hash{String => String}] additional remplacements in the text
  # @return [String] the text parsed and ready to be displayed
  def parse_text(file_id, text_id, additionnal_var = nil)
    PFM::Text.parse(file_id, text_id, additionnal_var)
  end

  # Get a text front the text database
  # @param file_id [Integer] ID of the text file
  # @param text_id [Integer] ID of the text in the file
  # @return [String] the text
  def text_get(file_id, text_id)
    GameData::Text.get(file_id, text_id)
  end

  # Get a list of text from the text database
  # @param file_id [Integer] ID of the text file
  # @return [Array<String>] the list of text contained in the file.
  def text_file_get(file_id)
    GameData::Text.get_file(file_id)
  end

  # Clean an array containing object responding to #name (force utf-8)
  # @param arr [Array<#name>]
  # @return [arr]
  def _clean_name_utf8(arr)
    utf8 = Encoding::UTF_8
    arr.each { |o| o&.name&.force_encoding(utf8) }
    return arr
  end

  # Get a text front the external text database
  # @param file_id [Integer] ID of the text file
  # @param text_id [Integer] ID of the text in the file
  # @return [String] the text
  def ext_text(file_id, text_id)
    GameData::Text.get_external(file_id, text_id)
  end

  # Play decision SE
  def play_decision_se
    $game_system&.se_play($data_system&.decision_se)
  end

  # Play cursor SE
  def play_cursor_se
    $game_system&.se_play($data_system&.cursor_se)
  end

  # Play buzzer SE
  def play_buzzer_se
    $game_system&.se_play($data_system&.buzzer_se)
  end

  # Play cancel SE
  def play_cancel_se
    $game_system&.se_play($data_system&.cancel_se)
  end

  # Play the Equip SE
  def play_equip_se
    $game_system&.se_play($data_system&.equip_se)
  end

  # Play the Shop SE
  def play_shop_se
    $game_system&.se_play($data_system&.shop_se)
  end

  # Play the Save SE
  def play_save_se
    $game_system&.se_play($data_system&.save_se)
  end

  # Play the Load SE
  def play_load_se
    $game_system&.se_play($data_system&.load_se)
  end

  # Play the Escape SE
  def play_escape_se
    $game_system&.se_play($data_system&.escape_se)
  end

  # Play the Actor collapse SE
  def play_actor_collapse_se
    $game_system&.se_play($data_system&.actor_collapse_se)
  end

  # Play the Enemy collapse SE
  def play_enemy_collapse_se
    $game_system&.se_play($data_system&.enemy_collapse_se)
  end
end
