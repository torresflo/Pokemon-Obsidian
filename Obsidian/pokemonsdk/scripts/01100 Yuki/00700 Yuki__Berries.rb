module Yuki
  # Module that manage the growth of berries.
  # @author Nuri Yuri
  #
  # The berry informations are stored in $pokemon_party.berries, a 2D Array of berry information
  #   $pokemon_party.berries[map_id][event_id] = [berry_id, stage, timer, stage_time, water_timer, water_time, water_counter, info_engrais]
  module Berries
    # The base name of berry character
    PLANTED_CHAR = 'Z_BP'
    # Berry data / db_symbol
    # @return [Hash{ symbol => Data }]
    BERRY_DATA = {}

    module_function

    # Init a berry tree
    # @param map_id [Integer] id of the map where the berry tree is
    # @param event_id [Integer] id of the event where the berry tree is shown
    # @param berry_id [Integer] ID of the berry Item in the database
    # @param state [Integer] the growth state of the berry
    def init_berry(map_id, event_id, berry_id, state = 4)
      return unless (berry_data = BERRY_DATA[GameData::Item[berry_id].db_symbol])

      data = find_berry_data(map_id)[event_id] = Array.new(8, 0)
      data[0] = berry_id
      data[1] = state
      data[3] = berry_data.time_to_grow * 15
      data[5] = data[3] - 1
    end

    # Test if a berry is on an event
    # @param event_id [Integer] ID of the event
    # @return [Boolean]
    def here?(event_id)
      return false unless (data = @data[event_id])

      return data[0] != 0
    end

    # Retrieve the ID of the berry that is planted on an event
    # @param event_id [Integer] ID of the event
    # @return [Integer]
    def get_berry_id(event_id)
      return 0 unless (data = @data[event_id])

      return data[0]
    end

    # Retrieve the Internal ID of the berry (text_id)
    # @param event_id [Integer] ID of the event
    # @return [Integer]
    def get_berry_internal_id(event_id)
      return 0 unless (data = @data[event_id])

      item_id = data[0]
      if item_id < 213
        return item_id - 149
      elsif item_id > 685
        return item_id - 622
      end

      return 0
    end

    # Retrieve the stage of a berry
    # @param event_id [Integer] ID of the event
    # @return [Integer]
    def get_stage(event_id)
      return 0 unless (data = @data[event_id])

      return data[1]
    end

    # Tell if the berry is watered
    # @param event_id [Integer] ID of the event
    # @return [Boolean]
    def watered?(event_id)
      return true unless (data = @data[event_id])

      return data[4] > 0
    end

    # Water a berry
    # @param event_id [Integer] ID of the event
    def water(event_id)
      return unless (data = @data[event_id])

      data[4] = data[5]
      data[6] += 1
    end

    # Plant a berry
    # @param event_id [Integer] ID of the event
    # @param berry_id [Integer] ID of the berry Item in the database
    def plant(event_id, berry_id)
      @data[event_id] = Array.new(8,0) unless @data[event_id]
      return unless (berry_data = BERRY_DATA[GameData::Item[berry_id].db_symbol])

      data = @data[event_id]
      data[0] = berry_id
      data[1] = 0
      data[3] = berry_data.time_to_grow * 15 # hours * 60 mins  / 4 steps
      data[2] = data[3]
      data[4] = 0
      data[5] = data[3] - 1
      data[6] = 0
      data[7] = 0
      update_event(event_id, data)
    end

    # Take the berries from the berry tree
    # @param event_id [Integer] ID of the event
    # @return [Integer] the number of berry taken from the tree
    def take(event_id)
      return unless (data = @data[event_id])
      return unless (berry_data = BERRY_DATA[GameData::Item[data[0]].db_symbol])

      delta = berry_data.max_yield - berry_data.min_yield
      water_times = data[6] # 0..4
      amount = berry_data.min_yield + delta * water_times / 4

      $bag.add_item(data[0], amount)
      data[0] = 0
      return amount
    end

    # Initialization of the Berry management
    def init
      @data = find_berry_data($game_map.map_id)
      @data.each do |event_id, data|
        update_event(event_id, data)
      end
      MapLinker.added_events.each do |map_id, stack|
        berry_data = find_berry_data(map_id)
        stack.each do |event|
          if (data = berry_data[event.original_id])
            update_event(event.id, data)
          end
        end
      end
    end

    # Update of the berry management
    def update
      $pokemon_party.berries.each do |_, berries|
        berries.each do |event_id, data|
          next if data[0] == 0

          # Update timer
          data[2] -= 1 if data[2] >= 0
          # Update water timer
          data[4] -= 1 if data[2] >= 0 && data[4] > 0
          # Update stage
          next unless data[1] < 4 and (data[2] % data[3]) == 0

          data[1] += 1
          data[2] = data[3]
          update_event(event_id, data) if data.__id__ == @data[event_id].__id__
        end
      end
    end

    # Update of the berry event graphics
    # @param event_id [Integer] id of the event where the berry tree is shown
    # @param data [Array] berry data
    def update_event(event_id, data)
      return unless (event = $game_map.events[event_id])
      return event.opacity = 0 if data[0] == 0

      stage = data[1]
      event.character_name = stage == 0 ? PLANTED_CHAR : "Z_B#{data[0]}"
      event.direction = (stage == 1 ? 2 : (stage == 2 ? 4 : (stage == 3 ? 6 : 8)))
      event.opacity = 255
    end

    # Search the Berry data of the map
    # @param map_id [Integer] id of the Map
    def find_berry_data(map_id)
      data = $pokemon_party.berries ||= {}
      return data[map_id] ||= {}
    end

    # Return the berry data
    def data
      @data
    end

    # Data describing a berry in the Berry system
    class Data
      # Bitter factor of the berry
      # @return [Integer]
      attr_accessor :bitter
      # Minimum amount of berry yield
      # @return [Integer]
      attr_accessor :min_yield
      # Sour factor of the berry
      # @return [Integer]
      attr_accessor :sour
      # Maximum amount of berry yield
      # @return [Integer]
      attr_accessor :max_yield
      # Spicy factor of the berry
      # @return [Integer]
      attr_accessor :spicy
      # Dry factor of the berry
      # @return [Integer]
      attr_accessor :dry
      # Sweet factor of the berry
      # @return [Integer]
      attr_accessor :sweet
      # Time the berry take to grow
      # @return [Integer]
      attr_accessor :time_to_grow
      # Create a new berry
      # @param time_to_grow [Integer] number of hours the berry need to fully grow
      # @param min_yield [Integer] minimum quantity the berry can yield
      # @param max_yield [Integer] maximum quantity the berry can yield
      # @param taste_info [Hash{ Symbol => Integer}]
      def initialize(time_to_grow, min_yield, max_yield, taste_info)
        self.time_to_grow = time_to_grow
        self.min_yield = min_yield
        self.max_yield = max_yield
        self.bitter = taste_info[:bitter] || 0
        self.dry = taste_info[:dry] || 0
        self.sweet = taste_info[:sweet] || 0
        self.spicy = taste_info[:spicy] || 0
        self.sour = taste_info[:sour] || 0
      end
    end

    BERRY_DATA[:cheri_berry] = Data.new(12, 2, 5, spicy: 10)
    BERRY_DATA[:chesto_berry] = Data.new(12, 2, 5, dry: 10)
    BERRY_DATA[:pecha_berry] = Data.new(12, 2, 5, sweet: 10)
    BERRY_DATA[:rawst_berry] = Data.new(12, 2, 5, bitter: 10)
    BERRY_DATA[:aspear_berry] = Data.new(12, 2, 5, sour: 10)
    BERRY_DATA[:leppa_berry] = Data.new(16, 2, 5, spicy: 10, bitter: 10, sour: 10, sweet: 10)
    BERRY_DATA[:oran_berry] = Data.new(16, 2, 5, spicy: 10, bitter: 10, sour: 10, sweet: 10, dry: 10)
    BERRY_DATA[:persim_berry] = Data.new(16, 2, 5, spicy: 10, sour: 10, sweet: 10, dry: 10)
    BERRY_DATA[:lum_berry] = Data.new(48, 2, 5, spicy: 10, bitter: 10, sweet: 10, dry: 10)
    BERRY_DATA[:sitrus_berry] = Data.new(32, 2, 5, bitter: 10, sour: 10, sweet: 10, dry: 10)
    BERRY_DATA[:figy_berry] = Data.new(20, 1, 5, spicy: 15)
    BERRY_DATA[:wiki_berry] = Data.new(20, 1, 5, dry: 15)
    BERRY_DATA[:mago_berry] = Data.new(20, 1, 5, sweet: 15)
    BERRY_DATA[:aguav_berry] = Data.new(20, 1, 5, bitter: 15)
    BERRY_DATA[:iapapa_berry] = Data.new(20, 1, 5, sour: 15)
    BERRY_DATA[:razz_berry] = Data.new(8, 2, 10, dry: 10, spicy: 10)
    BERRY_DATA[:bluk_berry] = Data.new(8, 2, 10, dry: 10, sweet: 10)
    BERRY_DATA[:nanab_berry] = Data.new(8, 2, 10, bitter: 10, sweet: 10)
    BERRY_DATA[:wepear_berry] = Data.new(8, 2, 10, bitter: 10, sour: 10)
    BERRY_DATA[:pinap_berry] = Data.new(8, 2, 10, spicy: 10, sour: 10)
    BERRY_DATA[:pomeg_berry] = Data.new(32, 1, 5, spicy: 10, bitter: 10, sweet: 10)
    BERRY_DATA[:kelpsy_berry] = Data.new(32, 1, 5, sour: 10, bitter: 10, dry: 10)
    BERRY_DATA[:qualot_berry] = Data.new(32, 1, 5, sour: 10, spicy: 10, sweet: 10)
    BERRY_DATA[:hondew_berry] = Data.new(32, 1, 5, sour: 10, spicy: 10, bitter: 10, dry: 10)
    BERRY_DATA[:grepa_berry] = Data.new(32, 1, 5, sour: 10, spicy: 10, sweet: 10)
    BERRY_DATA[:tamato_berry] = Data.new(32, 1, 5, spicy: 20, dry: 10)
    BERRY_DATA[:cornn_berry] = Data.new(24, 2, 10, dry: 20, sweet: 10)
    BERRY_DATA[:magost_berry] = Data.new(24, 2, 10, bitter: 10, sweet: 20)
    BERRY_DATA[:rabuta_berry] = Data.new(24, 2, 10, bitter: 20, sour: 10)
    BERRY_DATA[:nomel_berry] = Data.new(24, 2, 10, spicy: 10, sour: 20)
    BERRY_DATA[:spelon_berry] = Data.new(60, 2, 15, spicy: 30, dry: 10)
    BERRY_DATA[:pamtre_berry] = Data.new(60, 2, 15, dry: 30, sweet: 10)
    BERRY_DATA[:watmel_berry] = Data.new(60, 2, 15, sweet: 30, bitter: 10)
    BERRY_DATA[:durin_berry] = Data.new(60, 2, 15, bitter: 30, sour: 10)
    BERRY_DATA[:belue_berry] = Data.new(60, 2, 15, sour: 30, spicy: 10)
    BERRY_DATA[:occa_berry] = Data.new(72, 1, 5, spicy: 15, sweet: 10)
    BERRY_DATA[:passho_berry] = Data.new(72, 1, 5, dry: 15, bitter: 10)
    BERRY_DATA[:wacan_berry] = Data.new(72, 1, 5, sweet: 15, sour: 10)
    BERRY_DATA[:rindo_berry] = Data.new(72, 1, 5, bitter: 15, spicy: 10)
    BERRY_DATA[:yache_berry] = Data.new(72, 1, 5, sour: 15, dry: 10)
    BERRY_DATA[:chople_berry] = Data.new(72, 1, 5, spicy: 15, bitter: 10)
    BERRY_DATA[:kebia_berry] = Data.new(72, 1, 5, dry: 15, sour: 10)
    BERRY_DATA[:shuca_berry] = Data.new(72, 1, 5, sweet: 15, spicy: 10)
    BERRY_DATA[:coba_berry] = Data.new(72, 1, 5, bitter: 15, dry: 10)
    BERRY_DATA[:payapa_berry] = Data.new(72, 1, 5, sour: 15, sweet: 10)
    BERRY_DATA[:tanga_berry] = Data.new(72, 1, 5, spicy: 20, sour: 10)
    BERRY_DATA[:charti_berry] = Data.new(72, 1, 5, dry: 20, spicy: 10)
    BERRY_DATA[:kasib_berry] = Data.new(72, 1, 5, sweet: 20, dry: 10)
    BERRY_DATA[:haban_berry] = Data.new(72, 1, 5, bitter: 20, sweet: 10)
    BERRY_DATA[:colbur_berry] = Data.new(72, 1, 5, sour: 20, bitter: 10)
    BERRY_DATA[:babiri_berry] = Data.new(72, 1, 5, spicy: 25, dry: 10)
    BERRY_DATA[:chilan_berry] = Data.new(72, 1, 5, dry: 25, sweet: 10)
    BERRY_DATA[:liechi_berry] = Data.new(96, 1, 5, spicy: 30, sweet: 30, dry: 10)
    BERRY_DATA[:ganlon_berry] = Data.new(96, 1, 5, bitter: 30, dry: 30, sweet: 10)
    BERRY_DATA[:salac_berry] = Data.new(96, 1, 5, sweet: 30, sour: 30, bitter: 10)
    BERRY_DATA[:petaya_berry] = Data.new(96, 1, 5, bitter: 30, spicy: 30, sour: 10)
    BERRY_DATA[:apicot_berry] = Data.new(96, 1, 5, sour: 30, dry: 30, spicy: 10)
    BERRY_DATA[:lansat_berry] = Data.new(96, 1, 5, bitter: 10, sour: 30, dry: 10, sweet: 30, spicy: 30)
    BERRY_DATA[:starf_berry] = Data.new(96, 1, 5, bitter: 10, sour: 30, dry: 10, sweet: 30, spicy: 30)
    BERRY_DATA[:enigma_berry] = Data.new(96, 1, 5, spicy: 40, dry: 10)
    BERRY_DATA[:micle_berry] = Data.new(96, 1, 5, dry: 40, sweet: 10)
    BERRY_DATA[:custap_berry] = Data.new(96, 1, 5, sweet: 40, bitter: 10)
    BERRY_DATA[:jaboca_berry] = Data.new(96, 1, 5, bitter: 40, sour: 10)
    BERRY_DATA[:rowap_berry] = Data.new(96, 1, 5, sour: 40, spicy: 10)
    BERRY_DATA[:rowap_berry] = Data.new(96, 1, 5, sour: 40, spicy: 10)
    BERRY_DATA[:roseli_berry] = Data.new(72, 1, 5, sour: 10, sweet: 20)
    BERRY_DATA[:kee_berry] = Data.new(96, 1, 5, sweet: 40, sour: 10)
    BERRY_DATA[:maranga_berry] = Data.new(96, 1, 5, bitter: 40, dry: 10)
    # Add berry related task to the Scheduler
    ::Scheduler.add_message(:on_update, TJN, 'Update berries using time system', 1000, self, :update)
    ::Scheduler.add_message(:on_warp_process, 'Scene_Map', 'Init baies', 99, self, :init)
    ::Scheduler.add_message(:on_init, 'Scene_Map', 'Init baies', 99, self, :init)
  end
end
