#encoding : utf-8


module GamePlay
  class Evolve < BaseCleanUpdate
    attr_accessor :evolved
    #Name of the png background
    BACK_NAMES=["back_building","back_grass","back_tall_grass","back_taller_grass",
        "back_cave","back_mount","back_sand","back_pond","back_sea","back_under_water",
        "back_snow","back_ice"]
    #Path of the music of the pokemon in evolution    
    EVOLVE_MUSIC = "Audio/BGM/PkmRS-Evolving.mid"
    #Path of the music of the pokemon in evolved
    EVOLVED_MUSIC = "Audio/BGM/XY_Trainer_Battle_Victory.ogg"

    #Constante for evolved animation
    FIRST_STEP = 60
    SECOND_STEP = FIRST_STEP + 420
    LAST_STEP = SECOND_STEP + 60
    PI2 = Math::PI*2

    # Launch the Pokemon Evolution scene
    # @param pokemon [PFM::Pokemon] the evolving Pokemon
    # @param id [Integer] the ID of the evolution
    # @param form [Integer] the form of the evolution
    # @param forced [Boolean] if the evolution can be stopped or not
    def initialize(pokemon, id, form = nil, forced = false)
      super()
      @pokemon = pokemon 
      @clone = pokemon.clone
      @clone.id = id
      if form
        @clone.form = form
      else
        @clone.form_calibrate(:evolve)
      end
      @forced = forced 
      @id_bg = 0
      @evolved = false
      @counter = 0
      memorize_audio
    end

    def update_graphics
      return if $game_temp.message_window_showing

      if @counter == 0
        evolution_first_step
      elsif @counter >= LAST_STEP
        evolution_last_step
        update_message
        #===
        #> Munja évolution de Ningale
        #> Faites avant l'évolution de Ningale
        #===
        munja_evolution
        update_pkmn_id
        # check_alola_evolve(@pokemon)
        @pokemon.check_skill_and_learn # (false, -1) #(US-45) Fin de ligne commentée tant que la BDD n'aura pas les niveaux à -1 pour les attaques par évolution.
        restore_audio
        @running = false
        @evolved = true
        register_in_pokedex
      else
        if(@counter < SECOND_STEP and (!@forced and Input.trigger?(:B)))
          stop_evolution_step
          return
        else
          update_animation
        end
      end
      @counter += 1
    end

    private

    def release_animation
      @sprite_clone.opacity = 0
      @sprite_pokemon.opacity = 255
      @sprite_pokemon.set_color([0, 0, 0, 0])
      @viewport.tone.set(0, 0, 0, 0)
    end

    def stop_evolution_step
      release_animation
      @message_window.stay_visible = false
      display_message(parse_text(31, 1, ::PFM::Text::PKNICK[0] => @pokemon.given_name))
      @running = false
      $game_system.bgm_restore2
    end

    def evolution_first_step 
      Audio.bgm_play(EVOLVE_MUSIC)
      $game_system.cry_play(@pokemon.id)
      @message_window.auto_skip = true
      @message_window.stay_visible = true
      display_message(parse_text(31, 0, ::PFM::Text::PKNICK[0] => @pokemon.given_name))
    end

    def evolution_last_step
      @message_window.stay_visible = false
      Audio.bgm_play(EVOLVED_MUSIC)
      $game_system.cry_play(@clone.id)
      display_message(parse_text(31, 2, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
        ::PFM::Text::PKNAME[1] => @clone.name))
    end

    def munja_evolution
      if @clone.id == 291 and $actors.size < 6 and $bag.contain_item?(4)
        munja = PFM::Pokemon.generate_from_hash({
          id: 292,
          level: @pokemon.level,
          exp: @pokemon.exp,
          shiny: @pokemon.shiny,
          captured_in: @pokemon.captured_in,
          trainer_id: @pokemon.trainer_id,
          trainer_name: @pokemon.trainer_name,
          iv_hp: @pokemon.iv_hp,
          iv_atk: @pokemon.iv_atk,
          iv_dfe: @pokemon.iv_dfe,
          iv_spd: @pokemon.iv_spd,
          iv_ats: @pokemon.iv_ats,
          iv_dfs: @pokemon.iv_dfs,
          ev_hp: @pokemon.ev_hp,
          ev_atk: @pokemon.ev_atk,
          ev_dfe: @pokemon.ev_dfe,
          ev_spd: @pokemon.ev_spd,
          ev_ats: @pokemon.ev_ats,
          ev_dfs: @pokemon.ev_dfs,
          skills_set: @pokemon.skills_set
        })
        $actors << munja
        $bag.remove_item(4, 1)
        $pokedex.mark_seen(292, forced: true)
        $pokedex.mark_captured(292)
      end
    end

    def register_in_pokedex
      $pokedex.mark_seen(@pokemon.id, @pokemon.form, forced: true)
      $pokedex.mark_captured(@pokemon.id)
      $pokedex.pokemon_fought_inc(@pokemon.id)
      $pokedex.pokemon_captured_inc(@pokemon.id)
    end

    def memorize_audio
      $game_system.bgm_memorize2
      Audio.bgm_stop
    end

    def restore_audio
      Audio.bgm_stop
      $game_system.bgm_restore2
    end

    def update_animation
      if @counter < FIRST_STEP
        value = 255 * @counter / FIRST_STEP
        @sprite_pokemon.set_color(Color.new(value, value, value, value))
        value /= 5
        @viewport.tone.set(value, value, value, 0)
      elsif @counter < SECOND_STEP
        value = (Math.cos((@counter-FIRST_STEP)*PI2/120)+1)*128
        @sprite_pokemon.opacity = value
        @sprite_clone.opacity = 255-value
      elsif @counter < LAST_STEP
        value = (60 - (@counter - SECOND_STEP)) * 255 / 60
        @viewport.tone.set(value, value, value, 0)
        @sprite_clone.set_color(Color.new(value, value, value, value))
      end
    end
    
    def update_pkmn_id
      @pokemon.id = @clone.id
      @pokemon.form = @clone.form
    end

    def update_message
      while $game_temp.message_window_showing
        @message_window.update
        Graphics.update
      end
    end

    def create_background
        @id_bg = $env.get_zone_type(true)
        if(@id_bg == 0 && $env.grass?)
            @id_bg = 1
        else
            @id_bg += 1
        end
        @background = Sprite.new(@viewport).set_bitmap(BACK_NAMES[@id_bg], :battleback)
    end
   
    def create_sprite_pkmn
      @sprite_pokemon = Sprite::WithColor.new(@viewport).set_bitmap(@pokemon.battler_face)
      @sprite_pokemon.set_position(160,120)
      @sprite_pokemon.set_origin_div(2,2)
    end

    def create_sprite_pkmn_evolved
        @sprite_clone = Sprite::WithColor.new(@viewport).set_bitmap(@clone.battler_face)
        @sprite_clone.set_position(160,120)
        @sprite_clone.set_origin_div(2, 2)
        @sprite_clone.set_color([1, 1, 1, 1])
        @sprite_clone.opacity = 0
    end

    def create_graphics
      create_viewport
      create_background
      create_sprite_pkmn
      create_sprite_pkmn_evolved
    end

  end
end