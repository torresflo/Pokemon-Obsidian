module UI
  module Casino
    # Object showing image that should be aligned
    class BandDisplay < Sprite
      # List of files that shows the images of the band
      FILES = %w[casino/v1 casino/v2 casino/v3 casino/v4
                 casino/v5 casino/v6 casino/v7]
      # List of loaded image for shorter processing
      # @return [Array<Image>]
      @@loaded_images = []
      # Band information
      # @return [Array<Integer>]
      attr_reader :band
      # Animation speed of the band
      # @return [Integer]
      attr_accessor :animation_speed
      # Tell if the band is locked or not
      # @return [Boolean]
      attr_accessor :locked

      # Create a new BandDisplay
      # @param viewport [Viewport]
      # @param x [Integer]
      # @param y [Integer]
      # @param band [Array<Integer>]
      # @param speed [Integer] speed of the band
      def initialize(viewport, x, y, band, speed)
        super(viewport)
        @band = band
        make_band
        set_position(x, y)
        self.opacity = 224
        @animation_speed = speed
        @locked = true
      end

      # Update the animation
      def update
        return if done?
        if @locked
          @animation_speed.times do
            src_rect.y -= 1
            break if done?
          end
        else
          src_rect.y -= @animation_speed
        end
        src_rect.y = src_rect.y % (7 * cell_height)
      end

      # Tell if the animation is done
      def done?
        return (src_rect.y % cell_height) == 0 && @locked
      end

      # Get the current value of the image shown by the band
      # @param row [Integer] row you want the value
      # @return [Integer]
      def value(row = 1)
        value_index = src_rect.y / cell_height + row
        return @band[value_index % @band.size]
      end

      private

      def make_band
        band_images = load_images
        dest_img = Image.new(cell_width, cell_height * 10)
        rect = Rect.new(0, 0, cell_width, cell_height)
        @band.each_with_index do |value, index|
          dest_img.blt(0, cell_height * index, band_images[value], rect)
        end
        bmp = Texture.new(dest_img.width, dest_img.height)
        dest_img.copy_to_bitmap(bmp)
        self.bitmap = bmp
        self.src_rect.height = 3 * cell_height
        dest_img.dispose
      end

      def cell_width
        28
      end

      def cell_height
        22
      end

      # Load the band images
      # @return [Array<Image>]
      def load_images
        if @@loaded_images.empty?
          FILES.each { |filename| @@loaded_images << RPG::Cache.interface_image(filename) }
        end
        return @@loaded_images
      end

      class << self
        public

        # Dispose all the loaded images
        def dispose_images
          @@loaded_images.each(&:dispose)
          @@loaded_images.clear
        end
      end
    end
  end
end
