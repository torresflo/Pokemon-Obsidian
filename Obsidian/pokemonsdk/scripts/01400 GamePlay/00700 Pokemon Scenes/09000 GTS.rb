################################################################################
#
# GTS System                  Version 3.0.0 RELEASE-PSDK
# By Hansiec, Manoel Afonso, A Dork of Pork and Nuri Yuri
#
# CHANGE LOG FOR THIS VERSION:
# - Adaptation of the original script to work on PSDK
# - Use HTTPS protocol to communicate with the GTS server
# - Set to work with GTS Online Panel by Hills Tech
# - Performance improvement
# - Some minor bugs fixed
#
# Special Thanks to Saving Raven for providing graphics and testing
# CREDITS REQUIRED
#
################################################################################
#
# NOTICE: If a bug occurs, please state the message of the bug.
#
# Installation:
#   * Create a new code session above Main and paste this script there;
#   * Go to http://gts.hillstech.co and create a user account;
#   * Go to the 'new game' tab on the site and create a new game;
#   * Get the game ID that was generated on the site and paste it
#     into the GAMEID variable in this script;
#   * Done.
#
# How To Use:
#   * Install
#   * Call 'GTS.open'
#   * Report if any bugs uccor
#
# Settings:
#   * URL - The url link of the online panel, don't change this.
#   * SPECIES_SHOWN - Set to 'All', 'Owned', or 'Seen' - this sets the available
#       species you can search for.
#   * SORT_MODE - Set to 'Alphabetical' or 'Regional' - How species are arranged
#       during species finding.
#   * GAME_CODE - A special Game Code, if you happen to trade with a game with
#       a different game code, the found map would be 'Faraway Place'.
#   * GAME_ID - The ID of your game in the Pannel
#   * BLACK_LIST - A list of Pokémon ID or db_symbol that aren't allowed to be
#       searched
#
################################################################################

# require 'net/http'
# ENV['SSL_CERT_FILE'] = './lib/cert.pem'

module GTS
  module Settings
    # ID of the game, replace 0 by what you got on the pannel
    GAMEID = 161
    # URL of the GTS server
    URL = 'https://gts.hillstech.co/api.php?i='
    # Condition to see the Pokemon in the search result (All/Seen/Owned)
    SPECIES_SHOWN = 'All'
    # How the Pokemon are searched (Alphabetical/Regional)
    SORT_MODE = 'Alphabetical'
    # List of black listed Pokemon (filtered out of the search) put ID or db_symbol here
    BLACK_LIST = []
    # Internal Game Code to know if the Pokemon comes from this game or another (like DPP <-> HGSS)
    GAME_CODE = '255'
    # Scene BGM (Complete path in lower case without extname)
    BGM = 'audio/bgm/xy_gts'
  end

  module_function

  # Main Method
  def open
    Core.update_uri
    loading_viewport = Viewport.create(:main, 10_001)
    @loading_screen = LoadingScreen.new(loading_viewport)
    Audio.bgm_play(Settings::BGM) unless Settings::BGM.empty?
    Scene.new.main
    loading_viewport.dispose
    @loading_screen = nil
    $game_system.bgm_play($game_system.playing_bgm)
    Graphics.transition
  end

  # Return the loading screen
  # @return [LoadingScreen]
  def loading_screen
    @loading_screen
  end

  # Finishes the GTS trade
  # @param my_pokemon [PFM::Pokemon] the player's Pokemon
  # @param new_poke [PFM::Pokemon] the traded Pokemon
  # @param choice [Integer, nil] the choice made in the Box in order to correctly remove the Pokemon
  # @param searching [Boolean] if the Pokemon was got from searching (implying choice to be Integer)
  # @param id [Integer] online ID
  def finish_trade(my_pokemon, new_poke, searching, choice = nil, id = nil)
    $pokedex.mark_seen(new_poke.id, new_poke.form)
    $pokedex.mark_captured(new_poke.id)
=begin TODO
    pbFadeOutInWithMusic(99999){
      evo = PokemonTradeScene.new
      evo.pbStartScreen(my_pokemon, new_poke, $Trainer.name, new_poke.ot)
      evo.pbTrade
      evo.pbEndScreen
    }
