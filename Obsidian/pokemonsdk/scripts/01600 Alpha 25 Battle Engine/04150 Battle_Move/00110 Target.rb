module Battle
  class Move
    # List of symbol describe a one target aim
    OneTarget = %i[any_other_pokemon random_foe adjacent_pokemon adjacent_foe user user_or_adjacent_ally adjacent_ally]
    # List of symbol that doesn't show any choice of target
    TargetNoAsk = %i[adjacent_all_foe all_foe adjacent_all_pokemon all_pokemon user all_ally random_foe]

    # Does the skill aim only one Pokemon
    # @return [Boolean]
    def one_target?
      return OneTarget.include?(target)
    end
    alias is_one_target? one_target? # BE24

    # Does the skill doesn't show a target choice
    # @return [Boolean]
    def no_choice_skill?
      return TargetNoAsk.include?(target)
    end
    alias is_no_choice_skill? no_choice_skill? # BE24

    # Does the move affect the whole bank (in order to manage Magic Bounce)
    # @return [Boolean]
    alias affects_bank? void_false

    # List the targets of this move
    # @param pokemon [PFM::PokemonBattler] the Pokemon using the move
    # @param logic [Battle::Logic] the battle logic allowing to find the targets
    # @return [Array<PFM::PokemonBattler>] the possible targets
    # @note use one_target? to select the target inside the possible result
    def battler_targets(pokemon, logic)
      case target
      #  eo eo ex / ux ao ax || e! e! ex / ux a! ax
      when :adjacent_pokemon, :adjacent_all_pokemon
        return logic.adjacent_foes_of(pokemon).concat(logic.adjacent_allies_of(pokemon))
      #  eo eo ex / ux ax ax || e! e! ex / ux ax ax
      when :adjacent_foe, :adjacent_all_foe
        return logic.adjacent_foes_of(pokemon)
      #  e! e! e! / ux ax ax || e? e? e? / ux ax ax
      when :all_foe, :random_foe
        return logic.foes_of(pokemon)
      #  e! e! e! / u! a! a!
      when :all_pokemon
        return logic.foes_of(pokemon).concat(logic.allies_of(pokemon)) << pokemon
      #  ex ex ex / u! ax ax
      when :user
        return [pokemon]
      #  ex ex ex / uo ao ax
      when :user_or_adjacent_ally
        return [pokemon].concat(logic.adjacent_allies_of(pokemon))
      #  ex ex ex / ux ao ax
      when :adjacent_ally
        return logic.allies_of(pokemon)
      #  ex ex ex / u! a! a!
      when :all_ally
        return [pokemon].concat(logic.allies_of(pokemon))
      # eo eo eo / ux ao ao
      when :any_other_pokemon
        return logic.foes_of(pokemon).concat(logic.allies_of(pokemon))
      end
      return [pokemon]
    end
  end
end
