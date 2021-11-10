module BattleUI
  # Abstraction of the Target Selection to comply with what the Visual expect
  module TargetSelectionAbstraction
    # The position (bank, position) of the choosen target
    # @return [Array, :cancel]
    attr_accessor :result

    # If the player made a choice
    # @return [Boolean]
    def validated?
      !@result.nil? && (respond_to?(:done?, true) ? done? : true)
    end

    private

    # Function that initialize the required data to ensure every necessary instance variables are set
    # @param launcher [PFM::PokemonBattler]
    # @param move [Battle::Move]
    # @param logic [Battle::Logic]
    def initialize_data(launcher, move, logic)
      @launcher = launcher
      @move = move
      @logic = logic
      @row_size = logic.battle_info.vs_type
      @targets = move.battler_targets(launcher, logic).select(&:alive?)
      @allow_selection = !move.no_choice_skill?
      @mons = generate_mon_list
      @index = find_best_index
    end

    # Choose the target
    # @return [Boolean] if the operation was a success
    def choose_target
      if @targets.empty?
        @result = [1, 0]
        return true
      end

      target = @allow_selection ? @buttons[@index].data : @targets.first
      target = @targets.sample(random: @logic.generic_rng) if @move.target == :random_foe
      if @targets.include?(target)
        @result = [target.bank, target.position]
        return true
      end

      return false
    end

    # Tell that the player cancelled
    # @return [Boolean]
    def choice_cancel
      @result = :cancel
      return true
    end

    # Generate the list of mons shown by the UI
    # @return [Array<PFM::PokemonBattler>]
    def generate_mon_list
      2.times.map do |bank|
        @logic.battle_info.vs_type.times.map do |position|
          @logic.battler(bank, position)
        end
      end.reverse.flatten
    end

    # Find the best possible index as default index
    # @return [Integer]
    def find_best_index
      return @mons.index(@targets.first).to_i
    end
  end
end
