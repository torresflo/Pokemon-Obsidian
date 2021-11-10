# Run by writing : Game --util=data_to_csv extract

module GameData
  class Base
    COLUMNS = %i[id db_symbol class]
    # @return [Array<Symbol>]
    def columns
      COLUMNS
    end

    def to_csv_row
      columns.map { |i| respond_to?(i) ? send(i) : nil }
    end
  end

  class Item
    COLUMNS = %i[
      id db_symbol class name icon price socket position battle_usable map_usable limited holdable fling_power
      loyalty_malus hp_count hp_rate status_list stat_index count
      move_learnt is_hm img catch_rate color level_count pp_count max repel_count event_id
    ]
    def columns
      COLUMNS
    end
  end

  class Pokemon
    COLUMNS = %i[
      id id_bis form db_symbol name species front_offset_y
      height weight type1 type2
      base_hp base_atk base_dfe base_spd base_ats base_dfs
      ev_hp ev_atk ev_dfe ev_spd ev_ats ev_dfs
      exp_type base_exp evolution_level evolution_id special_evolution
      base_loyalty rareness female_rate breed_groupes hatch_step baby
      items abilities move_set tech_set breed_moves master_moves
    ]
    def columns
      COLUMNS
    end

    def baby
      GameData::Pokemon[@baby || 0].db_symbol
    end

    def type1
      "#{@type1} - #{GameData::Type[@type1].name}"
    end

    def type2
      "#{@type2} - #{GameData::Type[@type2].name}"
    end

    def special_evolution
      @special_evolution.inspect
    end

    def items
      (@items || []).each_slice(2).map do |(id, rate)|
        "#{GameData::Item[id].db_symbol} #{rate}%"
      end.join(' | ')
    end

    def abilities
      (@abilities || []).map { |i| GameData::Abilities.db_symbol(i) }.join(' | ')
    end

    def move_set
      (@move_set || []).each_slice(2).sort.map do |(level, id)|
        "lv.#{level} #{GameData::Skill[id].db_symbol}"
      end.join(' > ')
    end

    def tech_set
      (@tech_set || []).map { |i| GameData::Skill[i].db_symbol }.join(' | ')
    end

    def breed_moves
      (@breed_moves || []).map { |i| GameData::Skill[i].db_symbol }.join(' | ')
    end

    def master_moves
      (@master_moves || []).map { |i| GameData::Skill[i].db_symbol }.join(' | ')
    end
  end

  class Skill
    COLUMNS = %i[
      id db_symbol name type power accuracy pp_max atk_class be_method target
      priority critical_rate direct charge recharge blocable snatchable mirror_move
      punch gravity magic_coat_affected unfreeze sound_attack distance heal authentic
      powder bite pulse ballistics mental non_sky_battle dance king_rock_utility
      effect_chance battle_stage_mod status map_use
    ]
    def columns
      COLUMNS
    end

    def type
      "#{@type} - #{GameData::Type[@type].name}"
    end
  end

  class Type
    COLUMNS = %i[id db_symbol name text_id on_hit_tbl]
    def columns
      COLUMNS
    end

    def on_hit_tbl
      @on_hit_tbl.map.with_index do |factor, i|
        "x#{factor} (#{GameData::Type[i].name})"
      end.join(' | ')
    end
  end
end

$options = PFM::Options.new('fr')
GameData::Text.load
GameData::Pokemon.load
GameData::Item.load
GameData::Skill.load
GameData::Type.load
GameData::Abilities.load
if ARGV.include?('extract')
  CSV.open('Data/PSDK/pokemon.csv', 'w') do |csv|
    csv << GameData::Pokemon::COLUMNS
    GameData::Pokemon.all.each do |i|
      i.each do |j|
        next unless j

        csv << j.to_csv_row
      end
    end
  end
  CSV.open('Data/PSDK/item.csv', 'w') do |csv|
    csv << GameData::Item::COLUMNS
    GameData::Item.all.each do |i|
      csv << i.to_csv_row
    end
  end
  CSV.open('Data/PSDK/skills.csv', 'w') do |csv|
    csv << GameData::Skill::COLUMNS
    GameData::Skill.all.each do |i|
      csv << i.to_csv_row
    end
  end
  CSV.open('Data/PSDK/types.csv', 'w') do |csv|
    csv << GameData::Type::COLUMNS
    GameData::Type.all.each do |i|
      csv << i.to_csv_row
    end
  end
else
 # 0
end
