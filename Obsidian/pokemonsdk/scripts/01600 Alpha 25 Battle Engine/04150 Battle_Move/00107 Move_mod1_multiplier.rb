module Battle
  class Move
    private

    # Mod1 multiplier calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod1(user, target)
      # Mod1 = BRN × RL × TVT × SR × FF
      # BRN
      result = calc_mod1_brn(user)
      # RL
      result *= calc_mod1_rl(target)
      # TVT
      result *= calc_mod1_tvt(target)
      # SR
      result *= calc_mod1_sr
      # FF
      return result * calc_mod1_ff(user)
    end

    # Calculate the burn mod
    # @param user [PFM::PokemonBattler] user of the move
    # @return [Numeric]
    def calc_mod1_brn(user)
      return 1 unless physical? && user.burn?
      return 1 if user.ability_db_symbol == :guts
      return VAL_0_5
    end

    # Calculate the RL mod
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod1_rl(target)
      return 1 if critical_hit?
      if physical?
        return 1 unless logic.bank_reflect?(target.bank)
      else
        return 1 unless logic.bank_light_screen?(target.bank)
      end
      return $game_temp.vs_type == 2 ? (2 / 3.0) : VAL_0_5
    end

    # Calculate the TVT mod
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod1_tvt(target)
      return 1 if one_target? || $game_temp.vs_type == 1
      count = 0
      if self.target == :all_foe
        $game_temp.vs_type.times do |i|
          count += 1 if logic.battler(target.bank, i)&.can_fight?
        end
      else
        (target.position - 1).upto(target.position + 1) do |i|
          count += 1 if logic.battler(target.bank, i)&.can_fight?
        end
      end
      return count > 1 ? 0.75 : 1
    end

    # Calculate the SR mod
    # @return [Numeric]
    def calc_mod1_sr
      if $env.sunny?
        return 1.5 if type == GameData::Types::FIRE
        return VAL_0_5 if type == GameData::Types::WATER
      elsif $env.rain?
        return VAL_0_5 if type == GameData::Types::FIRE
        return 1.5 if type == GameData::Types::WATER
      end
      return 1
    end

    # Calculate the Flash Fire mod
    # @param user [PFM::PokemonBattler] user of the move
    # @return [Numeric]
    def calc_mod1_ff(user)
      if user.ability_db_symbol == :flash_fire
        return 1.5 if user.last_hit_by_move&.type == GameData::Types::FIRE
      end
      return 1
    end
  end
end
