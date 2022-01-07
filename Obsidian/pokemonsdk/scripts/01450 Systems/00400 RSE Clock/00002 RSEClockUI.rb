module GamePlay
  module RSEClockHelpers
    # Module defining the UI of the RSE Clock
    module UI
      # @!parse include GamePlay::Base
      # @!parse include Logic

      private

      def create_graphics
        create_viewport

        create_background
        create_clock
        create_am_pm
        create_minute_aiguille
        create_hour_aiguille
      end

      def create_background
        @background = ::UI::BlurScreenshot.new(viewport, __last_scene)
      end

      def create_clock
        @clock = Sprite.new(viewport).load('clock/clock', :interface)
        @clock.set_origin_div(2, 2).set_position(viewport.rect.width / 2, viewport.rect.height / 2)
      end

      def create_am_pm
        @am_pm = SpriteSheet.new(viewport, 1, 2).load('clock/am_pm', :interface).set_position(@clock.x - 14, @clock.y + 24)
      end

      def create_minute_aiguille
        @minute_aiguille = Sprite.new(viewport).load('clock/minute', :interface).set_position(@clock.x, @clock.y).set_origin(6, 44)
      end

      def create_hour_aiguille
        @hour_aiguille = Sprite.new(viewport).load('clock/hour', :interface).set_position(@clock.x, @clock.y).set_origin(5, 24)
      end

      def update_aiguilles
        @hour_aiguille.angle = -(hour % 12) * 30 - minute / 2
        @minute_aiguille.angle = -minute * 6
        @am_pm.sy = hour / 12
        @waiter = Yuki::Animation.wait(0.016)
        @waiter.start
      end

      def update_waiter
        @waiter.update
        @sm_execute_next_state = @waiter.done?
      end
    end
  end
end