=end
    elv_id, elv_form = new_poke.evolve_check(:trade, my_pokemon)
    $scene.call_scene(GamePlay::Evolve, new_poke, elv_id, elv_form, true) if elv_id

    if !new_poke.game_code || new_poke.game_code != Settings::GAME_CODE
      new_poke.flags = 0x00E9_0000 # 9 = base2 : 1,0,0,1 = ?, !FromThisGame, !CapturedByPlayer, FromPresentTime
    else
      new_poke.flags = 0x00ED_0000 # D = base2 : 1,1,0,1 = ?, FromThisGame, !CapturedByPlayer, FromPresentTime
    end

    return finish_trade_from_searching(my_pokemon, new_poke, choice, id) if searching

    GamePlay::Save.save
    return Core.delete_pokemon(false)
  end

  # Finishes the GTS trade (delete pokemon from data & insert traded Pokemon in party)
  # @param my_pokemon [PFM::Pokemon] the player's Pokemon
  # @param new_poke [PFM::Pokemon] the traded Pokemon
  # @param choice [Integer, nil] the choice made in the Box in order to correctly remove the Pokemon
  # @param id [Integer] online ID
  def finish_trade_from_searching(my_pokemon, new_poke, choice, id)
    if Core.take_pokemon(id) && Core.upload_new_pokemon(id, my_pokemon)
      choice >= 31 ? $pokemon_party.remove_pokemon(choice - 31) : $storage.remove(choice - 1)
      $pokemon_party.add_pokemon(new_poke)
      GamePlay::Save.save
      return true
    end
    return false
  end

  ##### Brings up all species of pokemon of the given index of the given sort mode
  def order_species(index)
    commands = [ext_text(8997, 2)]

    # Retreive the list of Pokemon we can see
    species_list = species_list_from_criteria

    if Settings::SORT_MODE == 'Alphabetical'
      letter = index.is_a?(String) ? index : (0x40 + index).chr # index >= 1, A = 0x41
      # Select the Pokemon that start with the right letter
      species_list.select! { |i| GameData::Pokemon[i].name.start_with?(letter) }
    elsif Settings::SORT_MODE == 'Regional'
      # /!\ PSDK has no multi-regional Dex
      real_index = index == 1 && $pokedex.national? ? -1 : 0
      if real_index != -1
        # Reject non-national Pokemon
        species_list.reject! { |i| GameData::Pokemon[i].id_bis == 0 }
        # Sort Pokemon by their Regional ID
        species_list.sort! { |a, b| GameData::Pokemon[a].id_bis <=> GameData::Pokemon[b].id_bis }
      end
    end

    to_id = proc { |i| $pokedex.national? ? i : GameData::Pokemon[i].id_bis }

    commands.concat(species_list.collect { |i| format('%03d : %0s', to_id.call(i), GameData::Pokemon[i].name) })
    if commands.size <= 1
      $scene.display_message(ext_text(8997, 0))
      return 0
    end

    c = $scene.display_message(ext_text(8997, 1), 1, *commands)
    return c == 0 ? 0 : species_list[c - 1]
  end

  # Return the specie list filtered with the criteria (seen, got, black_list)
  # @return [Array<Integer>]
  def species_list_from_criteria
    show_seen = Settings::SPECIES_SHOWN == 'Seen'
    show_captured = Settings::SPECIES_SHOWN == 'Owned'
    return (1..GameData::Pokemon::LAST_ID).select do |i|
      next(false) if show_seen && !$pokedex.has_seen?(i)
      next(false) if show_captured && !$pokedex.has_captured?(i)
      next(false) if Settings::BLACK_LIST.include?(i) || Settings::BLACK_LIST.include?(GameData::Pokemon.db_symbol(i))

      next(true)
    end
  end

  def genders
    return %w[Either Male Female]
  end

  ################################################################################
  # GTS Scenes
  # By A Dork of Pork, Rewritten by Nuri Yuri
  # Scenes For GTS
  ################################################################################

  # GTS Button, A Basic options button for our GTS System
  class Button < UI::SpriteStack
    def initialize(viewport, x, y, name = '')
      super(viewport, x, y)
      bmp = push(0, 0, 'GTS/Options_bar').bitmap
      add_text(0, 1, bmp.width, 16, name, 1)
      self.x -= bmp.width / 2
    end

    def width
      @stack.first.width
    end
  end

  # GTS Search Method Selection
  class SearchMethod < GamePlay::BaseCleanUpdate
    # Create the new SearchMethod object
    def initialize
      super
      @index = 0
      @max_index = 3
    end

    # Update the inputs
    def update_inputs
      if index_changed(:@index, :UP, :DOWN, @max_index)
        update_selector
      elsif Input.trigger?(:B)
        $game_system.se_play($data_system.cancel_se)
        @running = false
      elsif Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        do_command
      else
        return true
      end
      return false
    end

    private

    # Update the sprites
    def update_graphics
      @sprites.update
    end

    # Update the selector position
    def update_selector
      x = (sprite = @sprites.stack[@sprites_base_index + @index]).x
      y = sprite.y
      @selection_l.x = x - 1
      @selection_l.y = y - 1
      @selection_r.x = x - 9 + sprite.width
      @selection_r.y = y - 1
    end

    # Create all the sprites
    def create_graphics
      create_viewport
      create_spriteset_and_background
      create_action_sprites(@viewport.rect.width / 2)
      create_selection
    end

    # Create the Spriteset and the Background with the right scene_name
    # @param scene_name [String] name of the scene shown on screen
    def create_spriteset_and_background(scene_name = ext_text(8997, 3))
      @sprites = UI::SpriteStack.new(@viewport)
      @background = @sprites.push(0, 0, 'GTS/Background')
      @sprites.add_text(25, 3, 0, 16, scene_name, color: 9)
      @sprites.add_text(300, 3, 0, 16, "Online ID: #{$pokemon_party.online_id}", 2, color: 9)
      @sprites_base_index = @sprites.stack.size
    end

    # Create the actions sprites
    # @param width2 [Integer] half of the view width
    def create_action_sprites(width2)
      @sprites.push_sprite(Button.new(@viewport, width2, 75, ext_text(8997, 4)))
      @sprites.push_sprite(Button.new(@viewport, width2, 105, ext_text(8997, 5)))
      @sprites.push_sprite(Button.new(@viewport, width2, 135, ext_text(8997, 6)))
      @sprites.push_sprite(Button.new(@viewport, width2, 165, ext_text(8997, 7)))
    end

    # Create the selectors
    def create_selection
      x = (sprite = @sprites.stack[@sprites_base_index + @index]).x
      y = sprite.y

      @selection_l = @sprites.push_sprite(UI::SpriteStack.new(@viewport, x - 1, y - 1))
      @selection_l.push(0, 0, 'GTS/Select', rect: [0, 0, 8, 8])
      @selection_l.push(0, 11, 'GTS/Select', rect: [0, 8, 8, 8])

      @selection_r = @sprites.push_sprite(UI::SpriteStack.new(@viewport, x - 9 + sprite.width, y - 1))
      @selection_r.push(0, 0, 'GTS/Select', rect: [8, 0, 8, 8])
      @selection_r.push(0, 11, 'GTS/Select', rect: [8, 8, 8, 8])
    end

    # Execute the actions according to the index
    def do_command
      if @index == 0
        do_command0
      elsif @index == 1
        do_command1
      elsif @index == 2
        do_command2
      else
        @running = false
      end
    end

    # Ask the player to select a Pokemon in the given list
    # @param pokemon_list [Array<PFM::Pokemon>]
    # @return [Integer, false]
    def select_pokemon(pokemon_list)
      index = false
      call_scene(SummarySelect, pokemon_list) { |scene| index = scene.return_data }
      return index
    end

    # Ask the player to confirm if he wants to take the given wanted_data
    # @param wanted_data [Array<Integer>]
    # @return [Boolean]
    def confirm_wanted_data(wanted_data)
      takes = false
      call_scene(SummaryWanted, wanted_data) { |scene| takes = scene.return_data }
      return takes
    end

    # Ask the player to choose a Pokemon in the storage
    # @return [Integer, nil]
    def choose_pokemon
      choice = nil
      call_scene(GamePlay::StorageTrade) { |scene| choice = scene.return_data }
      return choice
    end

    # Search by player's requirements
    def do_command0
      data = nil
      call_scene(WantedDataScene) { |scene| data = scene.wanted_data }
      return unless data.is_a?(Array)

      list = Core.get_pokemon_list(data)
      return display_message(ext_text(8997, 8)) if list.first == 'nothing'

      pokemon_list = list.collect { |i| Core.download_pokemon(i).to_pokemon }
      return display_message(ext_text(8997, 9)) if pokemon_list.include?(nil)

      loop do
        break unless (index = select_pokemon(pokemon_list))

        wanted_data = Core.download_wanted_data(list[index])
        return display_message(ext_text(8997, 11)) if wanted_data.empty?
        next unless confirm_wanted_data(wanted_data)
        break unless (choice = choose_pokemon)

        pkmn = choice >= 31 ? $actors[choice - 31] : $storage.info(choice - 1)
        next display_message(ext_text(8997, 12)) unless pokemon_matching_requirements?(pkmn, wanted_data)

        return GTS.finish_trade(pkmn, pokemon_list[index], true, choice, list[index])
      end
    end

    # Search using a Pokemon that could meet the requirement
    def do_command1
      display_message_and_wait(ext_text(8997, 13))
      return unless (choice = choose_pokemon)
      return unless (pkmn = choice >= 31 ? $actors[choice - 31] : $storage.info(choice - 1))

      list = Core.get_pokemon_list_from_wanted(pkmn)
      return display_message(ext_text(8997, 8)) if list.first == 'nothing'

      pokemon_list = list.collect { |i| Core.download_pokemon(i).to_pokemon }
      return display_message(ext_text(8997, 9)) if pokemon_list.include?(nil)

      loop do
        break unless (index = select_pokemon(pokemon_list))

        wanted_data = Core.download_wanted_data(list[index])
        return display_message(ext_text(8997, 11)) if wanted_data.empty?

        display_message_and_wait(ext_text(8997, 14))
        break unless confirm_wanted_data(wanted_data)

        return GTS.finish_trade(pkmn, pokemon_list[index], true, choice, list[index])
      end
    end

    # Search using the online ID of the trainer
    def do_command2
      id = nil # Local variable needs to exists outside of the block in Ruby 2.x
      loop do
        $game_temp.num_input_start = 0
        $game_temp.num_input_variable_id = Yuki::Var::TMP1
        $game_temp.num_input_digits_max = 8
        display_message_and_wait(ext_text(8997, 15))
        id = $game_variables[Yuki::Var::TMP1]
        return if id < 1
        break if id != $pokemon_party.online_id

        display_message(ext_text(8997, 16))
      end
      unless Core.pokemon_uploaded?(id)
        display_message(ext_text(8997, 17))
        return
      end
      gpkmn = Core.download_pokemon(id).to_pokemon
      pokemon_list = [] << gpkmn
      return display_message(ext_text(8997, 10)) unless gpkmn

      wanted_data = Core.download_wanted_data(id)
      return display_message(ext_text(8997, 11)) if wanted_data.empty?
      return unless select_pokemon(pokemon_list)
      return unless confirm_wanted_data(wanted_data)
      return unless (choice = choose_pokemon)

      pkmn = choice >= 31 ? $actors[choice - 31] : $storage.info(choice - 1)
      return display_message(ext_text(8997, 12)) unless pokemon_matching_requirements?(pkmn, wanted_data)

      return GTS.finish_trade(pkmn, gpkmn, true, choice, id)
    end

    # Test if the Pokemon match the requirement
    # @param pkmn [PFM::Pokemon] pokemon
    # @param wanted_data [Array<Integer>] requirements
    def pokemon_matching_requirements?(pkmn, wanted_data)
      return pkmn.id == wanted_data[0] && pkmn.level >= wanted_data[1] &&
             pkmn.level <= wanted_data[2] && (wanted_data[3] == 0 || pkmn.gender == wanted_data[3])
    end
  end

  # GTS Wanted Data, shows a screen on which you can create wanted data
  class WantedDataScene < SearchMethod
    # @return [Array, -1] the choosen wanted data
    attr_reader :wanted_data
    # Create a new WantedDataScene
    def initialize
      @wanted_data = [-1, 1, 100, 0]
      super
      @max_index = 4
    end

    # Update the inputs
    def update_inputs
      if index_changed(:@index, :UP, :DOWN, @max_index)
        update_selector
      elsif Input.trigger?(:B)
        $game_system.se_play($data_system.cancel_se)
        @wanted_data = -1
        @running = false
      elsif Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        do_command
      end
    end

    private

    # Create all the sprites
    def create_graphics
      super
      draw_wanted_data
    end

    def draw_wanted_data
      @texts[0].text = @wanted_data[0] > 0 ? GameData::Pokemon[@wanted_data[0]].name : '????'
      @texts[1].text = GTS.genders[@wanted_data[3]]
      @texts[2].text = format(ext_text(8997, 18), min: @wanted_data[1], max: @wanted_data[2])
    end

    # Create the Spriteset and the Background with the right scene_name
    def create_spriteset_and_background
      super(ext_text(8997, 19))
    end

    # Create the actions sprites
    # @param width2 [Integer] half of the view width
    def create_action_sprites(width2)
      add_text_args = []

      sp = @sprites.push(width2, 25, 'GTS/Pokemon_bar')
      sp.x -= sp.width / 2
      add_text_args << [sp.x + sp.width / 2 - 2, sp.y + 1, 0, 16, ext_text(8997, 20), 2]
      sp = @sprites.push(width2, 55, 'GTS/Gender_bar')
      sp.x -= sp.width / 2
      add_text_args << [sp.x + sp.width / 2 - 2, sp.y + 1, 0, 16, ext_text(8997, 21), 2]
      sp = @sprites.push(width2, 85, 'GTS/Level_bar')
      sp.x -= sp.width / 2
      add_text_args << [sp.x + sp.width / 2 - 2, sp.y + 1, 0, 16, ext_text(8997, 22), 2]
      sp = @sprites.push(width2, 115, 'GTS/Search_bar')
      sp.x -= sp.width / 2
      add_text_args << [sp.x, sp.y + 1, sp.width, 16, ext_text(8997, 23), 1]
      @sprites.push_sprite(Button.new(@viewport, width2, 145, ext_text(8997, 24)))

      add_text_args.each { |args| @sprites.add_text(*args) }

      @texts = Array.new(3) do |i|
        @sprites.add_text(add_text_args[i][0] + 8 + (i == 0 ? 10 : 0), add_text_args[i][1], 0, 16, '')
      end
    end

    # Execute the actions according to the index
    def do_command
      if @index == 0
        do_command0
      elsif @index == 1
        @wanted_data[3] = display_message(ext_text(8997, 25), 1, *GTS.genders)
      elsif @index == 2
        do_command2
      elsif @index == 3
        if @wanted_data[0] > 0
          @running = false
        else
          $game_system.se_play($data_system.cancel_se)
        end
      elsif @index == 4
        @wanted_data = -1
        return @running = false
      end
      draw_wanted_data
    end

    def do_command0
      commands2 = [ext_text(8997, 2)]
      if Settings::SORT_MODE == 'Alphabetical'
        commands2.concat(('A'..'Z').to_a)
        msg = ext_text(8997, 26)
        c2 = display_message(msg, 1, *commands2)
      elsif Settings::SORT_MODE == 'Regional'
        c2 = 1
      end
      if c2 > 0
        s = GTS.order_species(commands2[c2])
        @wanted_data[0] = s if s > 0
      end
    end

    undef do_command1

    # Ask the level requirements
    def do_command2
      $game_temp.num_input_start = GameData::MAX_LEVEL
      $game_temp.num_input_variable_id = Yuki::Var::TMP1
      $game_temp.num_input_digits_max = 3
      display_message(ext_text(8997, 27))
      @wanted_data[1] = $game_variables[Yuki::Var::TMP1] if $game_variables[Yuki::Var::TMP1] > 0
      $game_temp.num_input_start = GameData::MAX_LEVEL
      $game_temp.num_input_variable_id = Yuki::Var::TMP1
      $game_temp.num_input_digits_max = 3
      display_message(ext_text(8997, 28))
      @wanted_data[2] = $game_variables[Yuki::Var::TMP1] if $game_variables[Yuki::Var::TMP1] >= @wanted_data[1]
    end
  end

  # Scene GTS Main GTS Functionality here.
  class Scene < SearchMethod
    def initialize
      @uploaded = Core.pokemon_uploaded?
      super
      @max_index = 2
    end

    private

    # Create the Spriteset and the Background with the right scene_name
    def create_spriteset_and_background
      super('GTS')
    end

    # Create the actions sprites
    # @param width2 [Integer] half of the view width
    def create_action_sprites(width2)
      @sprites.push_sprite(Button.new(@viewport, width2, 50, ext_text(8997, 29)))
      @poke_action = @sprites.push_sprite(Button.new(@viewport, width2, 100, @uploaded ? ext_text(8997, 30) : ext_text(8997, 31)))
      @sprites.push_sprite(Button.new(@viewport, width2, 150, ext_text(8997, 7)))
    end

    def refresh_sprites
      @uploaded = Core.pokemon_uploaded?
      @poke_action.stack.last.text = @uploaded ? ext_text(8997, 30) : ext_text(8997, 31)
    end

    # Execute the actions according to the index
    def do_command
      if @index == 0
        call_scene(SearchMethod)
      elsif @index == 1
        do_command1
      elsif display_message(ext_text(8997, 32), 2, ext_text(8997, 33), ext_text(8997, 34)) == 0
        $game_system.se_play($data_system.cancel_se)
        @running = false
      end
    end

    undef do_command0

    # Perform the action related to the Pokemon on the GTS
    def do_command1
      if @uploaded
        summary
        refresh_sprites
      else
        return false unless (choice = choose_pokemon)

        party = choice >= 31
        pkmn = party ? $actors[choice - 31] : $storage.info(choice - 1)
        if party && $pokemon_party.pokemon_alive == 1 && !pkmn.dead?
          display_message(ext_text(8997, 35))
          return
        end
        data = nil
        call_scene(WantedDataScene) { |scene| data = scene.wanted_data }
        if data.is_a?(Array) && Core.upload_pokemon(pkmn, data)
          $pokemon_party.online_pokemon = pkmn.clone
          party ? $pokemon_party.remove_pokemon(choice - 31) : $storage.remove(choice - 1)
          GamePlay::Save.save
          refresh_sprites
        end
      end
    end

    undef do_command2

    # Brings up a summary of your uploaded pokemon (also allows you to delete it)
    def summary
      if Core.pokemon_taken?
        new_poke = Core.download_pokemon($pokemon_party.online_id).to_pokemon
        return display_message(ext_text(8997, 10)) unless new_poke

        if GTS.finish_trade($pokemon_party.online_pokemon, new_poke, false)
          $pokemon_party.add_pokemon(new_poke)
          $pokemon_party.online_pokemon = nil
          GamePlay::Save.save
        end
        return
      end
      call_scene(GamePlay::Summary, $pokemon_party.online_pokemon)
      if display_message(ext_text(8997, 36), 2, ext_text(8997, 33), ext_text(8997, 34)) == 0
        if display_message(ext_text(8997, 37), 2, ext_text(8997, 33), ext_text(8997, 34)) == 0
          if Core.delete_pokemon
            $pokemon_party.add_pokemon($pokemon_party.online_pokemon)
            $pokemon_party.online_pokemon = nil
            GamePlay::Save.save
            display_message(ext_text(8997, 38))
          end
        end
      end
    end
  end

  ################################################################################
  # GTS Summary Scenes
  # Written by Nuri Yuri
  # Summary Modifications for GTS
  ################################################################################

  # Selection of a Pokemon in a List
  class SummarySelect < GamePlay::Summary
    # @return [Integer, false] Index of the Pokemon the player wants in the list
    attr_accessor :return_data
    # Create a new SummarySelect
    def initialize(list)
      super(list.first, :view, list)
    end

    # Overload the update inputs to ask if the player wants the current Pokemon
    def update_inputs
      if Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        if display_message(ext_text(8997, 39), 1, ext_text(8997, 33), ext_text(8997, 34)) == 0
          @return_data = @party_index
          @running = false
        end
      elsif Input.trigger?(:B)
        mouse_quit
      else
        super
      end
    end

    # Overload the mouse_quit to ask if the player really wants to quit (without choosing)
    def mouse_quit
      $game_system.se_play($data_system.cancel_se)
      if display_message(ext_text(8997, 40), 1, ext_text(8997, 33), ext_text(8997, 34)) == 0
        @return_data = false
        @running = false
      end
    end
  end

  # Show a Pokemon with its requirement in order to trade
  class SummaryWanted < GamePlay::Summary
    attr_accessor :return_data
    def initialize(wanted_data)
      super(PFM::Pokemon.new(wanted_data[0], wanted_data[1]))
      @wanted_data = wanted_data
    end

    # Force the button to disabled unless it's the cancel one
    def ctrl_id_state
      return 3
    end

    # Ask if the player wants to accept this trade
    def update_inputs
      if Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        if display_message(ext_text(8997, 41), 1, ext_text(8997, 33), ext_text(8997, 34)) == 0
          @return_data = true
          @running = false
        end
      elsif Input.trigger?(:B)
        mouse_quit
      end
    end

    # Ask if the player wants to decline
    def mouse_quit
      $game_system.se_play($data_system.cancel_se)
      if display_message(ext_text(8997, 42), 1, ext_text(8997, 33), ext_text(8997, 34)) == 0
        @return_data = false
        @running = false
      end
    end

    def create_graphics
      super
      draw_page_one_gts_wanted(@wanted_data)
    end

    # Create the various UI
    def create_uis
      @uis = [
        Summary_Memo_GTS.new(@viewport),
        UI::Summary_Stat.new(@viewport),
        UI::Summary_Skills.new(@viewport)
      ]
    end

    # Draw the wanted info
    def draw_page_one_gts_wanted(wanted_data)
      @win_text = UI::SpriteStack.new(@viewport)
      @win_text.push(0, 217, 'team/Win_Txt')
      @win_text.add_text(2, 220, 238, 15, ext_text(8997, 43), color: 9)

      data = {
        id: wanted_data[0], name: GameData::Pokemon[wanted_data[0]].name,
        from: wanted_data[1], to: wanted_data[2],
        sexe: GTS.genders[wanted_data[3]]
      }
      @uis[0].text_info.text = format(ext_text(8997, 44), data)
    end
  end

  # Child of the Memo that doesn't write the text_info itself
  class Summary_Memo_GTS < UI::Summary_Memo
    attr_reader :text_info
    def load_text_info(pokemon) end
  end

  ################################################################################
  # GTS Core
  # By A Dork of Pork, Rewritten by Nuri Yuri
  # Core GTS functions (Basically this is what you need to make a complete GTS
  # system)
  ################################################################################

  module Core
    # URI to the GTS server
    @uri = URI(Settings::URL + Settings::GAMEID.to_s)
    # Locking mutex
    LOCK = Mutex.new

    module_function

    # Update the URI
    def update_uri
      @uri = URI(Settings::URL + Settings::GAMEID.to_s)
    end

    # Tests connection to the server (not used anymore but kept for possible use)
    def test_connection
      x = execute('test')
      return !x.empty?
    rescue StandardError
      return false
    end

    # Our main execution method, since I'm too lazy to write Settings::URL a lot
    def execute(action, data = {})
      data[:action] = action
      result = nil
      Thread.new do
        LOCK.synchronize do
          Thread.main.wakeup
          result = Net::HTTP.post_form(@uri, data).body
          Thread.main.wakeup
        end
      end
      sleep unless LOCK.locked? || result
      GTS.loading_screen&.process
      Graphics.update while LOCK.locked? # Security
      return result
    end

    # gets a new online ID from the server
    def obtain_online_id
      r = execute('getOnlineID')
      return r.to_i
    end

    # registers our new online ID to the server
    def register_online_id(id)
      r = execute('setOnlineID', id: id)
      ret = r == 'success'
      log_error(r) unless ret
      return ret
    end

    # checks whether you have a pokemon uploaded in the server
    def pokemon_uploaded?(id = $pokemon_party.online_id)
      r = execute('hasPokemonUploaded', id: id)
      log_error(r) unless r == 'yes' || r == 'no'
      return r == 'yes'
    end

    # sets the pokemon with the given online ID to taken
    def take_pokemon(id)
      r = execute('setTaken', id: id)
      ret = r == 'success'
      log_error(r) unless ret
      return ret
    end

    # checks wether the pokemon with the give online ID is taken
    def pokemon_taken?(id = $pokemon_party.online_id)
      r = execute('isTaken', id: id)
      log_error(r) unless r == 'yes' || r == 'no'
      return r == 'yes'
    end

    # uploads a pokemon to the server
    def upload_pokemon(pokemon, *wanted_data)
      wanted_data = wanted_data[0] if wanted_data[0].is_a?(Array)
      pokemon.game_code = Settings::GAME_CODE
      data = {
        id: $pokemon_party.online_id, pokemon: pokemon.encode, species: pokemon.id, level: pokemon.level,
        gender: pokemon.gender, Wspecies: wanted_data[0], WlevelMin: wanted_data[1],
        WlevelMax: wanted_data[2], Wgender: translate_gender(wanted_data[3])
      }
      r = execute('uploadPokemon', data)
      ret = r == 'success'
      log_error(r) unless ret
      return ret
    end

    # uploads the newly traded pokemon to the given online ID to the server
    def upload_new_pokemon(id, pokemon)
      pokemon.game_code = Settings::GAME_CODE
      r = execute('uploadNewPokemon', id: id, pokemon: pokemon.encode)
      ret = r == 'success'
      log_error(r) unless ret
      return ret
    end

    # downloads a pokemon string with the given online ID
    def download_pokemon(id)
      r = execute('downloadPokemon', id: id)
      log_error('Empty response') if r.empty?
      return r.empty? ? false : r
    end

    # downloads the wanted data with the given online ID
    def download_wanted_data(id)
      r = execute('downloadWantedData', id: id)
      log_error('Empty response') if r.empty?
      return [] if r.empty?

      r = r.split(',').collect(&:to_i)
      r[3] = 0 if r[3] < 0
      return r
    end

    # deletes your current pokemon from the server
    def delete_pokemon(withdraw = true, party = $pokemon_party)
      r = execute('deletePokemon', id: party.online_id, withdraw: withdraw ? 'y' : 'n')
      ret = r == 'success'
      log_error(r) unless ret
      return ret
    end

    # gets a list of online IDs where the wanted data match up
    def get_pokemon_list(*wanted_data)
      wanted_data = wanted_data[0] if wanted_data[0].is_a?(Array)
      r = execute('getPokemonList',
                  id: $pokemon_party.online_id, species: wanted_data[0], levelMin: wanted_data[1],
                  levelMax: wanted_data[2], gender: translate_gender(wanted_data[3]))
      return [r] if r == 'nothing'
      return r.split('/,,,/') if r.include?('/,,,/')

      return r.split(',')
    end

    # Reverse Lookup pokemon
    def get_pokemon_list_from_wanted(pokemon)
      r = execute('getPokemonListFromWanted',
                  id: $pokemon_party.online_id, species: pokemon.id, level: pokemon.level,
                  gender: translate_gender(pokemon.gender))
      return [r] if r == 'nothing'
      return r.split('/,,,/') if r.include?('/,,,/')

      return r.split(',')
    end

    # installs the MYSQL tables in the server
    def install
      return execute('createTables')
    end

    # Translate the wanted gender field for the server
    def translate_gender(wanted)
      return -1 if wanted == 0

      return wanted
    end
  end

  # Class showing the loading during server requests
  class LoadingScreen < UI::SpriteStack
    # Create a new LoadingScreen
    # @param viewport [Viewport] viewport used by the loading screen
    def initialize(viewport)
      super(viewport)
      @texts = [
        ext_text(8997, 45),
        ext_text(8997, 46),
        ext_text(8997, 47)
      ]
      @text = add_text(2, @viewport.rect.height - 16, 0, 16, @texts.first, color: 2)
      @viewport.visible = false
    end

    # Blocking method that makes the "LoadingScreen" process it's loading display
    def process
      @viewport.visible = true
      while Core::LOCK.locked?
        Graphics.update
        @text.text = @texts[Graphics.frame_count % 60 / 20] if Graphics.frame_count % 20 == 0
      end
      @viewport.visible = false
    end
  end
