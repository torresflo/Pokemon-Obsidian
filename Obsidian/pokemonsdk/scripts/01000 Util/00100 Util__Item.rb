# Module that contain helpers for various scripts
module Util
  # Item Helper
  # @author Nuri Yuri
  module Item
    # Use an item in a GamePlay::Base child class
    # @param item_id [Integer] ID of the item in the database
    def util_item_useitem(item_id, &result_process)
      item = GameData::Item[item_id]
      extend_data = ::PFM::ItemDescriptor.actions(item.id)

      if extend_data[:chen]
        display_message(parse_text(22, 43))
        return false
      elsif extend_data[:no_effect]
        display_message(parse_text(22, 108))
        return false
      end
      if $actors.empty? && extend_data[:open_party]
        display_message(parse_text(22, 119))
        return false
      end
      return util_item_open_party_sequence(item, extend_data, result_process) if extend_data[:open_party]
      return util_item_on_use_sequence(item, extend_data) if extend_data[:on_use]

      if extend_data[:action_to_push] || extend_data[:ball_data]
        @return_data = [item.id, extend_data, false]
        @running = false
      end
      return extend_data
    end

    # Part where the extend_data request to open the party
    # @param item [GameData::Item]
    # @param extend_data [Hash]
    # @param result_process [Proc, nil]
    # @return [Hash, false]
    def util_item_open_party_sequence(item, extend_data, result_process)
      call_scene(GamePlay::Party_Menu, @team || $actors, :item, extend_data, no_leave: false) do |scene|
        if $game_temp.in_battle && scene.return_data != -1
          @return_data = [item.id, extend_data, scene.return_data]
          @running = false
          next
        end
        $bag.remove_item(item.id, 1) if item.limited && scene.return_data != -1
        result_process&.call
      end
      return false unless @running

      return extend_data
    end

    # Part where the extend_data request to use the item
    # @param item [GameData::Item]
    # @param extend_data [Hash]
    # @return [Hash, false]
    def util_item_on_use_sequence(item, extend_data)
      message = parse_text(22, 46, ::PFM::Text::TRNAME[0] => $trainer.name,
                                   ::PFM::Text::ITEM2[1] => item.exact_name)

      if extend_data[:use_before_telling]
        if extend_data[:on_use].call != :unused
          $bag.remove_item(item.id, 1) if item.limited
          display_message(message) if $scene == self
          return extend_data
        end
        return false
      end

      $bag.remove_item(item.id, 1) if item.limited
      display_message(message)
      extend_data[:on_use].call

      return extend_data
    end
  end
end
