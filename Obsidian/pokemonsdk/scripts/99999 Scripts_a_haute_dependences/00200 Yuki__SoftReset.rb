unless PARGV[:worldmap] || PARGV[:"animation-editor"] || PARGV[:test] || PARGV[:tags]
  # Add soft reset sequence
  Scheduler.add_proc(:on_update, :any, 'SoftReset', 10**99) do
    if Input::Keyboard.press?(Input::Keyboard::F12) && $scene.class != Yuki::SoftReset
      # Set the running to false if possible
      $scene&.instance_variable_set(:@running, false)
      # Switching the scene to the soft reset
      $scene = Yuki::SoftReset.new
      # Telling soft reset is processing
      cc 0x03
      puts 'Soft resetting...'
      cc 0x07
      raise Reset, ''
    end
  end

  module Yuki
    # Class that manage the soft reset
    class SoftReset
      # Main process of the scene
      def main
        # Force the on_transition event to be called
        Scheduler.start(:on_transition)
        # Disposing everything and freeing memory
        Audio.__reset__
        ObjectSpace.each_object(LiteRGSS::Viewport) { |v| v.dispose unless v.disposed? }
        GC.start
        ObjectSpace.each_object(LiteRGSS::Sprite) { |s| s.dispose unless s.disposed? }
        ObjectSpace.each_object(LiteRGSS::Text) { |t| t.dispose unless t.disposed? }
        ObjectSpace.each_object(LiteRGSS::Bitmap) { |b| b.dispose unless b.disposed? }
        Pathfinding.debug = false
        GC.start
        # Reloading required ressources
        Graphics.on_start { Graphics.init_sprite }
        ts = 0.1
        sleep(ts) while Input::Keyboard.press?(Input::Keyboard::F12)
        $scene = Scheduler.get_boot_scene
      end

      def update
        return
      end

      def display_message(*)
        return
      end
    end
  end

  class Reset < StandardError
  end
end
