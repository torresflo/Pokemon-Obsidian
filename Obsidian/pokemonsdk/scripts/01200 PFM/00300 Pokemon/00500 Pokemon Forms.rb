#encoding: utf-8

module PFM
  class Pokemon
    FORM_CALIBRATE = {}
    FORM_GENERATION = {}
    # List of items (in the form index order) that change the form of Arceus
    ArceusItem = %i[__undef__ flame_plate splash_plate zap_plate meadow_plate
                    icicle_plate fist_plate toxic_plate earth_plate sky_plate
                    mind_plate insect_plate stone_plate spooky_plate draco_plate
                    iron_plate dread_plate pixie_plate]
    # List of items (in the form index order) that change the form of Genesect
    GenesectModules = %i[__undef__ burn_drive chill_drive douse_drive shock_drive]
    # List of item (in the form index oreder) that change the form of Silvally
    SilvallyROM = %i[__undef__ fighting_memory flying_memory poison_memory
                     ground_memory rock_memory bug_memory ghost_memory steel_memory
                     __undef__ fire_memory water_memory grass_memory electric_memory
                     psychic_memory ice_memory dragon_memory dark_memory fairy_memory]
    # Change the form of the Pokemon
    # @note If the form doesn't exist, the form is not changed
    # @param value [Integer] the new form index
    def form=(value)
      value = value.to_i
      if GameData::Pokemon.get_forms(@id)[value]
        @form = value
        form_calibrate
        update_ability
      end
    end

    # Check if the Pokemon can mega evolve
    # @return [Integer, false] form index if the Pokemon can mega evolve, false otherwise
    def can_mega_evolve?
      data = GameData::Pokemon.get_forms(@id)
      item_id = @item_holding
      if data.size > 30
        30.step(data.size - 1) do |i|
          d = data[i]
          next unless d.special_evolution
          d.special_evolution.each do |j|
            next if j[:form] && j[:form] != @form
            return i if item_id == j[:gemme]
            return i if j[:mega_skill] && skill_learnt?(j[:mega_skill])
          end
        end
      end
      return false
    end

    # Mega evolve the Pokemon (if possible)
    def mega_evolve
      mega_evolution = can_mega_evolve?
      return unless mega_evolution
      @mega_evolved = [@form, @ability]
      @form = mega_evolution
      @ability_current = @ability = data.abilities[rand(3)]
    end

    # Reset the Pokemon to its normal form after mega evolution
    def unmega_evolve
      if @mega_evolved
        @form, @ability = @mega_evolved
        @ability_current = @ability
        @mega_evolved = false
      end
    end

    # Is the Pokemon mega evolved ?
    def mega_evolved?
      return @mega_evolved != false
    end

    # Automatically generate the form index of the Pokemon
    # @note It calls the block stored in the hash FORM_GENERATION where the key is the Pokemon db_symbol
    # @param form [Integer] if form != 0 does not generate the form (protection)
    # @return [Integer] the form index
    def form_generation(form, old_value = nil)
      form = old_value if old_value
      return form if form != -1
      @character = nil
      block = FORM_GENERATION[db_symbol]
      return instance_exec(&block).to_i if block
      return 0
    end

    # Automatically calibrate the form of the Pokemon
    # @note It calls the block stored in the hash FORM_CALIBRATE where the key is the Pokemon db_symbol &
    #   the block parameter is the reason. The block should change @form
    # @param reason [Symbol] what called form_calibrate (:menu, :evolve, :load, ...)
    # @return [Boolean] if the Pokemon's form has changed
    def form_calibrate(reason = :menu)
      @character = nil
      data = GameData::Pokemon.get_forms(@id)
      last_form = @form
      block = FORM_CALIBRATE[db_symbol]
      instance_exec(reason, &block) if block
      # Set the form to 0 if the form does not exists in the Database
      @form = 0 unless data[@form]
      # Update the ability
      update_ability
      return last_form != @form
    end

    # Calculate the form of deerling & sawsbuck
    # @return [Integer] the right form
    def current_deerling_form
      time = Time.new
      case time.month
      when 1, 2
        return 3
      when 3
        return time.day < 21 ? 3 : 0
      when 6
        return time.day < 21 ? 0 : 1
      when 7, 8
        return 1
      when 9
        return time.day < 21 ? 1 : 2
      when 10, 11
        return 2
      when 12
        return time.day < 21 ? 2 : 3
      end
      return 0
    end

    FORM_GENERATION[:unown] = proc { @code % 28 }
    FORM_GENERATION[:castform] = proc do
      env = $env
      if env.sunny?
        next 2
      elsif env.rain?
        next 3
      elsif env.hail?
        next 6
      end
      next 0
    end
    FORM_GENERATION[:burmy] = FORM_GENERATION[:wormadam] = proc do
      env = $env
      if env.building?
        next 2
      elsif env.grass? || env.tall_grass? || env.very_tall_grass?
        next 0
      end
      next 1
    end
    FORM_GENERATION[:cherrim] = proc { $env.sunny? ? 1 : 0 }
    FORM_GENERATION[:deerling] = FORM_GENERATION[:sawsbuck] = proc { current_deerling_form }
    FORM_GENERATION[:meowstic] = proc { @gender == 2 ? 1 : 0 }

    FORM_CALIBRATE[:giratina] = proc { @form = item_db_symbol == :griseous_orb ? 1 : 0 }
    FORM_CALIBRATE[:arceus] = proc { @form = ArceusItem.index(item_db_symbol).to_i }
    FORM_CALIBRATE[:shaymin] = proc { @form = (item_db_symbol == :gracidea) && !($env.night? || $env.sunset?) ? 1 : 0 }
    FORM_CALIBRATE[:genesect] = proc { @form = GenesectModules.index(item_db_symbol).to_i }
    FORM_CALIBRATE[:silvally] = proc { @form = SilvallyROM.index(item_db_symbol).to_i }
    FORM_CALIBRATE[:deerling] = FORM_CALIBRATE[:sawsbuck] = proc { @form = current_deerling_form }
  end
end
