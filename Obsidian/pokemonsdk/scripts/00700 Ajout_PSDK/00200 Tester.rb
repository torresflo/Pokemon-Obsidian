#encoding: utf-8

# Class designed to test an interface or a script
class Tester
  @@args = nil
  @@class = nil
  # Create a new test
  # @param script [String] filename of the script to test
  def initialize(script)
    @script = script
    $tester = self
    Object.define_method(:reload) { $tester.load_script }
    Object.define_method(:restart) { $tester.restart_scene }
    Object.define_method(:quit) { $tester.quit_test }
    data_load
    PFM::GameState.new.expand_global_var
    @thread = Thread.new do 
      while true
        sleep(0.1)
        if Input::Keyboard.press?(Input::Keyboard::F9)
          print "\rMouse coords = %d,%d\nCommande : " % [Mouse.x, Mouse.y]
          sleep(0.5)
        end
      end
    end
    load_script
    show_test_message
    @unlocked = true
  rescue Exception
    manage_exception
  end
  # Main process of the tester
  def main
    Graphics.update until @unlocked
    $scene = @@class.new(*@@args)
    $scene.main
    if $scene != self
      $scene = nil
      @thread.kill
    end
  rescue Exception
    manage_exception
  end
  # Retart the scene
  # @return [true]
  def restart_scene
    $scene.instance_variable_set(:@running, false)
    $scene = self
    @unlocked = true
    return true
  end
  # Show the test message
  def show_test_message
    cc 0x02
    puts "Testing script #{@script}"
    cc 0x07
    puts "Type : "
    puts "reload to reload the script"
    puts "restart to restart the scene"
    puts "quit to quit the test"
    print "Commande : "
  end
  # Quit the test
  def quit_test
    restart_scene
    $scene = nil
  end
  # Load the script
  # @return [true]
  def load_script
    script = File.open(@script, "r") { |f| break(f.read(f.size)) }
    eval(script, $global_binding, @script)
    return true
  end
  # Manage the exception
  def manage_exception
    raise if $!.class == LiteRGSS::DisplayWindow::ClosedWindowError
    puts Yuki::EXC.build_error_log($!)
    cc 0x01
    puts "Test locked, type reload and restart to unlock"
    cc 0x07
    restart_scene
    @unlocked = false
  end
  # Define the class and the arguments of it to test
  # @param klass [Class] the class to test
  # @param args [Array] the arguments
  def self.start(klass, *args)
    @@class = klass
    @@args = args
  end  
  # Load the RMXP Data
  def data_load
    unless $data_actors
      $data_actors        = _clean_name_utf8(load_data("Data/Actors.rxdata"))
      $data_classes       = _clean_name_utf8(load_data("Data/Classes.rxdata"))
      $data_enemies       = _clean_name_utf8(load_data("Data/Enemies.rxdata"))
      $data_troops        = _clean_name_utf8(load_data("Data/Troops.rxdata"))
      $data_tilesets      = _clean_name_utf8(load_data("Data/Tilesets.rxdata"))
      $data_common_events = _clean_name_utf8(load_data("Data/CommonEvents.rxdata"))
      $data_system        = load_data_utf8("Data/System.rxdata")
    end
    $game_system = Game_System.new
    $game_temp = Game_Temp.new
  end
end
