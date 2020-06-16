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
      # @param hash [Hash] Hash describing optional value you want to assign to the Pokemon
      # @option hash [Integer, Symbol] :id ID of the Pokemon
      # @option hash [Integer] :level level of the Pokemon
      # @option hash [Boolean] :shiny if the pokemon will be shiny
      # @option hash [Boolean] :no_shiny if the pokemon will never be shiny
      # @option hash [Integer] :form form index of the Pokemon
      # @option hash [String] :given_name Nickname of the Pokemon
      # @option hash [Integer, Symbol] :captured_with ID of the ball used to catch the Pokemon
      # @option hash [Integer] :captured_in ID of the zone where the Pokemon was caught
      # @option hash [Integer, Time] :captured_at Time when the Pokemon was caught
      # @option hash [Integer] :captured_level Level of the Pokemon when it was caught
      # @option hash [Integer] :egg_in ID of the zone where the egg was layed/found
      # @option hash [Integer, Time] :egg_at Time when the egg was layed/found
      # @option hash [Integer, String] :gender Forced gender of the Pokemon
      # @option hash [Integer] :nature Nature of the Pokemon
      # @option hash [Array<Integer>] :stats IV array ([hp, atk, dfe, spd, ats, dfs])
      # @option hash [Array<Integer>] :bonus EV array ([hp, atk, dfe, spd, ats, dfs])
      # @option hash [Integer, Symbol] :item ID of the item the Pokemon is holding
      # @option hash [Integer, Symbol] :ability ID of the ability the Pokemon has
      # @option hash [Integer] :rareness Rareness of the Pokemon (0 = not catchable, 255 = always catchable)
      # @option hash [Integer] :loyalty Happiness of the Pokemon
      # @option hash [Array<Integer, Symbol>] :moves Current Moves of the Pokemon (0 = default)
      # @option hash [Array(Integer, Integer)] :memo_text Text used for the memo ([file_id, text_id])
      # @option hash [String] :trainer_name Name of the trainer that caught / got the Pokemon
      # @option hash [Integer] :trainer_id ID of the trainer that caught / got the Pokemon
      # @return [PFM::Pokemon]
      def generate_from_hash(hash)
        pkmn_id = hash[:id]
        return psp_generate_from_hash(hash) unless pkmn_id # On est donc en mode PSP 0.7

        level = hash[:level].to_i
        shiny = hash[:shiny]
        ns = hash[:no_shiny]
        form = hash[:form] || -1
        hash[:captured_with] ||= hash[:ball]
        return PFM::Pokemon.new(pkmn_id, level, shiny, ns, form, hash)
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
