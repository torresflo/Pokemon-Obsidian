boot_time = Time.new

# Loading all the game scripts
begin
  puts 'Loading Game...'
  ScriptLoader.load_tool('GameLoader/Z_main') unless PARGV[:util].to_a.any?
  ScriptLoader.start
  SafeExec.load
  GC.start
rescue StandardError
  display_game_exception('An error occured during Script Loading.')
end

# Loading all the utility
begin
  PARGV[:util].to_a.each do |filename|
    if filename.start_with?('project_compilation')
      ScriptLoader.load_tool('Compilation/project_compilation')
    else
      require filename
    end
  end
  pausable_util = /(update)/
  system('pause') if !PARGV[:util].empty? && PARGV[:util].any? { |util| util.match?(pausable_util) }
rescue StandardError
  display_game_exception('An error occured during Utility loading...')
end

# Actually start the game
begin
  puts format('Time to boot game : %<time>ss', time: (Time.new - boot_time))
  $GAME_LOOP&.call
rescue Exception
  display_game_exception('An error occured during Game Loop.')
end
