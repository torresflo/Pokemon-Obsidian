# frozen_string_literal: true

module PFM
  module Message
    # Class holding all the properties for the currently showing message
    class Properties
      # All the properties that can be set in :[]: with the function to call to compute the property parameters
      # @return [Hash{String=>Symbol}]
      PROPERTIES = {
        'name' => :parse_speaker_name,
        'face' => :parse_speaker_face,
        'city' => :parse_city_filename,
        'can_skip' => :parse_can_skip,
        'windowskin' => :parse_window_skin,
        'lookto' => :look_to_event,
        'align' => :parse_message_align
      }

      # Parsed text of the message
      # @return [String]
      attr_reader :parsed_text
      # Tell that the message should show the gold window
      # @return [Boolean]
      attr_accessor :show_gold_window
      # Get the name to show
      # @return [String, nil]
      attr_reader :name
      # Get all the faces to show
      # @return [Array<Face>]
      attr_reader :faces
      # Get the city image to show
      # @return [String, nil]
      attr_reader :city_filename
      # Tell if user can skip the message using directional keys
      # @return [Boolean]
      attr_reader :can_skip_message
      # Get the windowsking overwrite of the current message
      # @return [String]
      attr_reader :windowskin_overwrite
      # Get the ID of the event to look to
      # @return [Integer]
      attr_reader :look_to
      # Get the message alignment
      # @return [Symbol] :left, :right, :center
      attr_reader :align

      # Create a new Properties object
      # @param parsed_text [String]
      def initialize(parsed_text)
        @parsed_text = parsed_text
        @show_gold_window = false
        @can_skip_message = false
        @name = nil
        @faces = []
        @align = :left
        preparse_properties
      end

      # Process the lookto operation
      def process_look_to
        return if @look_to == 0 || ! @look_to

        $game_player.look_to(@look_to)
      end

      private

      # Parse the speaker name
      # @param name [String] name of the speaker
      def parse_speaker_name(name)
        @name = name
      end

      # Parse the face of a speaker
      # @param info_str [String] infos about the face (position,name,opacity,mirror)
      def parse_speaker_face(info_str)
        position, name, opacity, mirror = info_str.split(',')
        face = Face.new
        face.position = position.to_i
        face.name = name
        face.opacity = opacity ? opacity.to_i.clamp(0, 255) : 255
        face.mirror = mirror == true
        @faces << face
      end

      # Parse the image setting of the city
      # @param name [String] name of the image in Pictures
      def parse_city_filename(name)
        @city_filename = name
      end

      # Parse the can skip authorisation
      # @param _ignored [String] ignored param
      def parse_can_skip(_ignored)
        @can_skip_message = true
      end

      # Parse the message box windowsking change
      # @param windowskin [String] name of the temporary windowskin
      def parse_window_skin(windowskin)
        @windowskin_overwrite = windowskin
      end

      # Turn the player toward the event of it's choice
      # @param event [String] the info about the chosen event
      # @example example of event
      #   If you want your player to turn to the talking event, write :[lookto=] or :[lookto=0]
      #   If you want your player to turn to another event, write :[lookto=X] where X is the event's id
      #   Take care to always write the id without the first 0. Example : 036 should always be written 36.
      def look_to_event(event)
        @look_to = event.to_i
      end

      # Parse the message alignment
      # @param align [String] position of text
      def parse_message_align(align = 'left')
        @align = align.to_sym
      end

      # Function that pre parse the properties so they're all set to the right value
      def preparse_properties
        self.show_gold_window = true if parsed_text.match?(/\\[Gg]/)
        parsed_text.gsub!(/\\[Gg]/, '')
        parsed_text.gsub!(/:\[([^\]]+)\]:/) { parse_properties($1) }
        parsed_text.gsub!(Text::S_000, '\\')
      end

      # Parse all the properties of a message set through :[prop_name1=a;prop_name2=a,b]:
      # @param unparsed_props [String] all the properties that were not currently parsed
      # @return nil
      def parse_properties(unparsed_props)
        unparsed_props.split(';').each do |property_string|
          property, values = property_string.split('=', 2)
          next unless (method_name = PROPERTIES[property])

          send(method_name, values)
        end
        return nil
      end

      # Class describing a face to show
      class Face
        # Get the face position
        # @return [Integer]
        attr_accessor :position
        # Get the face name (filename)
        # @return [String]
        attr_accessor :name
        # Get the face opacity
        # @return [Integer]
        attr_accessor :opacity
        # Get the face mirror state
        # @return [Boolean]
        attr_accessor :mirror
      end
    end
  end
end
