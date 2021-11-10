return unless PSDK_CONFIG.debug?

module InspectElements
  class DisplayDataDetailsEditor
    def initialize(display_data)
      @element = display_data.element
    end

    def element_details
      result = []
      return result if @element.nil?

      result << DisplayDataDetailsField.new("Instance var.", @element.instance_variables.to_s)
      if @element.is_a?(Viewport)
        # TODO ?
      elsif @element.is_a?(Window)
        # TODO ?
      elsif @element.is_a?(Sprite) && !@element.is_a?(Plane)
        result << DisplayDataDetailsField.new("Texture Filename", @element.bitmap&.filename, proc do |new_value|
          @element.bitmap = ::LiteRGSS::Bitmap.new(new_value)
        end)
      elsif @element.is_a?(Text)
        align = ""
        case @element.align
        when 0
          align = "left"
        when 1
          align = "center"
        when 2
          align = "right"
        end

        result << DisplayDataDetailsField.new("Align", align, proc do |new_value|
          case new_value
          when "left"
            @element.align = 0
          when "center"
            @element.align = 1
          when "right"
            @element.align = 2
          end
        end)

        result << DisplayDataDetailsField.new("Text", @element.text, proc do |new_value|
          @element.text = new_value
        end)
      end
      return result
    end

  end
end