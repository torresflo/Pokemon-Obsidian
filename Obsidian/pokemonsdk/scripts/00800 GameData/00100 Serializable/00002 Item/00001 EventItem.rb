module GameData
  # Item that describe the kind of item that calls an event in map
  class EventItem < Item
    # Get the ID of the event to call
    # @return [Integer]
    attr_reader :event_id
    # Create a new event item
    # @param initialize_params [Array] params to create the Item object
    # @param event_id [Integer] ID of the event to call
    def initialize(*initialize_params, event_id)
      super(*initialize_params)
      @event_id = event_id.to_i.clamp(1, Float::INFINITY)
    end
  end
end

safe_code('Register EventItem ItemDescriptor') do
  PFM::ItemDescriptor.define_bag_use(GameData::EventItem, true) do |item, scene|
    condition = PFM::ItemDescriptor::COMMON_EVENT_CONDITIONS[GameData::EventItem.from(item).event_id]
    if condition.call
      $game_temp.common_event_id = GameData::EventItem.from(item).event_id
    else
      scene.display_message_and_wait(parse_text(22, 43))
      next :unused
    end
  end
end
