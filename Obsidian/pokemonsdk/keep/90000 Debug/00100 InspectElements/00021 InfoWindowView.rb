return unless PSDK_CONFIG.debug?

module InspectElements
  class InfoWindowView < UI::SpriteStack
    def initialize(viewport, model)
      super(viewport)
      @viewport = viewport
      @model = model
      @texts = []
      @form_fields = []
      @focused_form_field = nil
      rebuild_items
    end

    def refresh_view
      rebuild_items
    end

    def update_inputs
      @focused_form_field&.update_inputs(@model.text_entered)
    end

    def update_mouse_click(button, mouse_x, mouse_y)
      @focused_form_field = nil
      @form_fields.each do |field|
        if @focused_form_field.nil? && field.update_focus(mouse_x, mouse_y)
          @focused_form_field = field
          @model.text_entered = @focused_form_field.value_text
        else
          field.focus_out
        end
      end
    end

    private
    def rebuild_items
      @texts.each(&:dispose)
      @form_fields.each(&:dispose)
      @texts = []
      @form_fields = []
      @model.data.each do |display_data|
        offset_x = display_data.box&.x - display_data.original_box&.x
        offset_y = display_data.box&.y - display_data.original_box&.y

        @form_fields = DisplayDataDetailsEditor.new(display_data).element_details

        content = "Type: #{display_data}\n" \
                  "Relative position: #{display_data.box}\n" \
                  "Offset: (#{offset_x},#{offset_y})\n"
        @texts << add_text(0, 0, 0, 25, content, 0, color: 32, sizeid: 12)
        y = 60
        @form_fields.each do |form_field|
          form_field.render(@viewport, 0, y += form_field.height)
        end
      end
    end
  end
end
