ScriptLoader.load_tool('GameLoader/Z_main')

def PSDK_CONFIG.vsync_enabled
  return false
end

module Graphics
  module_function
  def emulate_144Hz
    if @last_emulation_time
      d = Time.new - @last_emulation_time
      wait = 0.006944444444444444 - d
      sleep(wait) if wait > 0
    end
    @last_emulation_time = Time.new
  end
end
Graphics.on_start do
  win = Graphics.window
  def win.update
    super
    Graphics.emulate_144Hz
  end
  def win.update_no_input
    super
    Graphics.emulate_144Hz
  end
end