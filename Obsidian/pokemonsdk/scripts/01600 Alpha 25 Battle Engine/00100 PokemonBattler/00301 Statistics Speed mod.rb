module PFM
  class PokemonBattler
    # List of ability speed modifier
    SPEED_MODIFIER_ABILITY = Hash.new(:calc_us_1).merge!(
      chlorophyll: :calc_us_chlorophyll,
      quick_feet:  :calc_us_quick_feet,
      slow_start:  :calc_us_slow_start,
      swift_swim:  :calc_us_swift_swim,
      unburden:    :calc_us_unburden
    )
    # List of item speed modifier
    SPEED_MODIFIER_ITEM = Hash.new(:calc_us_1).merge!(
      choice_scarf: :calc_us_1_5,
      iron_ball:    :calc_us_0_5,
      macho_brace:  :calc_us_0_5,
      power_anklet: :calc_us_0_5,
      power_band:   :calc_us_0_5,
      power_belt:   :calc_us_0_5,
      power_bracer: :calc_us_0_5,
      power_lens:   :calc_us_0_5,
      power_weight: :calc_us_0_5,
      quick_powder: :calc_us_quick_powder
    )
    # Paralysis counter modifier
    PARALYSIS_MODIFIER_1 = 4
    # Paralysis modifier
    PARALYSIS_MODIFIER = 1.0 / PARALYSIS_MODIFIER_1
    # Constant containing 1.5
    VAL_1_5 = 1.5
    # Constant containing 0.5
    VAL_0_5 = 0.5

    private

    # Method that returns 1 as speed modifier
    # @return [Integer]
    def calc_us_1
      return 1
    end

    # Method that returns 1.5 as speed modifier
    # @return [Integer]
    def calc_us_1_5
      return VAL_1_5
    end

    # Method that returns 0.5 as speed modifier
    # @return [Integer]
    def calc_us_0_5
      return VAL_0_5
    end

    # Method that returns 2 if the sun is bright with Chlorophyll ability
    # @return [Integer]
    def calc_us_chlorophyll
      return $env.sunny? ? 2 : 1
    end

    # Quick feet speed modifier
    # @return [Float]
    def calc_us_quick_feet
      # TODO : fetch the right paralysis modifier
      return paralyzed? ? PARALYSIS_MODIFIER_1 * VAL_1_5 : VAL_1_5
    end

    # Slow Start speed modifier
    # @return [Numeric]
    def calc_us_slow_start
      return VAL_1_5 if @turn_count < 5
      return 1
    end

    # Swift Swim speed modifier
    # @return [Integer]
    def calc_us_swift_swim
      return $env.rain? ? 2 : 1
    end

    # Unburden speed modifier
    # @return [Integer]
    def calc_us_unburden
      return 1 if @item_holding >= 0
      return @item_holding != @original.item_holding ? 2 : 1
    end

    # Ditto's quick powder speed modifier
    # @return [Integer]
    def calc_us_quick_powder
      return db_symbol == :ditto ? 2 : 1
    end
  end
end
