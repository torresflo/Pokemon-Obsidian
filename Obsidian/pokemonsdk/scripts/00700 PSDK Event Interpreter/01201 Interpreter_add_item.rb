class Interpreter

  MODE_SWOOSH = true

  # Add an item to the bag if possible, will delete the event forever
  # @param item_id [Integer] id of the item in the database
  # @param no_delete [Boolean] bypass the deletion of the event
  # @param text_id [Integer] ID of the text used when the item is found
  # @param no_space_text_id [Integer] ID of the text when the player has not enough space in the bag
  # @param count [Integer] number of item to add
  # @param color [Integer] color to put on the item name
  def add_item(item_id, no_delete = false, text_id: 4, no_space_text_id: 7, color: 11, count: 1)
    item_id = GameData::Item.get_id(item_id) if item_id.is_a?(Symbol)

    if (max = GameData::Bag::MaxItem) > 0 && ($bag.item_quantity(item_id) + count) >= max
      add_item_no_space(item_id, no_space_text_id, color)
    else
      item_text, socket = add_item_show_message_got(item_id, text_id, color, count: count)
      # Pokemon Sword/Shield does not show this type of message
      # If you want your game to show it, change MODE_SWOOSH to false
      if count == 1 && !MODE_SWOOSH
        show_message(
          :bag_store_item_in_pocket,
          item_1: item_text, header: SYSTEM_MESSAGE_HEADER,
          PFM::Text::TRNAME[0] => $trainer.name,
          '[VAR 0112(0002)]' => GameData::Bag.get_socket_name(socket)
        )
      end
      $bag.add_item(item_id, count)
      delete_this_event_forever unless no_delete
    end

    @wait_count = 2
  end

  # Pick an item on the ground (and delete the event)
  # @param item_id [Integer] id of the item in the database
  # @param count [Integer] number of item
  # @param no_delete [Boolean] if the event should not be delete forever
  def pick_item(item_id, count = 1, no_delete = false)
    add_item(item_id, no_delete, text_id: 4, count: count)
  end

  # Give an item to the player
  # @param item_id [Integer] id of the item in the database
  # @param count [Integer] number of item
  def give_item(item_id, count = 1)
    item_id = GameData::Item.get_id(item_id) if item_id.is_a?(Symbol)
    text_id = GameData::Item.socket(item_id) == 5 ? 1 : 0
    add_item(item_id, true, text_id: text_id, count: count)
  end

  private

  # Show the too bad no space phrase in the add_item command
  # @param item_id [Integer]
  # @param no_space_text_id [Integer] ID of the text when the player has not enough space in the bag
  # @param color [Integer] color to put on the item name
  def add_item_no_space(item_id, no_space_text_id, color)
    item_text = "\\c[#{color}]#{GameData::Item.exact_name(item_id)}\\c[10]"

    MESSAGES[:bag_full_text] = proc { text_get(41, no_space_text_id) }
    show_message(
      :bag_full_text,
      item_1: item_text, header: SYSTEM_MESSAGE_HEADER,
      PFM::Text::TRNAME[0] => $trainer.name
    )
  end

  # Show the item got text
  # @param item_id [Integer]
  # @param text_id [Integer] ID of the text used when the item is found
  # @param color [Integer] color to put on the item name
  # @return [Array<String, Integer>] the name of the item with the decoration and its socket
  def add_item_show_message_got(item_id, text_id, color, count: 1)
    count == 1 ? item_text = "\\c[#{color}]#{GameData::Item.name(item_id)}\\c[10]" : item_text = "\\c[#{color}]#{ext_text(9001, item_id)}\\c[10]"
    misc_data = GameData::Item.misc_data(item_id)
    socket = GameData::Item.socket(item_id)
    
    Audio.me_play(ItemGetME[(socket == 3 ? 2 : (socket == 5 ? 1 : 0))], 80)
    if misc_data&.skill_learn
      text_id = text_id <= 3 ? 3 : 6
      MESSAGES[:hm_got_text] = proc { text_get(41, text_id) }
      show_message(
        :hm_got_text,
        item_1: item_text, header: SYSTEM_MESSAGE_HEADER, PFM::Text::TRNAME[0] => $trainer.name,
        PFM::Text::MOVE[2] => "\\c[#{color}]#{GameData::Skill.name(misc_data.skill_learn)}\\c[10]"
      )
    else
      MESSAGES[:item_got_text] = proc { text_get(41, text_id) }
      show_message(
        :item_got_text,
        item_1: item_text, header: SYSTEM_MESSAGE_HEADER,
        PFM::Text::TRNAME[0] => $trainer.name,
        '[VAR 1402(0001)]' => "#{count} "
      )
    end
    return item_text, socket
  end
end
