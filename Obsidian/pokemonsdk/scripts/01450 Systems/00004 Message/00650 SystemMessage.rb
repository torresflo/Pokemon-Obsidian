module Util
  # Module that help showing system message.
  #
  # How to use it :
  # ```ruby
  #   include Util::SystemMessage
  #   # ...
  #     show_message(:message_name) # Basic message
  #     if yes_no_choice(load_message(:message_name)) # Choice from interpreter
  #       show_message(:message_name, pokemon: pokemon) # Will set PKNICK[0] & PKNAME[0]
  #       show_message(:message_name, pokemon_1: pokemon) # Will set PKNICK[1] & PKNAME[1]
  #       show_message(:message_name, item: item_id, pokemon: pokemon) # Will set ITEM2[0], PKNICK[0] & PKNAME[0]
  #       show_message_and_wait(:message_name) # Will wait until the message box disappear
  # ```
  #
  # How to define ":message_name"s :
  #   - Simple message (from RH) : `Util::SystemMessage::MESSAGES[:message_name] = [:text_get, id, line]`
  #   - Complex message : `Util::SystemMessage::MESSAGES[:message_name] = proc { |opts| next(message_contents) }`
  # Note : opts are the optionnals arguments sent to show_message
  module SystemMessage
    # List of message by name
    MESSAGES = {
      received_pokemon: [:ext_text, 8999, 15],
      give_nickname_question: [:ext_text, 8999, 16],
      is_nickname_correct_qesion: [:ext_text, 8999, 17],
      pokemon_stored_to_box: [:ext_text, 8999, 18],
      bag_store_item_in_pocket: [:text_get, 41, 9],
      pokemon_shop_unavailable: [:ext_text, 9003, 1]
    }
    # Capture regexp
    HAS_NUMBER_REG = /_([0-9]+)$/
    # Tell if the key contain pokemon
    IS_POKEMON = /^pokemon/
    # Tell if the key contain item
    IS_ITEM = /^item/
    # Tell if the key contain num1
    IS_NUMBER1 = /^num1/
    # Tell if the key contain num2
    IS_NUMBER2 = /^num2/
    # Tell if the key contain num3
    IS_NUMBER3 = /^num3/

    module_function

    # Load a message
    # @param message_name [Symbol] ID of the message in MESSAGES
    # @param opts [Hash] options (additional text replacement)
    def load_message(message_name, opts = nil)
      PFM::Text.reset_variables
      parse_opts(opts) if opts
      message_data = MESSAGES[message_name]
      string = message_data.is_a?(Array) ? send(*message_data) : message_data.call(opts)
      string = opts[:header] + string if opts&.key?(:header)
      return PFM::Text.parse_string_for_messages(string.dup)
    ensure
      PFM::Text.reset_variables
    end

    # Show a message
    # @param message_name [Symbol] ID of the message in MESSAGES
    # @param opts [Hash] options (additional text replacement)
    def show_message(message_name, opts = nil)
      message_text = load_message(message_name, opts)
      if is_a?(Interpreter)
        message(message_text)
      elsif is_a?(Scene_Map) || is_a?(GamePlay::Base)
        display_message(message_text)
      else
        $scene.display_message(message_text)
      end
    end

    # Show a message
    # @param message_name [Symbol] ID of the message in MESSAGES
    # @param opts [Hash] options (additional text replacement)
    def show_message_and_wait(message_name, opts = nil)
      message_text = load_message(message_name, opts)
      if is_a?(GamePlay::Base)
        return display_message_and_wait(message_text)
      elsif is_a?(Interpreter)
        message(message_text)
      else
        $scene.display_message(message_text)
      end
    end

    # Parse the message opts
    # @param opts [Hash] options (additional text replacement)
    def parse_opts(opts)
      text_handler = PFM::Text
      opts.each do |key, value|
        next text_handler.set_variable(key, value) if key.is_a?(String)
        number = key.match(HAS_NUMBER_REG)&.captures&.first&.to_i || 0
        if key.match?(IS_POKEMON)
          text_handler.set_pkname(value, number)
          text_handler.set_pknick(value, number)
        elsif key.match?(IS_ITEM)
          text_handler.set_item_name(value, number)
        elsif key.match?(IS_NUMBER1)
          text_handler.set_num1(value, number)
        elsif key.match?(IS_NUMBER2)
          text_handler.set_num2(value, number)
        elsif key.match?(IS_NUMBER3)
          text_handler.set_num3(value, number)
        end
      end
    end
  end
end

Interpreter.include(Util::SystemMessage) # Give it for real to the interpreter
