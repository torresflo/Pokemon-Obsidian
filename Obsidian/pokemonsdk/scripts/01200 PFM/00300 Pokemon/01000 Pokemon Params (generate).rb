module PFM
  class Pokemon
    # PSP 0.7 ID Hash key
    G_ID = 'ID'
    # PSP 0.7 level Hash key
    G_NV = 'NV'
    # PSP 0.7 item hash key
    G_OBJ = 'OBJ'
    # PSP 0.7 stat hash key
    G_STAT = 'STAT'
    # PSP 0.7 move hash key
    G_MOVE = 'MOVE'
    # PSP 0.7 gender hash key
    G_GR = 'GR'
    # PSP 0.7 form hash key
    G_FORM = 'FORM'
    # PSP 0.7 shiny hash key
    G_SHINY = 'SHINY'
    class << self
      # Generate a Pokemon from a hash
      #
      #   Hash structure :
      #     id: Integer # ID of the Pokemon in the database
      #     level: Integer # Level of the Pokemon
      #     item: opt Integer # ID of the item the Pokemon holds
      #     stats: opt Array<Integer> # IV of the Pokemon [hp, atk, dfe, spd, ats, dfs]
      #     moves: opt Array<Integer> # List of skill/move ID in the database
      #     gender: opt Integer/String # "i", 0, "m", 1, "f", 2
      #     shiny: Boolean # If the Pokemon is shiny
      #     no_shiny: Boolean # If the Pokemon cannot be shiny
      #     form: opt Integer # The form of the Pokemon
      #     rareness: opt Integer # The pokemon rareness (0 = uncatchable)
      #     trainer_name: opt String # Trainer name of the Pokemon
      #     trainer_id: opt Integer # Trainer id of the Pokemon
      #     given_name: opt String # Given name of the Pokemon
      #     loyalty: opt Integer # Loyalty of the Pokemon
      #     ball: opt Integer # ID of the ball used to catch the Pokemon
      #     bonus: opt Array<Integer> # EV of the Pokemon [hp, atk, dfe, spd, ats, dfs]
      #     nature: opt Integer # Nature of the Pokemon
      #     memo_text: opt Array<Integer> [file_id, text_id]
      # @param hash [Hash] the hash parameter of the Pokemon
      # @return [PFM::Pokemon]
      def generate_from_hash(hash)
        pkmn_id = hash[:id]
        return psp_generate_from_hash(hash) unless pkmn_id # On est donc en mode PSP 0.7
        obj = hash[:item]
        stat = hash[:stats]
        moves = hash[:moves]
        form = hash[:form]
        ability = hash[:ability]

        pokemon = PFM::Pokemon.new(pkmn_id, hash[:level].to_i, hash[:shiny], hash[:no_shiny], form || -1)
        pokemon.code_generation(hash[:shiny])

        # Set gender
        pokemon.set_gender(hash[:gender] || pokemon.gender)
        # Set Moves
        pokemon.load_skill_from_array(moves) if moves
        # Set IV
        pokemon.dv_modifier(stat) if stat && stat.size == 6
        # Set EV
        bonus = hash[:bonus]
        pokemon.add_bonus(bonus) if bonus
        # Set Item
        if obj
          success = !hash[:item_rate]
          success ||= rand(100) < hash[:item_rate]
          pokemon.item_holding = obj if success
        end
        # Set Ability
        if ability
          pokemon.ability_current = pokemon.ability = ability
          pokemon.ability_index = nil
        end
        pokemon.form = form
        # Set Nature
        pokemon.nature = hash[:nature] || pokemon.nature_id
        # Set trainer info
        pokemon.trainer_id = hash[:trainer_id] || pokemon.trainer_id
        pokemon.trainer_name = hash[:trainer_name] || pokemon.trainer_name
        # Set nickname
        pokemon.given_name = hash[:given_name] || pokemon.given_name
        # Set rareness
        pokemon.rareness = hash[:rareness] || pokemon.rareness
        # Set happiness
        pokemon.loyalty = hash[:loyalty] || pokemon.loyalty
        # Set ball used to catch the Pokemon
        pokemon.captured_with = hash[:ball] || pokemon.captured_with
        # Memo text
        pokemon.memo_text = hash[:memo_text]
        pokemon.hp = pokemon.max_hp

        return pokemon
      end

      private

      def psp_generate_from_hash(hash)
        form = hash[G_FORM]
        pokemon = PFM::Pokemon.new(hash[G_ID], hash[G_NV], hash[G_SHINY], false, form || -1)

        # Set Gender
        sexe = hash[G_GR]
        pokemon.set_gender(sexe) if sexe
        # Set Moves
        moves = hash[G_MOVE]
        pokemon.load_skill_from_array(moves) if moves
        # Set IV
        stat = hash[G_STAT]
        pokemon.dv_modifier(stat) if stat && stat.size == 6
        # Set Item
        obj = hash[G_OBJ]
        pokemon.item_holding = obj

        return pokemon
      end
    end
  end
end
