# Namespace that contains modules and classes written by Nuri Yuri
# @author Nuri Yuri
module Yuki
  # Module that allows the game to write and Error.log file if the Exception is not a SystemExit or a Reset
  #
  # Creation date : 2013, update : 26/09/2017
  # @author Nuri Yuri
  module EXC
    # Name of the current Game/Software
    Software = 'Pokémon SDK'

    module_function

    # Method that runs #build_error_log if the Exception is not a SystemExit or a Reset.
    # @overload run(e)
    #   The log is sent to Error.log
    #   @param e [Exception] the exception thrown by Ruby
    # @overload run(e, io)
    #   The log is sent to an io
    #   @param e [Exception] the exception thrown by Ruby
    #   @param io [#<<] the io that receive the log
    def run(e, io = nil)
      log_debug(e.inspect)
      return if e.class == LiteRGSS::DisplayWindow::ClosedWindowError
      raise if (e.message.empty? || e.class.to_s == 'Reset') && !e.is_a?(Interrupt)

      error_log = build_error_log(e)
      if io
        io << error_log
      else
        File.binwrite('Error.log', error_log)
        puts <<~EODSP
          The game crashed!
          The error is stored in Error.log.
        EODSP
      end
      dot_25_battle_reproduction($scene) if defined?(Battle::Scene) && $scene.is_a?(Battle::Scene)
      show_error_window(error_log) if $scene
    end

    # Method that build the error log.
    # @param e [Exception] the exception thrown by Ruby
    # @return [String] the log readable by anybody
    def build_error_log(e)
      str = ''
      return build_system_stack_error_log(e, str) if e.is_a?(SystemStackError)
      return unless e.backtrace_locations

      source_arr = e.backtrace_locations[0]
      source_name = fix_source_path(source_arr.path.to_s)
      source_line = source_arr.lineno
      str << 'Erreur de script'.center(80, '=')
      # Formatage du message pour Windows
      str << format("\r\nMessage :\r\n%<message>s\r\n\r\n", message: e.message.to_s.sub(/#<([^ ]+).*>/, '#<\1>').gsub(/[\r\n]+/, "\r\n"))
      str << format("Type : %<type>s\r\n", type: e.class)
      str << format("Script : %<script>s\r\n", script: source_name)
      str << format("Ligne : %<line>d\r\n", line: source_line)
      str << format("Date : %<date>s\r\n", date: Time.new.strftime('%d/%m/%Y %H:%M:%S'))
      str << format("Game Version : %<game_version>s\r\n", game_version: PSDK_CONFIG.game_version)
      str << format("Logiciel : %<software>s %<version>s\r\n", software: Software, version: PSDK_Version.to_str_version)
      str << format("Script used by eval command : \r\n%<script>s\r\n\r\n", script: @eval_script) if @eval_script
      str << 'Backtraces'.center(80, '=')
      str << "\r\n"
      index = e.backtrace_locations.size
      e.backtrace_locations.each do |i|
        index -= 1
        source_name = fix_source_path(i.path.to_s)
        str << format("[%<index>s] : %<script>s | ligne %<line>d %<method>s\r\n",
                      index: index, script: source_name, line: i.lineno, method: i.base_label)
      end
      str << 'Fin du log'.center(80, '=')
      Yuki.set_clipboard(str)
      return str
    end

    # Function that corrects the source path
    # @param source_name [String] the source name path
    # @return [String] the fixed source name
    def fix_source_path(source_name)
      source = source_name.sub(File.expand_path('.'), nil.to_s)
      unless source.sub!(%r{/pokemonsdk/scripts/(.*)}, '\1 (PSDK)') || source.sub!(%r{/scripts/(.*)}, '\1 (user)')
        source << (source.include?('/lib/') ? ' (ruby)' : ' (RMXP)')
      end
      return source
    end

    # Sets the script used by the eval command
    # @param script [String, nil] the script used in the eval command
    def set_eval_script(script)
      if script
        @eval_script = script
      else
        @eval_script = nil
      end
    end

    # Get the eval script used by the current eval command
    # @return [String, nil]
    def get_eval_script
      return @eval_script
    end

    # Build the SystemStackError message
    # @param e [SystemStackError]
    # @param str
    def build_system_stack_error_log(e, str)
      str << format("Message :\r\n%<message>s\r\n", message: e.message.to_s.gsub(/[\r\n]+/, "\r\n"))
      str << format("Type : %<type>s\r\n", type: e.class)
      str << format("Date : %<date>s\r\n", date: Time.new.strftime('%d/%m/%Y %H:%M:%S'))
      str << format("Game Version : %<game_version>s\r\n", game_version: PSDK_CONFIG.game_version)
      str << format("Logiciel : %<software>s %<version>s\r\n", software: Software, version: PSDK_Version.to_str_version)
      str << format("Script used by eval command : \r\n%<script>s\r\n", script: @eval_script) if @eval_script
      str << (e.backtrace || ['Unkown Sources...']).join("\r\n")
      return str
    end

    # Function building the reproduction file
    # @param scene [Battle::Scene]
    def dot_25_battle_reproduction(scene)
      PFM.game_state.game_temp = Game_Temp.new
      $game_map.begin_save
      compressed_data = Zlib::Deflate.deflate(Marshal.dump([PFM.game_state, scene.battle_info]), Zlib::BEST_COMPRESSION)
      File.binwrite('battle.dat', compressed_data)
    end

    # Function that shows the error window
    # @param log [String]
    def show_error_window(log)
      if defined?(GamePlay::Save)
        save_data = defined?(Battle::Scene) && $scene.is_a?(Battle::Scene) ? File.binread('battle.dat') : GamePlay::Save.save(nil, true)
        ErrorWindow.new.run(log, save_data)
      else
        ErrorWindow.new.run(log)
      end
    end
  end

  # Show an error window
  class ErrorWindow
    # Open the error window and let the user aknowledge it
    # @param error_text [String] Text stored inside Error.log
    # @param data_to_add [Array<String>] data to add to the error log as pictures
    def run(error_text, *data_to_add)
      texts_to_show = cleanup_error_log(error_text)
      if defined?(ScriptLoader.load_tool)
        ScriptLoader.load_tool('SaveToPicture')
        images_to_show = data_to_add.map { |i| SaveToPicture.run(data: i) }
        images_to_show << SaveToPicture.run(data: error_text)
      end
      show_window_and_wait(texts_to_show, images_to_show || [])
    end

    private

    # Function that generates the text to show
    # @param error_text [String]
    # @return [Array<String>]
    def cleanup_error_log(error_text)
      sections = error_text.split(/=+[^=]+=+\r*\n/).reject(&:empty?)
      backtraces = sections[1].split("\n")[0, 5].join("\n")
      message = sections[0].sub('Message', 'A script error happened')
      return message, "Backtraces:\n#{backtraces}"
    end

    # Function that shows the window and wait for the user to do something
    # @param texts_to_show [Array<String>] text to show into the window
    # @param images [Array<Image>]
    def show_window_and_wait(texts_to_show, images)
      @running = true
      if PSDK_RUNNING_UNDER_MAC
        show_window_and_wait_internal(texts_to_show, images) { update_graphics }
      else
        Thread.new { show_window_and_wait_internal(texts_to_show, images) }
        update_graphics while @running
      end
    end

    # Function that execute the window processing
    # @param texts_to_show [Array<String>] text to show into the window
    # @param images [Array<Image>]
    def show_window_and_wait_internal(texts_to_show, images)
      window = LiteRGSS::DisplayWindow.new('Error', 960, 480, 1, 32, 20, false, false, false)
      create_text(window, texts_to_show)
      to_dispose = create_and_arrange_images(window, images)
      window.on_closed = proc { @running = false }
      while @running
        window.update
        yield if block_given?
      end
      to_dispose.each { |bmp| bmp.dispose unless bmp.disposed? }
    end

    # Function that updates the ingame graphics
    def update_graphics
      Graphics.window&.update
      sleep(0.1)
    rescue Exception
      sleep(0.1)
    end

    # Function that create the text to show into the window
    # @param window [LiteRGSS::Window]
    # @param texts_to_show [Array<String>]
    def create_text(window, texts_to_show)
      text = LiteRGSS::Text.new(0, window, window.width - 2, 96, 0, 16, texts_to_show[1], 2)
      text.draw_shadow = false
      text.fill_color = Color.new(220, 220, 220, 255)
      text.size = 13
      text = LiteRGSS::Text.new(0, window, 0, 0, 0, 16, append_message(texts_to_show[0]))
      text.draw_shadow = false
      text.fill_color = Color.new(220, 220, 220, 255)
      text.size = 13
    end

    # Function that append the text to show with a message
    # @param input [String]
    # @return [String]
    def append_message(input)
      if $game_system&.map_interpreter&.running?
        eid = $game_system.map_interpreter.event_id
        event = $game_map.events&.[](eid)&.event
        event_info = "\nEventID: #{eid} (#{event&.x}, #{event&.y}) | MapID: #{$game_map.map_id}"
      end
      return "#{input.strip}#{event_info}\n\nTake a snapshot of this window and report the issue if you can't fix it yourself!"
    end

    # Function that displays the images in reverse order starting from bottom right of the screen
    # @param window [LiteRGSS::Window]
    # @param images [Array<Image>]
    # @return [Array<Texture>]
    def create_and_arrange_images(window, images)
      y = window.height
      x = window.width
      min_y = y
      return images.map do |image|
        bmp = Texture.new(image.width, image.height)
        image.copy_to_bitmap(bmp)
        if (x - image.width) < 0
          x = window.width
          y = min_y
        end
        x -= image.width
        iy = y - image.height
        min_y = [iy, min_y].min
        LiteRGSS::Sprite.new(window).set_position(x, iy).bitmap = bmp
        image.dispose
        x -= 1
        next bmp
      end
    end
  end
end

# Function responsive of reloading the saved battle
def reload_battle
  return log_error('There is no battle') unless File.exist?('battle.dat')

  PFM.game_state, battle_info = Marshal.load(Zlib::Inflate.inflate(File.binread('battle.dat')))
  PFM.game_state.expand_global_var
  PFM.game_state.load_parameters
  $game_map.setup($game_map.map_id)
  Graphics.freeze
  $scene = Battle::Scene.new(battle_info)
end
