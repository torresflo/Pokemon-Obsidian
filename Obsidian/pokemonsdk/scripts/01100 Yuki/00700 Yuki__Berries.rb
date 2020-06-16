#encoding: utf-8

module Yuki
  # Module that manage the growth of berries.
  # @author Nuri Yuri
  # 
  # The berry informations are stored in $pokemon_party.berries, a 2D Array of berry information
  #   $pokemon_party.berries[map_id][event_id] = [berry_id, stage, timer, stage_time, water_timer, water_time, water_counter, info_engrais]
  module Berries
    # The base name of berry character
    PlantedChar = "Z_BP"
    module_function
    # Init a berry tree
    # @param map_id [Integer] id of the map where the berry tree is
    # @param event_id [Integer] id of the event where the berry tree is shown
    # @param berry_id [Integer] ID of the berry Item in the database
    # @param state [Integer] the growth state of the berry
    def init_berry(map_id, event_id, berry_id, state = 4)
      return unless (berry_data = GameData::Item[berry_id].misc_data&.berry)

      data = find_berry_data(map_id)[event_id] = Array.new(8, 0)
      data[0] = berry_id
      data[1] = state
      data[3] = berry_data[:time_to_grow]*15
      data[5] = data[3] - 1
    end
    # Test if a berry is on an event
    # @param event_id [Integer] ID of the event
    # @return [Boolean]
    def here?(event_id)
      return false unless data = @data[event_id]
      return data[0] != 0
    end
    # Retrieve the ID of the berry that is planted on an event
    # @param event_id [Integer] ID of the event
    # @return [Integer]
    def get_berry_id(event_id)
      return 0 unless data = @data[event_id]
      return data[0]
    end
    # Retrieve the Internal ID of the berry (text_id)
    # @param event_id [Integer] ID of the event
    # @return [Integer]
    def get_berry_internal_id(event_id)
      return 0 unless data = @data[event_id]
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
      return 0 unless data = @data[event_id]
      return data[1]
    end
    # Tell if the berry is watered
    # @param event_id [Integer] ID of the event
    # @return [Boolean]
    def watered?(event_id)
      return true unless data = @data[event_id]
      return data[4] > 0
    end
    # Water a berry
    # @param event_id [Integer] ID of the event
    def water(event_id)
      return unless data = @data[event_id]
      data[4] = data[5]
      data[6] += 1
    end
    # Plant a berry
    # @param event_id [Integer] ID of the event
    # @param berry_id [Integer] ID of the berry Item in the database
    def plant(event_id, berry_id)
      @data[event_id] = Array.new(8,0) unless @data[event_id]
      return unless (berry_data = GameData::Item[berry_id].misc_data&.berry)

      data = @data[event_id]
      data[0] = berry_id
      data[1] = 0
      data[3] = berry_data[:time_to_grow]*15 #hours * 60 mins  / 4 steps
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
      return unless data = @data[event_id]
      return unless (berry_data = GameData::Item[data[0]].misc_data&.berry)

      amount = berry_data[:min_yield]
      rand_delta = berry_data[:max_yield] - amount
      rand_sub = data[6] / 2 #>Valeur soustraite au rand pour garantir une ou deux de plus)
      rand_delta -= rand_sub
      amount += (rand(rand_delta+1) + rand_sub)
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
          if data = berry_data[event.original_id]
            update_event(event.id, data)
          end
        end
      end
    end
    # Update of the berry management
    def update
      map_id = berries = event_id = data = nil
      #>Mise à jour des informations de chaque baies
      $pokemon_party.berries.each do |map_id, berries|
        berries.each do |event_id, data|
          next if data[0] == 0
          #>Actualisation du timer
          data[2] -= 1 if data[2] >= 0
          #>Actualisation du water_timer
          data[4] -= 1 if data[2] >= 0 and data[4] > 0
          #>Actualisation du stage
          if data[1] < 4 and (data[2] % data[3]) == 0
            data[1] += 1
            data[2] = data[3]
            update_event(event_id, data) if data.__id__ == @data[event_id].__id__
          end
        end
      end
    end
    # Update of the berry event graphics
    # @param event_id [Integer] id of the event where the berry tree is shown
    # @param data [Array] berry data
    def update_event(event_id, data)
      return unless event = $game_map.events[event_id]
      if(data[0] == 0)
        return event.opacity = 0
      end
      stage = data[1]
      event.character_name = stage == 0 ? PlantedChar : "Z_B#{data[0]}"
      event.direction = (stage == 1 ? 2 : (stage == 2 ? 4 : (stage == 3 ? 6 : 8)))
      event.opacity = 255
    end
    # Search the Berry data of the map
    # @param map_id [Integer] id of the Map
    def find_berry_data(map_id)
      $pokemon_party.berries = Hash.new unless $pokemon_party.berries
      data = $pokemon_party.berries
      data[map_id] = Hash.new unless data[map_id]
      return data[map_id]
    end
    # Return the berry data
    def data
      @data
    end
    # Add berry related task to the Scheduler
    ::Scheduler.add_message(:on_update, TJN, 'Update berries using time system', 1000, self, :update)
    ::Scheduler.add_message(:on_warp_process, 'Scene_Map', 'Init baies', 99, self, :init)
    ::Scheduler.add_message(:on_init, 'Scene_Map', 'Init baies', 99, self, :init)
  end
end
