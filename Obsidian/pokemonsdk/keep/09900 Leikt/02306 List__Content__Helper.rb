module UI
  class List
    # Module that calculate the coords for an Horizontal list
    module HorizontalContent
      module_function

      # Retrieve the item size
      # @param item_type [Class] the class of the item
      # @param item_param [Hash] the item instanciation parameters
      # @param [Integer]
      def item_size(item_type, item_param)
        return item_type.retrieve_width(item_param)
      end

      # Retrieve the content display length
      # @return [Integer]
      def viewport_size(viewport)
        return viewport.rect.width
      end

      # Retrieve the width of the content
      # @param data_length [Integer] the count of data in the list
      # @param item_size [Integer] the size of the item in pixel
      # @param viewport [Viewport] the content viewport
      # @return [Integer]
      def width(data_length, item_size, _viewport)
        return data_length * item_size
      end

      # Retrieve the height of the content
      # @param data_length [Integer] the count of data in the list
      # @param item_size [Integer] the size of the item in pixel
      # @param viewport [Viewport] the content viewport
      # @return [Integer]
      def height(_data_length, _item_size, viewport)
        return viewport.rect.height
      end

      # Calculate the cursor width
      # @param viewport [Viewport] the list viewport
      # @param item_size [Integer] the size of an item
      # @return [Integer]
      def cursor_width(_viewport, item_size)
        return item_size
      end

      # Calculate the cursor height
      # @param viewport [Viewport] the list viewport
      # @param item_size [Integer] the size of an item
      # @return [Integer]
      def cursor_height(viewport, _item_size)
        return viewport.rect.height
      end

      # Get the object position
      # @param obj [Object] object with x, y methods
      # @return [Integer]
      def object_position(obj)
        return obj.x
      end

      # Get the object origin
      # @param obj [Object] object with oy, ox methods
      # return [Integer]
      def object_origin(obj)
        return obj.ox
      end

      # Set the content origin
      # @param content [Object] and object with oy= and ox= methods
      # @param value [Integer] the new content position
      def set_object_origin(content, value)
        content.ox = value
      end

      # Set the object position. Do nothing is obj is nil
      # @param obj [Object] an object with x=, y= methods
      # @param value [Integer] the new position
      def set_object_position(obj, value)
        obj.x = value if obj
      end

      # Set the other coord object position. Do nothing if obj is nil
      # @param obj [Object] an object with x=, y= methods
      # @param value [Integer] the new position
      def set_object_other_position(obj, value)
        obj.y = value if obj
      end
    end

    # Module that calculate the coords for an Vertical list
    module VerticalContent
      module_function

      # Retrieve the item size
      # @param item_type [Class] the class of the item
      # @param item_param [Hash] the item instanciation parameters
      # @param [Integer]
      def item_size(item_type, item_param)
        return item_type.retrieve_height(item_param)
      end

      # Retrieve the content display length
      # @return [Integer]
      def viewport_size(viewport)
        return viewport.rect.height
      end

      # Retrieve the width of the content
      # @param data_length [Integer] the count of data in the list
      # @param item_size [Integer] the size of the item in pixel
      # @param viewport [Viewport] the content viewport
      # @return [Integer]
      def width(_data_length, _item_size, viewport)
        return viewport.rect.width
      end

      # Retrieve the height of the content
      # @param data_length [Integer] the count of data in the list
      # @param item_size [Integer] the size of the item in pixel
      # @param viewport [Viewport] the content viewport
      # @return [Integer]
      def height(data_length, item_size, _viewport)
        return data_length * item_size
      end

      # Calculate the cursor width
      # @param viewport [Viewport] the list viewport
      # @param item_size [Integer] the size of an item
      # @return [Integer]
      def cursor_width(viewport, _item_size)
        return viewport.rect.width
      end

      # Calculate the cursor height
      # @param viewport [Viewport] the list viewport
      # @param item_size [Integer] the size of an item
      # @return [Integer]
      def cursor_height(_viewport, item_size)
        return item_size
      end

      # Get the object position
      # @param obj [Object] object with x, y methods
      # @return [Integer]
      def object_position(obj)
        return obj.y
      end

      # Get the object origin
      # @param obj [Object] object with oy, ox methods
      # return [Integer]
      def object_origin(obj)
        return obj.oy
      end

      # Set the content origin
      # @param content [Object] and object with oy= and ox= methods
      # @param value [Integer] the new content position
      def set_object_origin(content, value)
        content.oy = value
      end

      # Set the object position. Do nothing is obj is nil
      # @param obj [Object] an object with x=, y= methods
      # @param value [Integer] the new position
      def set_object_position(obj, value)
        obj.y = value if obj
      end

      # Set the other coord object position. Do nothing if obj is nil
      # @param obj [Object] an object with x=, y= methods
      # @param value [Integer] the new position
      def set_object_other_position(obj, value)
        obj.x = value if obj
      end
    end
  end
end