end

################################################################################
# Addons
# By A Dork of Pork, Rewritten by Nuri Yuri
# (pokemon to string and string to pokemon based from Maruno's MysteryGift packer/unpacker)
# Addons to other scripts
################################################################################
module PFM
  class Pokemon_Party
    attr_accessor :online_pokemon

    # Retrieve the online ID of the trainer
    # @return [Integer]
    def online_id
      if @online_id.nil?
        id = GTS::Core.obtain_online_id
        raise('GTS Error: Cannot get Online ID for GTS!') if id == 0
        raise('GTS Error: Cannot set Online ID for GTS!') unless GTS::Core.register_online_id(id)

        @online_id = id
      end
      return @online_id
    end

    # The raw_online_id doesn't have the checksum to get a new ID, this is used for
    # when you do new game.
    # @return [Integer, nil]
    def raw_online_id
      @online_id
    end
  end

  # Add a game_code field and to_s method to the pokemon class
  class Pokemon
    # Code of the game where the Pokemon comes from (nil if the Pokemon hasn't been tainted by GTS system)
    # @return [Integer, nil]
    attr_accessor :game_code
    # Encode the Pokemon to a String in order to send it to the GTS system
    # @return [String]
    def encode
      return [Zlib::Deflate.deflate(Marshal.dump(self))].pack('m')
    end
  end
end

# Add a to_pokemon method to the string class
class String
  # Convert string to Pokemon if possible
  # @return [PFM::Pokemon, nil]
  def to_pokemon
    return Marshal.restore(Zlib::Inflate.inflate(unpack('m')[0]))
  rescue StandardError
    return nil
  end
end

# Delete Pokemon if we began a newgame
module GamePlay
  class Save
    alias gts_save_game save_game
    def save_game
      potential_old_party = current_pokemon_party
      if potential_old_party&.raw_online_id && potential_old_party&.online_pokemon &&
         potential_old_party.raw_online_id != $pokemon_party.raw_online_id
        GTS::Core.delete_pokemon(true, potential_old_party)
      end
      gts_save_game
    end
  end
end
