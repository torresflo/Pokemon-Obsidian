#encoding: utf-8

# Module that holds every data structure of RMXP and some specific modules/classes
module RPG
  # Structure of Events
  class Event
    # Properties dedicated to the MapLinker
    attr_accessor :original_id, :original_map, :offset_x, :offset_y

  end
end
