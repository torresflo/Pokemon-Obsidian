# Module that contain helpers for various scripts
module Util
  # Item Helper
  # @author Nuri Yuri
  module Item
    # Use an item in a GamePlay::Base child class
    # @param item_id [Integer] ID of the item in the database
    # @return [PFM::ItemDescriptor::Wrapper, false] item descriptor wrapper if the item could be used
    def util_item_useitem(item_id, &result_process)
      extend_data = PFM::ItemDescriptor.actions(item_id)

      if extend_data.chen
        display_message(parse_text(22, 43))
        return false
      elsif extend_data.no_effect
        display_message(parse_text(22, 108))
        return false
      elsif $actors.empty? && extend_data.open_party
        display_message(parse_text(22, 119))
        return false
      elsif extend_data.open_party
        return util_item_open_party_sequence(extend_data, result_process)
      end
      return util_item_on_use_sequence(extend_data)
=begin
      if extend_data[:action_to_push] || extend_data[:ball_data]
        @return_data = [item.id, extend_data, false]
        @running = false
      end
      return extend_data
=end
    end

    # Part where the extend_data request to open the party
    # @param extend_data [PFM::ItemDescriptor::Wrapper]
    # @param result_process [Proc, nil]
    # @return [PFM::ItemDescriptor::Wrapper, false]
    def util_item_open_party_sequence(extend_data, result_process)
      party = @team || $actors
      GamePlay.open_party_menu_to_use_item(extend_data, party) do |scene|
        if $game_temp.in_battle && scene.pokemon_selected?
          GamePlay.bag_mixin.from(self).battle_item_wrapper = extend_data
          @running = false
          next
        elsif scene.pokemon_selected?
          $bag.remove_item(extend_data.item.id, 1) if extend_data.item.limited
        end
        result_process&.call
      end
      return false unless @running

      return extend_data
    end

    # Part where the extend_data request to use the item
    # @param extend_data [PFM::ItemDescriptor::Wrapper]
    # @return [PFM::ItemDescriptor::Wrapper, false]
    def util_item_on_use_sequence(extend_data)
      message = parse_text(22, 46, PFM::Text::TRNAME[0] => $trainer.name,
                                   PFM::Text::ITEM2[1] => extend_data.item.exact_name)

      if extend_data.use_before_telling
        if extend_data.on_use(self) != :unused
          $bag.remove_item(extend_data.item.id, 1) if extend_data.item.limited
          display_message(message) if $scene == self
          return_to_scene(Scene_Map) if $game_temp.common_event_id > 0
          return extend_data
        end
        return false
      end

      $bag.remove_item(extend_data.item.id, 1) if extend_data.item.limited
      display_message(message)
      extend_data.on_use(self)

      return extend_data
    end
  end
end
