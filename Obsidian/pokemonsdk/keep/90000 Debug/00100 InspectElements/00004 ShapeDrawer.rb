return unless PSDK_CONFIG.debug?

module InspectElements
  module ShapeDrawer
    module_function
    def create_outline_box(shapes, viewport, box, outline = 2, color)
      shape = ::Shape.new(viewport, :rectangle, outline, box.height)
      shape.color = color
      shape.x = box.x
      shape.y = box.y
      shapes << shape
      shape = ::Shape.new(viewport, :rectangle, box.width, outline)
      shape.x = box.x
      shape.y = box.y
      shape.color = color
      shapes << shape
      shape = ::Shape.new(viewport, :rectangle, outline, box.height - outline)
      shape.x = box.x + box.width - outline
      shape.y = box.y
      shape.color = color
      shapes << shape
      shape = ::Shape.new(viewport, :rectangle, box.width - outline, outline)
      shape.x = box.x
      shape.y = box.y + box.height - outline
      shape.color = color
      shapes << shape
    end

    def create_annotated_outline_box(shapes, viewport, box, outline = 2, color)
      text = TextRaw.new(0, viewport, box.x + outline, box.y + outline + 11, 0, 0, "#{box.x}; #{box.y}", 0, nil, 2, 4)
      text.visible = false
      shapes << text
      ShapeDrawer.create_outline_box(shapes, viewport, box, outline, color)
      shape = ::Shape.new(viewport, :rectangle, box.width - outline, box.height - outline)
      shape.x = box.x
      shape.y = box.y
      shape.color = Color.new(220, 120, 120, 80)
      shape.visible = false
      shapes << shape
    end
  end
end