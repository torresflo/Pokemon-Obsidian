#encoding: utf-8
class Pokemon_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  TYPE_FORMAT = '%d - %s'
  EXP_TYPES = ["0 - Fast", "1 - Medium", "2 - Slow", "3 - Slow/Parabolic", "4 - Erratic", "5 - Fluctuating"]
  GROUPS = ["0 - Not Defined", "1 - Monster", "2 - Water 1", "3 - Bug", "4 - Flying", "5 - Field", "6 - Fairy", "7 - Grass", "8 - Humanlike", "9 - Water 3", "10 - Mineral", "11 - Amorphous", "12 - Water 2", "13 - Ditto", "14 - Dragon", "15 - Undiscovered"]
  Forms = ["0 - Base"]
  Forms2 =  ["0 - Base"]
  1.step(29) do |i| Forms<<"#{i} - Non-existent";Forms2<<"#{i} - Existent" end
  Forms<<"30 - Mega 1"
  Forms<<"31 - Mega 2"
  Forms2<<"30 - Mega 1/Def"
  Forms2<<"31 - Mega 2/Def"
  POKEMON_FORM_PATH = "Graphics\\pokedex\\PokeFront\\%03d_%02d.png"
  POKEMON_PATH = "Graphics\\pokedex\\PokeFront\\%03d.png"
  Gender=["Unknown","Male","Female"]
  DayTime=["Night","Dawn","Morning","Day"]
  DATA_FILE = "Data/PSDK/PokemonData.rxdata"
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    define_combo_controler(1, :_on_pokemon_change, :_pokemon_list)
    define_combo(2, :_get_type_list, :_get_type1, :_set_type1)
    define_combo(3, :_get_type_list, :_get_type2, :_set_type2)
    define_combo(4, EXP_TYPES, :_get_exp_type, :_set_exp_type)
    define_combo(5, :_get_ability_list, :_get_ability1, :_set_ability1)
    define_combo(6, :_get_ability_list, :_get_ability2, :_set_ability2)
    define_combo(7, :_get_ability_list, :_get_ability3, :_set_ability3)
    define_combo(8, GROUPS, :_get_breed_group1, :_set_breed_group1)
    define_combo(9, GROUPS, :_get_breed_group2, :_set_breed_group2)
    define_combo_controler(10, :_on_form_change, :_form_list)
    define_combo(11, :_get_baby_list, :_get_baby, :_set_baby)
    define_text_view(1, :_get_pokemon_name)
    define_text_view(2, :_get_pokemon_descr)
    define_text_view(3, :_get_pokemon_species)
    define_text_control(4, :@height, 64, :_float_value)
    define_text_control(5, :@weight, 64, :_float_value)
    define_unsigned_int(6, {getter: :_get_id, setter: :_set_id}, 0, 99_999)
    define_unsigned_int(7, :@id_bis, 0, 99_999)
    define_unsigned_int(8, :@base_hp, 1, 255)
    define_unsigned_int(9, :@base_atk, 1, 255)
    define_unsigned_int(10, :@base_dfe, 1, 255)
    define_unsigned_int(11, :@base_spd, 1, 255)
    define_unsigned_int(12, :@base_ats, 1, 255)
    define_unsigned_int(13, :@base_dfs, 1, 255)
    define_unsigned_int(14, :@base_exp, 1, 999)
    define_unsigned_int(21, :@base_loyalty, 1, 255)
    define_signed_int(15, :@ev_hp, -255, 255)
    define_signed_int(16, :@ev_atk, -255, 255)
    define_signed_int(17, :@ev_dfe, -255, 255)
    define_signed_int(18, :@ev_spd, -255, 255)
    define_signed_int(19, :@ev_ats, -255, 255)
    define_signed_int(20, :@ev_dfs, -255, 255)
    define_signed_int(22, :@female_rate, -1, 100)
    define_checkbox(1, {getter: :_get_is_genderless, setter: :_set_is_genderless})
    define_unsigned_int(23, :@rareness, 0, 255)
    define_unsigned_int(24, :@evolution_id, 0, 99_999)
    define_unsigned_int(25, :@evolution_level, 0, 255)
    define_text_control(26, {getter: :_get_special_evl, setter: :_set_special_evl}, 20_000)
    define_unsigned_int(27, :@hatch_step, 0, 999_999)
    define_image(1, :_pokemon_image, :_change_pokemon_image)
    define_button(1, :_edit_pokemon_name)
    define_button(2, :_edit_pokemon_descr)
    define_button(3, :_edit_pokemon_species)
    define_button(4, :_check_evolve)
    define_button(5, :_edit_moveset)
    define_button(6, :_raz_pokemon)
    define_button(7, :_save)
    define_button(8, :_add)
    define_button(9, :_edit_ct)
    define_button(10, :_del)
    super
  end
  public
  def _edit_ct
    Pokemon_Plus_Dialog.instanciate(@hwnd, @pokemon_id, _pokemon_list)
  end
  
  def _edit_moveset
    Pokemon_Skill_Dialog.instanciate(@hwnd, @pokemon_id, _pokemon_list)
  end
  
  def _save
    check_update_data
    App.save_data($game_data_pokemon, get_file_name(DATA_FILE))
  end
  
  def _raz_pokemon
    $game_data_pokemon = App.load_data(get_file_name(DATA_FILE))
    return :update_dialog
  end
  
  def _edit_pokemon_name
    Text_Dialog.instanciate(@pokemon_id, 0, @hwnd)
    return :update_dialog
  end
  
  def _edit_pokemon_descr
    Text_Dialog.instanciate(@pokemon_id, 2, @hwnd)
    return :update_dialog
  end
  
  def _edit_pokemon_species
    Text_Dialog.instanciate(@pokemon_id, 1, @hwnd)
    return :update_dialog
  end
  
  def _get_special_evl
    @object.special_evolution.inspect
  end
  
  def _set_special_evl(value)
    value = eval(value)
    @object.special_evolution = value if value == nil or value.class == Array
  rescue Exception
    msgbox("Syntax error in the special evolution.", self.class.to_s)
  end
  
  def _get_is_genderless
    @object.female_rate == -1
  end
  
  def _set_is_genderless(value)
    @object.female_rate = -1 if value
  end
  
  def _get_pokemon_name
    GameData::Text._get(@lang_id, 0, @pokemon_id)
  end
  
  def _get_pokemon_descr
    GameData::Text._get(@lang_id, 2, @pokemon_id)
  end
  
  def _get_pokemon_species
    GameData::Text._get(@lang_id, 1, @pokemon_id)
  end
  
  def _on_pokemon_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_pokemon.size)
    check_update_data
    @object = $game_data_pokemon[id][0]
    @pokemon_id = id
    @object.id = id
    @object.form = 0
    @pokemon_form = 0
    update_combo(10, 0)
    return :update_dialog
  end
  
  def _pokemon_list
    if @pokemon_list and (@pokemon_list.size + 1) == $game_data_pokemon.size
      return @pokemon_list
    else
      lang = @lang_id
      @pokemon_list = Array.new($game_data_pokemon.size - 1) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 0, i+1), i+1)
      end
    end
    return @pokemon_list
  end
  
  def _get_baby_list
    if @baby_list and (@baby_list.size) == $game_data_pokemon.size
      return @baby_list
    else
      @baby_list = ["None (0)"] + _pokemon_list
    end
    return @baby_list
  end
  
  def _on_form_change(index, text)
    form_index = text.to_i
    check_update_data
    last_object = @object
    @object = $game_data_pokemon[@pokemon_id][form_index]
    unless @object
      @object = $game_data_pokemon[@pokemon_id][form_index] =
        Marshal.load(Marshal.dump(last_object))
    end
    @pokemon_form = form_index
    update_combo(10, form_index)
    @object.id = @pokemon_id
    @object.form = form_index
    return :update_dialog
  end
  
  def _form_list
    @pokemon_id = 1 unless @pokemon_id
    pkmn = $game_data_pokemon[@pokemon_id]
    return Array.new(Forms.size) do |i|
      next(Forms2[i]) if pkmn[i]
      next(Forms[i])
    end
  end
  
  def _get_type_list
    if @type_list and (@type_list.size) == $game_data_types.size
      return @type_list
    else
      @type_list = Array.new($game_data_types.size) do |i| 
        sprintf(TYPE_FORMAT, i, $game_data_types[i].name)
      end
    end
    return @type_list
  end
  
  def _get_type1
    @object.type1
  end
  
  def _set_type1(index, text)
    @object.type1 = text.to_i
  end
  
  def _get_type2
    @object.type2
  end
  
  def _set_type2(index, text)
    @object.type2 = text.to_i
  end
  
  def _get_exp_type
    @object.exp_type
  end
  
  def _set_exp_type(index, text)
    @object.exp_type = text.to_i
  end
  
  def _get_ability_list
    if @ability_list and (@ability_list.size) == $game_data_abilities.size
      return @ability_list
    else
      @ability_list = Array.new($game_data_abilities.size) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 4, $game_data_abilities[i]), i)
      end
    end
    return @ability_list
  end
  
  def _get_ability1
    @object.abilities[0].to_i
  end
  
  def _set_ability1(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_abilities.size)
    @object.abilities[0] = id
  end
  
  def _get_ability2
    @object.abilities[1].to_i
  end
  
  def _set_ability2(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_abilities.size)
    @object.abilities[1] = id
  end
  
  def _get_ability3
    @object.abilities[2].to_i
  end
  
  def _set_ability3(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_abilities.size)
    @object.abilities[2] = id
  end
  
  def _get_breed_group1
    @object.breed_groupes[0].to_i
  end
  
  def _set_breed_group1(index, text)
    @object.breed_groupes[0] = text.to_i
  end
  
  def _get_breed_group2
    @object.breed_groupes[1].to_i
  end
  
  def _set_breed_group2(index, text)
    @object.breed_groupes[1] = text.to_i
  end
  
  def _get_baby
    @object.baby.to_i
  end
  
  def _set_baby(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_pokemon.size)
    @object.baby = id
  end
  
  def _get_id
    @pokemon_id
  end
  
  def _set_id(value)
  
  end
  
  def _float_value(value)
    value = value.to_f
    return 0 if value < 0
    value
  end
  
  def _pokemon_image
    filename = get_file_name(sprintf(POKEMON_FORM_PATH, @pokemon_id, @pokemon_form))
    return filename if File.exist?(filename)
    return get_file_name(sprintf(POKEMON_PATH, @pokemon_id))
  end
  
  def _change_pokemon_image
    nil
  end
  
  def _check_evolve
    check_update_data
    ev = false
    str = "#{_get_pokemon_name} evolves to:"
    evolution_id = @object.evolution_id
    evolution_level = @object.evolution_level
    if(evolution_id * evolution_level > 0)
      begin
        str << "\r\n- #{GameData::Text._get(@lang_id,0,evolution_id)} at level #{evolution_level}"
        ev = true
      rescue TextDataError
        msgbox("This Pokémon can not evolve into an undefined Pokémon. : Pokémon with #{evolution_id} id doesn't exist.", self.class.to_s)
      end
    end
    v = @object.special_evolution
    if(v and v.class == Array)
      v.each do |i|
        #> Nom
        begin
          ev = true
          if(id = i[:trade])
            str << "\r\n- #{GameData::Text._get(@lang_id, 0, id.to_i)} by trade"
          else
            if i[:gemme]
              str << "\r\n- Mega-#{GameData::Text._get(@lang_id,0,@pokemon_id)}"
            else
              id = i[:id].to_i
              str << "\r\n- #{GameData::Text._get(@lang_id,0,id)}"
            end
          end
        rescue TextDataError
          msgbox("This Pokémon can not evolve into an undefined Pokémon. (Special evolution : n°#{i[:trade] || i[:id]})", self.class.to_s)
        end
        #> Echange avec
        if(id = i[:trade_with])
          begin
            str << " trade with #{GameData::Text._get(@lang_id,0,id)}"
          rescue TextDataError
            ###
          end
        end
        #> Autres infos
        if(id = i[:min_level])
          str<<" having a minimum level of #{id},"
        end
        if(id = i[:max_level])
          str<<" having a max level of #{id},"
        end
        if(id = i[:item_hold])
          str << " by holding the item: #{GameData::Text._get(App.lang_id,12,id)}," rescue ""
        end
        if(id = i[:min_loyalty])
          str<<" having a minimum happiness of #{id},"
        end
        if(id = i[:max_loyalty])
          str<<" having a maximum happiness of #{id}," rescue ""
        end
        if(id=i[:skill_1])
          str<<" having the move #{GameData::Text._get(App.lang_id,6,id)},"  rescue ""
          if(id=i[:skill_2])
            str<<" the move #{GameData::Text._get(App.lang_id,6,id)},"  rescue ""
            if(id==i[:skill_3])
              str<<" the move #{GameData::Text._get(App.lang_id,6,id)},"  rescue ""
              if(id==i[:skill_4])
                str<<" and the move #{GameData::Text._get(App.lang_id,6,id)},"  rescue ""
              end
            end
          end
        end
        if(id=i[:weather])
          str<<" if the weather is #{id},"
        end
        if(id=i[:env])
          str<<" if you are on system tag: #{id},"
        end
        if(id=i[:gender])
          str<<" having the gender: #{Gender[id]},"
        end
        if(id=i[:stone])
          str<<" using a: #{GameData::Text._get(App.lang_id,12,id)}," rescue ""
        end
        if(id=i[:day_night])
          str<<" at this time: #{DayTime[id]},"
        end
        if(id=i[:func])
          str<<" by validating this scripted function: : #{i[:func]},"
        end
        if(id=i[:maps])
          str<<" on this map: #{id},"
        end
        str.chomp!(",")
        str << "."
        #<<<
      end
    end
	  unless ev
      str<<"\r\nNo Pokémon."
	  end
    msgbox(str, self.class.to_s)
  end
  
  
  def _add
    if(check_text_before_adding(size = $game_data_pokemon.size, @lang_id, 0, 1, 2))
      check_update_data
      @object = pkm = GameData::Pokemon.new
      @pokemon_id = size
      @object.id = size
      @object.form = 0
      define_basic_object(pkm)
      $game_data_pokemon << [pkm]
      list = _pokemon_list
      position = list.index(sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 0, size), size)).to_i
      update_combo(10, @pokemon_form = 0)
      update_combo(1, position, true)
    else
      msgbox("You are either missing text for a name, species, or description.", self.class.to_s)
    end
  end
  
  def _del
    if(confirm("Any deletion can cause bugs in the game.\nAre you sure you want to delete this Pokémon?", self.class.to_s))
      if @pokemon_id == ($game_data_pokemon.size-1) and @pokemon_id > 1
        $game_data_pokemon.pop
        text = _pokemon_list.last
        id = text.split(TEXT_SPLIT).last.to_i
        id = 1 if(id < 1 or id >= $game_data_pokemon.size)
        @object = $game_data_pokemon[@pokemon_id = id][0]
        update_combo(10, @pokemon_form = 0)
        update_combo(1, $game_data_pokemon.size - 2)
      else
        msgbox("The Pokémon will be deleted.", self.class.to_s)
        @object = obj = GameData::Pokemon.new
        define_basic_object(obj)
        $game_data_pokemon[@pokemon_id] = [obj]
        update_combo(10, @pokemon_form = 0)
      end
      return :update_dialog
    end
  end
  
  def define_basic_object(pkm)
    pkm.type1=pkm.type2=pkm.id_bis=pkm.ev_hp=pkm.ev_atk=pkm.ev_dfe=pkm.ev_spd=pkm.ev_ats=pkm.ev_dfs=pkm.evolution_level=pkm.evolution_id=pkm.exp_type=0
    pkm.breed_groupes=[0,0]
    pkm.move_set=[]
    pkm.tech_set=[]
    pkm.special_evolution=nil
    pkm.abilities=[0,0,0]
    pkm.breed_moves=[]
    pkm.hatch_step=5120
    pkm.rareness=pkm.base_hp=pkm.base_atk=pkm.base_dfe=pkm.base_spd=pkm.base_ats=pkm.base_dfs=pkm.base_exp=40
	pkm.base_loyalty=70
	pkm.female_rate=50
    pkm.height=1.2
    pkm.weight=36.2
    pkm.items=[]
    pkm.master_moves = []
  end
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Pokemon_Dialog.new(App::Dialogs[:pokemon], 0) { |instance| @instance = instance}
  end
end