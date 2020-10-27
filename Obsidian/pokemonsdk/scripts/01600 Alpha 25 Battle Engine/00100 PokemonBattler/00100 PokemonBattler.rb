module PFM
  # Class defining a Pokemon during a battle, it aim to copy its properties but also to have the methods related to the battle.
  class PokemonBattler < Pokemon
    # List of properties to copy
    COPIED_PROPERTIES = %i[
      @id @form @given_name @code @ability @nature
      @iv_hp @iv_atk @iv_dfe @iv_spd @iv_ats @iv_dfs
      @ev_hp @ev_atk @ev_dfe @ev_spd @ev_ats @ev_dfs
      @trainer_id @trainer_name @step_remaining @loyalty
      @exp @hp @status @status_count @item_holding
      @captured_with @captured_in @captured_at @captured_level
      @gender @skill_learnt @ribbons
      @exp_rate @hp_rate @egg_at @egg_in
    ]

    # @return [Array<Battle::Move>] the moveset of the Pokemon
    attr_reader :moveset

    # @return [Symbol, nil] the last successfull move (during the previous turn)
    attr_accessor :last_successfull_move

    # @return [Integer] number of turn the Pokemon is in battle
    attr_accessor :turn_count

    # @return [Battle::Move] last move that hit the pokemon
    attr_accessor :last_hit_by_move

    # @return [Integer] 3rd type (Mega / Move effect)
    attr_accessor :type3

    # @return [Integer] the ID of the party that control the Pokemon in the bank
    attr_accessor :party_id

    # @return [Integer] Bank where the Pokemon is supposed to be
    attr_accessor :bank

    # @return [Integer] Position of the Pokemon in the bank
    attr_accessor :position

    # @return [Numeric] Order of the Pokemon in the action chain (the lesser the faster)
    attr_accessor :order

    # Create a new PokemonBattler from a Pokemon
    # @param original [PFM::Pokemon] original Pokemon (protected during the battle)
    # @param scene [Battle::Scene] current battle scene
    # @param max_level [Integer] new max level for Online battle
    def initialize(original, scene, max_level = Float::INFINITY)
      @original = original
      @scene = scene
      copy_properties
      copy_moveset
      init_states
      @level = original.level < max_level ? original.level : max_level
      @type3 = 0
      @bank = 0
      @position = -1
      @order = -1
    end

    # Reload the original ability
    def reset_ability
      @ability = @original.ability
    end

    # Is the Pokemon able to fight ?
    # @return [Boolean]
    def can_fight?
      @position && !dead?
    end

    # Is the pokemon able to use a move ?
    # @return [Boolean]
    def can_use_move?
      moves = @moveset
      # TODO : Implement all the move conditions
      return moves.any? { |move| move.pp > 0 }
    end

    def to_s
      "<PB:#{name},#{@bank},#{@position} lv=#{@level} hp=#{@hp_rate.round(3)} st=#{@status}>"
    end
    alias inspect to_s

    private

    # Copy the properties of the original pokemon
    def copy_properties
      original = @original
      COPIED_PROPERTIES.each do |ivar_name|
        instance_variable_set(ivar_name, original.instance_variable_get(ivar_name))
      end
    end

    # Copy the moveset of the original Pokemon
    def copy_moveset
      @moveset = Array.new(@original.skills_set.size)
      @original.skills_set.each_with_index do |skill, index|
        @moveset[index] = Battle::Move[skill.symbol].new(skill.id, skill.pp, skill.ppmax, @scene)
      end
      @skills_set = @moveset
    end
  end
end
