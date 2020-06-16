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
      return if e.class == LiteRGSS::Graphics::ClosedWindowError
      raise if e.message.empty? || e.class.to_s == 'Reset'

      error_log = build_error_log(e)
      if io
        io << error_log
      else
        File.open('Error.log', 'wb') { |f| f << error_log }
        try_graphic_display
      end
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
      str << format("\r\nMessage :\r\n%<message>s\r\n\r\n", message: e.message.to_s.gsub(/[\r\n]+/, "\r\n"))
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

    # Try to show the exception
    def try_graphic_display
      str = <<~EODSP
        The game crashed!
        We copied the error in the clipboard. You can also find it in Error.log
      EODSP
      begin
        @vp = Viewport.create(:main, 100_000)
        @vp.color = Color.new(255, 0, 0)
        Text.new(0, vp, 0, 16, vp.rect.width, Font::FONT_SMALL, str, 1, 0, 10)
      rescue StandardError
        puts str
        system('pause')
        return
      end
      Graphics.wait(100)
      Graphics.update until Input.trigger?(:C)
      @vp.dispose
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
  end
end
