class Interpreter
  include Util::SystemMessage if const_defined?(:Util)
  # Name of the file used as Received Pokemon ME (with additional parameter like volume)
  RECEIVED_POKEMON_ME = ['audio/me/rosa_yourpokemonevolved', 80]
  # Header of the system messages
  SYSTEM_MESSAGE_HEADER = ':[windowskin=m_18]:\\c[10]'
  # Default BGM used for trainer battle (sent to AudioFile so no audio/bgm)
  DEFAULT_TRAINER_BGM = ['xy_trainer_battle', 100, 100]
  # Default eye bgm for trainer encounter (direct, requires audio/bgm)
  DEFAULT_EYE_BGM = ['audio/bgm/pkmrs-enc1', 100, 100]
  # Default exclamation SE for trainer encounter (direct, requires audio/se)
  DEFAULT_EXCLAMATION_SE = ['audio/se/015-jump01', 65, 95]
  # Duration of the exclamation particle
  EXCLAMATION_PARTICLE_DURATION = 54
  # Receive Pokemon sequence, when the player is given a Pokemon
  # @param pokemon_or_id [Integer, Symbol, PFM::Pokemon] the ID of the pokemon in the database or a Pokemon
  # @param level [Integer] the level of the Pokemon (if ID given)
  # @param shiny [Boolean, Integer] true means the Pokemon will be shiny, 0 means it'll have no chance to be shiny, other number are the chance (1 / n) the pokemon can be shiny.
  # @return [PFM::Pokemon, nil] if nil, the Pokemon couldn't be stored in the PC or added to the party. Otherwise it's the Pokemon that was added.
  def receive_pokemon_sequence(pokemon_or_id, level = 5, shiny = false)
    pokemon = add_pokemon(pokemon_or_id, level, shiny)
    if pokemon
      Audio.me_play(*RECEIVED_POKEMON_ME)
      show_message(:received_pokemon, pokemon: pokemon, header: SYSTEM_MESSAGE_HEADER)
      original_name = pokemon.given_name
      while yes_no_choice(load_message(:give_nickname_question))
        rename_pokemon(pokemon)
        if pokemon.given_name == original_name ||
           yes_no_choice(load_message(:is_nickname_correct_qesion, pokemon: pokemon))
          break
        else
          pokemon.given_name = original_name
        end
      end
      pokemon_stored_sequence(pokemon) if $game_switches[Yuki::Sw::SYS_Stored]
      PFM::Text.reset_variables
    end
    return pokemon
  end

  # Show the "Pokemon was sent to BOX $" message
  # @param pokemon [PFM::Pokemon] Pokemon sent to the box
  def pokemon_stored_sequence(pokemon)
    show_message(:pokemon_stored_to_box,
                 pokemon: pokemon,
                 '[VAR BOXNAME]' => $storage.get_box_name($storage.current_box),
                 header: SYSTEM_MESSAGE_HEADER)
  end

  # Start a trainer battle
  # @param trainer_id [Integer] ID of the trainer in Ruby Host
  # @param bgm [String, Array] BGM to play for battle
  # @param disable [String] Name of the local switch to disable (if defeat)
  # @param enable [String] Name of the local switch to enable (if victory)
  # @param troop_id [Integer] ID of the troop to use : 3 = trainer, 4 = Gym Leader, 5 = Elite, 6 = Champion
  # @example Start a simple trainer battle
  #   start_trainer_battle(5) # 5 is the trainer 5 in Ruby Host
  # @example Start a trainer battle agains a gym leader
  #   start_trainer_battle(5, bgm: '28 Pokemon Gym', troop_id: 4)
  def start_trainer_battle(trainer_id, bgm: DEFAULT_TRAINER_BGM, disable: 'A', enable: 'B', troop_id: 3)
    set_self_switch(false, disable, @event_id) # Better to disable the switch here than in defeat
    original_battle_bgm = $game_system.battle_bgm
    $game_system.battle_bgm = RPG::AudioFile.new(*bgm)
    $game_variables[Yuki::Var::Trainer_Battle_ID] = trainer_id
    $game_temp.battle_abort = true
    $game_temp.battle_calling = true
    $game_temp.battle_troop_id = troop_id
    $game_temp.battle_can_escape = false
    $game_temp.battle_can_lose = false
    $game_temp.battle_proc = proc do |n|
      yield if block_given?
      set_self_switch(true, enable, @event_id) if n == 0
      $game_system.battle_bgm = original_battle_bgm
    end
  end

  # Sequence to call before start trainer battle
  # @param phrase [String] the full speech of the trainer
  # @param eye_bgm [String, Array] BGM to play during the speech
  # @param exclamation_se [String, Array] SE to play when the trainer detect the player
  # @example Simple eye sequence
  #   trainer_eye_sequence('Hello!')
  # @example Eye sequence with another eye_bgm
  #   trainer_eye_sequence('Hello!', eye_bgm: 'audio/bgm/pkmrs-enc7')
  def trainer_eye_sequence(phrase, eye_bgm: DEFAULT_EYE_BGM, exclamation_se: DEFAULT_EXCLAMATION_SE)
    character = get_character(@event_id)
    character.turn_toward_player
    front_coordinates = $game_player.front_tile
    # Unless the player triggered the event we show the exclamation
    unless character.x == front_coordinates.first && character.y == front_coordinates.last
      Audio.se_play(*exclamation_se)
      emotion(:exclamation)
      EXCLAMATION_PARTICLE_DURATION.times do
        $game_player.update
        $scene.spriteset.update
        Graphics.update
      end
    end
    Audio.bgm_play(*eye_bgm)
    # We move to the trainer
    while (($game_player.x - character.x).abs + ($game_player.y - character.y).abs) > 1
      character.move_toward_player
      while character.moving?
        $game_map.update
        $scene.spriteset.update
        Graphics.update
      end
    end
    $game_player.turn_toward_character(character)
    # We do the speech
    @message_waiting = true
    $scene.display_message(phrase)
    @message_waiting = false
    @wait_count = 2
  end

  # Sequence that perform NPC trade
  # @param index [Integer] index of the Pokemon in the party
  # @param pokemon [PFM::Pokemon] Pokemon that is traded with
  def npc_trade_sequence(index, pokemon)
    return unless $actors[index].is_a?(PFM::Pokemon)

    actor = $actors[index]
    $actors[index] = pokemon
    # TODO: Trade animation taking actor, pokemon (including messages)
    $scene.display_message("#{actor.given_name} is being traded with #{pokemon.name}")
    id, form = pokemon.evolve_check(:trade, @pokemon)
    $scene.call_scene(GamePlay::Evolve, pokemon, id, form, true) if id
  end
end
