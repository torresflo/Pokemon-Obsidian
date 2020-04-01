module Battle
  class Move
    private

    # Mod2 multiplier calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod2(user, target)
      update_use_count(user)
      item = user.item_db_symbol
      result = 1
      result *= VAL_1_3 if item == :life_orb
      result *= calc_mod2_metronome if item == :metronome
      result *= 1.5 if db_symbol == :me_first
      return result
    end

    # Update the move use count
    # @param user [PFM::PokemonBattler] user of the move
    def update_use_count(user)
      if user.last_successfull_move != db_symbol
        @consecutive_use_count = 0
      else
        @consecutive_use_count += 1
      end
    end

    # Calculate the multiplier of the metronome
    def calc_mod2_metronome
      return 1 if @consecutive_use_count == 0
      return 2 if @consecutive_use_count >= 10
      return 1 + @consecutive_use_count / 10.0
    end
  end
end
