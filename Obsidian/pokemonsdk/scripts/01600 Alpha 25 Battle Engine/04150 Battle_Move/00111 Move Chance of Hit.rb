module Battle
  class Move
    # List of accuracy items modifier
    ACCURACY_ITEM_MULTIPLIER = Hash.new(:calc_item_no_multiplier).merge!(
      wide_lens: :acc_mod_wide_lens,
      zoom_lens: :acc_mod_zoom_lens
    )
    # List of evasion item modifier
    EVASION_ITEM_MULTIPLIER = Hash.new(:calc_item_no_multiplier).merge!(
      brightpowder: :eva_mod_brightpowder,
      lax_incense:  :eva_mod_lax_incense
    )
    # List of accuracy ability modifier
    ACCURACY_ABILITY_MULTIPLIER = Hash.new(:calc_item_no_multiplier).merge!(
      compoundeyes: :acc_mod_compoundeyes,
      hustle: :acc_mod_hustle
    )
    # List of evasion ability modifier
    EVASION_ABILITY_MULTIPLIER = Hash.new(:calc_item_no_multiplier).merge!(
      sand_veil: :eva_mod_sand_veil,
      snow_cloak: :eva_mod_snow_cloak,
      tangled_feet: :eva_mod_tangled_feet
    )
    # @return [Float] Modifier of Gravity
    GRAVITY_MODIFIER = 5.0 / 3

    # Return the chance of hit of the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Float]
    def chance_of_hit(user, target)
      # TODO: lock-on return 100 if target is locked by user
      return 100 *
             accuracy_mod(user) *
             evasion_mod(target) *
             send(ACCURACY_ITEM_MULTIPLIER[user.item_db_symbol], user, target) *
             send(EVASION_ITEM_MULTIPLIER[target.item_db_symbol], user, target) *
             send(ACCURACY_ABILITY_MULTIPLIER[user.ability_db_symbol], user, target) *
             send(EVASION_ABILITY_MULTIPLIER[target.ability_db_symbol], user, target) *
             (logic.global_gravity? ? GRAVITY_MODIFIER : 1)
    end

    private

    # Return the accuracy modifier of the user
    # @param user [PFM::PokemonBattler]
    # @return [Float]
    def accuracy_mod(user)
      return user.stat_multiplier_acceva(user.acc_stage)
    end

    # Return the evasion modifier of the target
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def evasion_mod(target)
      return target.stat_multiplier_acceva(-target.eva_stage) # <=> 1 / ...
    end

    # Return the acc mod of the wide lens
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def acc_mod_wide_lens(user, target)
      return VAL_1_1
    end

    # Return the acc mod of the zoom lens
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def acc_mod_zoom_lens(user, target)
      return user.order > target.order ? VAL_1_1 : 0
    end

    # Return the acc mod of compoundeyes
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def acc_mod_compoundeyes(user, target)
      return VAL_1_3
    end

    # Return the acc mod of hustle
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def acc_mod_hustle(user, target)
      return physical? ? VAL_0_8 : 1
    end

    # Return the eva mod of the brightpowder
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def eva_mod_brightpowder(user, target)
      return VAL_0_9
    end

    # Return the eva mod of the lax_incense
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def eva_mod_lax_incense(user, target)
      return VAL_0_9
    end

    # Return the eva mod of sand veil
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def eva_mod_sand_veil(user, target)
      return $env.sandstorm? ? VAL_0_8 : 1
    end

    # Return the eva mod of snow cloak
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def eva_mod_snow_cloak(user, target)
      return $env.hail? ? VAL_0_8 : 1
    end

    # Return the eva mod of the tangled feet
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def eva_mod_tangled_feet(user, target)
      return target.confused? ? VAL_0_5 : 1
    end
  end
end
