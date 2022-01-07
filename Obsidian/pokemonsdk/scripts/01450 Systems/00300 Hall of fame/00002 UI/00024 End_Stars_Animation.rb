module UI
  module Hall_of_Fame
    # Class that define the End Stars animation stack
    class End_Stars_Animation < SpriteStack
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @stars = Array.new(20) { Star_Animation.new(viewport, 5, repeat: true) }
        @stars.each { |star| star.set_position(rand(320), rand(240)) }
        @counter = 0
      end

      # Update each star's animation
      def update
        @stars.each_with_index do |star, index|
          if star.sx == 0
            star.set_position(rand(320), rand(240))
          end
          star.update if (index * 10) <= @counter
        end
        @counter += 1
      end
    end
  end
end
